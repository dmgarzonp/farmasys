import '../../../../core/constants/sri_constants.dart';

/// Contrato abstracto para formas de pago (SOLID: OCP)
/// Nuevas formas de pago (billeteras electrónicas, seguros médicos) se añaden extendiendo esta clase.
abstract class PaymentMethodHandler {
  final SriPaymentMethod sriMethod;
  final double amount;

  const PaymentMethodHandler({
    required this.sriMethod,
    required this.amount,
  });

  String get displayName => sriMethod.label;
  bool validate();
}

/// Pago en efectivo con cálculo de vuelto
class CashPaymentHandler extends PaymentMethodHandler {
  final double receivedAmount;

  const CashPaymentHandler({
    required super.amount,
    required this.receivedAmount,
  }) : super(sriMethod: SriPaymentMethod.efectivo);

  double get changeAmount => (receivedAmount - amount).clamp(0.0, double.infinity);

  @override
  bool validate() => receivedAmount >= amount && amount > 0;
}

/// Pago con tarjeta de crédito o débito con voucher
class CardPaymentHandler extends PaymentMethodHandler {
  final String voucherNumber;
  final bool isCredit;

  const CardPaymentHandler({
    required super.amount,
    required this.voucherNumber,
    this.isCredit = false,
  }) : super(
          sriMethod: isCredit ? SriPaymentMethod.tarjetaCredito : SriPaymentMethod.tarjetaDebito,
        );

  @override
  bool validate() => voucherNumber.trim().isNotEmpty && amount > 0;
}

/// Pago mediante transferencia bancaria verificada
class TransferPaymentHandler extends PaymentMethodHandler {
  final String bankName;
  final String transactionReference;

  const TransferPaymentHandler({
    required super.amount,
    required this.bankName,
    required this.transactionReference,
  }) : super(sriMethod: SriPaymentMethod.transferencia);

  @override
  bool validate() => transactionReference.trim().isNotEmpty && amount > 0;
}
