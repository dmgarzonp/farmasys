class SettingsState {
  final double ivaVigente;
  final int expirationAlertDays;
  final int stockMinimo;

  const SettingsState({
    this.ivaVigente = 0.15,
    this.expirationAlertDays = 30,
    this.stockMinimo = 5,
  });

  SettingsState copyWith({
    double? ivaVigente,
    int? expirationAlertDays,
    int? stockMinimo,
  }) {
    return SettingsState(
      ivaVigente: ivaVigente ?? this.ivaVigente,
      expirationAlertDays: expirationAlertDays ?? this.expirationAlertDays,
      stockMinimo: stockMinimo ?? this.stockMinimo,
    );
  }
}
