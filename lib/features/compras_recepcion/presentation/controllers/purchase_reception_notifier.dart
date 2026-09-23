import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/drift_purchase_repository.dart';
import '../../../proveedores/domain/entities/supplier.dart';
import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/repositories/i_purchase_repository.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';

/// Estado inmutable de la recepción de mercadería / factura de compra
class PurchaseReceptionState {
  final Supplier? selectedSupplier;
  final String invoiceNumber;
  final String? authorizationNumber;
  final DateTime invoiceDate;
  final DateTime receptionDate;
  final List<PurchaseItem> items;
  final String? observations;
  final bool isLoading;
  final String? errorMessage;
  final PurchaseInvoice? lastConfirmedInvoice;
  final double ivaVigente;

  PurchaseReceptionState({
    this.selectedSupplier,
    this.invoiceNumber = '',
    this.authorizationNumber,
    DateTime? invoiceDate,
    DateTime? receptionDate,
    this.items = const [],
    this.observations,
    this.isLoading = false,
    this.errorMessage,
    this.lastConfirmedInvoice,
    this.ivaVigente = 0.15,
  })  : invoiceDate = invoiceDate ?? DateTime.now(),
        receptionDate = receptionDate ?? DateTime.now();

  double get subtotalDoce => items
      .where((item) => item.tieneIva)
      .fold(0.0, (acc, item) => acc + item.subtotal);

  double get subtotalCero => items
      .where((item) => !item.tieneIva)
      .fold(0.0, (acc, item) => acc + item.subtotal);

  double get iva => (subtotalDoce * ivaVigente);

  double get total => subtotalDoce + subtotalCero + iva;

  double get totalUnidades => items.fold(0.0, (acc, item) => acc + item.cantidadUnidades);

  bool get isValid =>
      selectedSupplier != null &&
      invoiceNumber.trim().isNotEmpty &&
      items.isNotEmpty;

  PurchaseReceptionState copyWith({
    Supplier? selectedSupplier,
    String? invoiceNumber,
    String? authorizationNumber,
    DateTime? invoiceDate,
    DateTime? receptionDate,
    List<PurchaseItem>? items,
    String? observations,
    bool? isLoading,
    String? errorMessage,
    PurchaseInvoice? lastConfirmedInvoice,
    double? ivaVigente,
  }) {
    return PurchaseReceptionState(
      selectedSupplier: selectedSupplier ?? this.selectedSupplier,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      authorizationNumber: authorizationNumber ?? this.authorizationNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      receptionDate: receptionDate ?? this.receptionDate,
      items: items ?? this.items,
      observations: observations ?? this.observations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastConfirmedInvoice: lastConfirmedInvoice ?? this.lastConfirmedInvoice,
      ivaVigente: ivaVigente ?? this.ivaVigente,
    );
  }
}

/// Notifier que controla la lógica de recepción de mercadería y cuadre de factura
class PurchaseReceptionNotifier extends StateNotifier<PurchaseReceptionState> {
  final IPurchaseRepository _purchaseRepo;
  final Ref _ref;

  PurchaseReceptionNotifier(this._purchaseRepo, this._ref) : super(PurchaseReceptionState(ivaVigente: _ref.read(settingsProvider).ivaVigente)) {
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await _purchaseRepo.getDraft();
    if (draft != null) {
      final supplier = Supplier(
        id: draft.proveedorId,
        nombreEmpresa: draft.proveedorNombre,
        ruc: draft.proveedorRuc,
        telefonoEmpresa: '', // Mock for UI
        direccion: '',
      );
      state = state.copyWith(
        selectedSupplier: supplier,
        invoiceNumber: draft.numeroFactura == 'BORRADOR' ? '' : draft.numeroFactura,
        authorizationNumber: draft.numeroAutorizacionSri,
        invoiceDate: draft.fechaEmision,
        receptionDate: draft.fechaRecepcion,
        items: draft.items,
        observations: draft.observaciones,
      );
    }
  }

  Future<void> _saveDraft() async {
    if (state.selectedSupplier == null) return;
    
    final invoice = PurchaseInvoice(
      proveedorId: state.selectedSupplier!.id ?? 0,
      proveedorNombre: state.selectedSupplier!.nombreEmpresa,
      proveedorRuc: state.selectedSupplier!.ruc,
      numeroFactura: state.invoiceNumber.isNotEmpty ? state.invoiceNumber : 'BORRADOR',
      numeroAutorizacionSri: state.authorizationNumber,
      fechaEmision: state.invoiceDate,
      fechaRecepcion: state.receptionDate,
      subtotalDoce: state.subtotalDoce,
      subtotalCero: state.subtotalCero,
      iva: state.iva,
      total: state.total,
      observaciones: state.observations,
      items: state.items,
    );
    await _purchaseRepo.saveDraft(invoice);
  }

  void selectSupplier(Supplier supplier) {
    state = state.copyWith(selectedSupplier: supplier);
    _saveDraft();
  }

  void setInvoiceNumber(String number) {
    state = state.copyWith(invoiceNumber: number.trim());
    _saveDraft();
  }

  void setAuthorizationNumber(String? auth) {
    state = state.copyWith(authorizationNumber: auth?.trim());
    _saveDraft();
  }

  void setInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
    _saveDraft();
  }

  void setObservations(String? obs) {
    state = state.copyWith(observations: obs?.trim());
    _saveDraft();
  }

  void addItem(PurchaseItem item) {
    final updated = List<PurchaseItem>.from(state.items)..add(item);
    state = state.copyWith(items: updated);
    _saveDraft();
  }

  void updateItem(int index, PurchaseItem item) {
    if (index >= 0 && index < state.items.length) {
      final updated = List<PurchaseItem>.from(state.items);
      updated[index] = item;
      state = state.copyWith(items: updated);
      _saveDraft();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final updated = List<PurchaseItem>.from(state.items)..removeAt(index);
      state = state.copyWith(items: updated);
      _saveDraft();
    }
  }

  void insertItem(int index, PurchaseItem item) {
    if (index >= 0 && index <= state.items.length) {
      final updated = List<PurchaseItem>.from(state.items)..insert(index, item);
      state = state.copyWith(items: updated);
      _saveDraft();
    }
  }

  void clear() {
    state = PurchaseReceptionState(ivaVigente: _ref.read(settingsProvider).ivaVigente);
    _purchaseRepo.discardDraft();
  }

  /// Guarda atómicamente la recepción en la base de datos
  Future<PurchaseInvoice?> confirmReception() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Debe completar el proveedor, número de factura y al menos un producto');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final invoice = PurchaseInvoice(
        proveedorId: state.selectedSupplier!.id!,
        proveedorNombre: state.selectedSupplier!.nombreEmpresa,
        proveedorRuc: state.selectedSupplier!.ruc,
        numeroFactura: state.invoiceNumber,
        numeroAutorizacionSri: state.authorizationNumber,
        fechaEmision: state.invoiceDate,
        fechaRecepcion: state.receptionDate,
        subtotalDoce: state.subtotalDoce,
        subtotalCero: state.subtotalCero,
        iva: state.iva,
        total: state.total,
        observaciones: state.observations,
        items: state.items,
      );

      final registered = await _purchaseRepo.registerPurchase(invoice);
      await _purchaseRepo.discardDraft();
      state = PurchaseReceptionState(lastConfirmedInvoice: registered);
      return registered;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Error al registrar recepción: $e');
      return null;
    }
  }
}

final purchaseReceptionProvider = StateNotifierProvider<PurchaseReceptionNotifier, PurchaseReceptionState>((ref) {
  final repo = ref.read(purchaseRepositoryProvider);
  return PurchaseReceptionNotifier(repo, ref);
});
