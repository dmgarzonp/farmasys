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

    state = SettingsState(
      ivaVigente: iva,
      expirationAlertDays: exp,
      stockMinimo: stock,
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
}
