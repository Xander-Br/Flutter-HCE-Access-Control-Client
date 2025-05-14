import 'dart:convert'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicpa/src/core/services/secure_storage_service.dart';
import 'package:sicpa/src/features/access_card/models/totp_model.dart';

class TotpRepository {
  final SecureStorageService _secureStorageService;

  TotpRepository(this._secureStorageService);

 
  static const String _totpKeyPrefix = 'totp_';

  
  Future<void> saveTotp(TotpModel totp) async {
    final String key = '$_totpKeyPrefix${totp.id}';
    final String totpJsonString = jsonEncode(totp.toJson());
    await _secureStorageService.write(key, totpJsonString);
  }

  
  Future<TotpModel?> getTotp(String id) async {
    final String key = '$_totpKeyPrefix$id';
    final String? totpJsonString = await _secureStorageService.read(key);

    if (totpJsonString != null && totpJsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(totpJsonString);
        return TotpModel.fromJson(jsonMap);
      } catch (e) {
        print('Error decoding TOTP from JSON for ID $id: $e');
       
        return null;
      }
    }
    return null;
  }

  Future<void> deleteTotp(String id) async {
    final String key = '$_totpKeyPrefix$id';
    await _secureStorageService.delete(key);
  }

 
  Future<List<TotpModel>> getAllTotps() async {
    final allStoredItems = await _secureStorageService.readAll();
    final List<TotpModel> totpList = [];

    allStoredItems.forEach((key, value) {
      if (key.startsWith(_totpKeyPrefix)) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(value);
          totpList.add(TotpModel.fromJson(jsonMap));
        } catch (e) {
          print('Error decoding TOTP from JSON for key $key (value: "$value"): $e');
          
          if (!value.startsWith('{')) { // Basic check if it's not a JSON object string
            try {
              final String idFromKey = key.substring(_totpKeyPrefix.length);
              print('Attempting migration for key $key: Treating value as raw URI.');
              totpList.add(TotpModel.fromUri(value, existingId: idFromKey));
            } catch (migrationError) {
              print('Migration failed for key $key: $migrationError');
            }
          }
        }
      }
    });
    return totpList;
  }
}


final totpRepositoryProvider = Provider<TotpRepository>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return TotpRepository(secureStorage);
});


