import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicpa/src/features/access_card/domain/repositories/totp_repository.dart';
import 'package:sicpa/src/features/access_card/models/totp_model.dart';

class TotpListNotifier extends AsyncNotifier<List<TotpModel>> {
  @override
  FutureOr<List<TotpModel>> build() async => _fetchTotps();

  Future<List<TotpModel>> _fetchTotps() async {
    final repository = ref.read(totpRepositoryProvider);
    return await repository.getAllTotps();
  }

  Future<void> addTotp(String totpUri) async {
    final repository = ref.read(totpRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final newTotp = TotpModel.fromUri(totpUri);
      await repository.saveTotp(newTotp); 

      final currentList = await _fetchTotps();
      state = AsyncValue.data(currentList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print('Error adding TOTP: $e');
      rethrow; // Rethrow to notify the UI of the error
    }
  }

  Future<void> removeTotp(String totpId) async {
    final repository = ref.read(totpRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      await repository.deleteTotp(totpId);
      final currentList = await _fetchTotps();
      state = AsyncValue.data(currentList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print('Error removing TOTP: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTotps());
  }
}

final totpListProvider = AsyncNotifierProvider<TotpListNotifier, List<TotpModel>>(() {
  return TotpListNotifier();
});