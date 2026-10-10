import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/settings_state.dart';
import '../../data/settings_repository.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late SettingsRepository _repo;

  @override
  SettingsState build() {
    _repo = ref.read(settingsRepositoryProvider);
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final iva = await _repo.getIva() ?? 0.15;
    final exp = await _repo.getExpirationDays() ?? 30;
    final stock = await _repo.getStockMinimo() ?? 5;

    final ruc = await _repo.getSriRuc() ?? '';
    final razonSocial = await _repo.getSriRazonSocial() ?? '';
    final estab = await _repo.getSriEstablecimiento() ?? '001';
    final punto = await _repo.getSriPuntoEmision() ?? '001';
    final amb = await _repo.getSriAmbiente() ?? 1;
    final fPath = await _repo.getSriFirmaPath() ?? '';
    final fPass = await _repo.getSriFirmaPassword() ?? '';

    state = SettingsState(
      ivaVigente: iva,
      expirationAlertDays: exp,
      stockMinimo: stock,
      sriRuc: ruc,
      sriRazonSocial: razonSocial,
      sriEstablecimiento: estab,
      sriPuntoEmision: punto,
      sriAmbiente: amb,
      sriFirmaPath: fPath,
      sriFirmaPassword: fPass,
    );
  }

  Future<void> updateIva(double newIva) async {
    await _repo.saveIva(newIva);
    state = state.copyWith(ivaVigente: newIva);
  }

  Future<void> updateExpirationDays(int days) async {
    await _repo.saveExpirationDays(days);
    state = state.copyWith(expirationAlertDays: days);
  }

  Future<void> updateStockMinimo(int stock) async {
    await _repo.saveStockMinimo(stock);
    state = state.copyWith(stockMinimo: stock);
  }

  Future<void> updateSriSettings({
    String? ruc,
    String? razonSocial,
    String? establecimiento,
    String? puntoEmision,
    int? ambiente,
    String? firmaPath,
    String? firmaPassword,
  }) async {
    await _repo.saveSriSettings(
      ruc: ruc,
      razonSocial: razonSocial,
      establecimiento: establecimiento,
      puntoEmision: puntoEmision,
      ambiente: ambiente,
      firmaPath: firmaPath,
      firmaPassword: firmaPassword,
    );
    state = state.copyWith(
      sriRuc: ruc,
      sriRazonSocial: razonSocial,
      sriEstablecimiento: establecimiento,
      sriPuntoEmision: puntoEmision,
      sriAmbiente: ambiente,
      sriFirmaPath: firmaPath,
      sriFirmaPassword: firmaPassword,
    );
  }
}
