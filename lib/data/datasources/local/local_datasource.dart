import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/errors/exceptions.dart';

abstract class LocalDataSource {
  Future<List<String>> getSolvedCountryCodes();
  Future<void> saveSolvedCountryCode(String code);
  Future<int> getTotalPoints();
  Future<void> saveTotalPoints(int points);
  Future<void> clearAll();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences prefs;

  LocalDataSourceImpl({required this.prefs});

  @override
  Future<List<String>> getSolvedCountryCodes() async {
    try {
      return prefs.getStringList(StorageConstants.solvedCountryCodesKey) ?? [];
    } catch (e) {
      throw CacheException('Failed to get solved country codes: $e');
    }
  }

  @override
  Future<void> saveSolvedCountryCode(String code) async {
    try {
      final codes = await getSolvedCountryCodes();
      if (!codes.contains(code)) {
        codes.add(code);
        await prefs.setStringList(
          StorageConstants.solvedCountryCodesKey,
          codes,
        );
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to save solved country code: $e');
    }
  }

  @override
  Future<int> getTotalPoints() async {
    try {
      return prefs.getInt(StorageConstants.totalPointsKey) ?? 0;
    } catch (e) {
      throw CacheException('Failed to get total points: $e');
    }
  }

  @override
  Future<void> saveTotalPoints(int points) async {
    try {
      await prefs.setInt(StorageConstants.totalPointsKey, points);
    } catch (e) {
      throw CacheException('Failed to save total points: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await prefs.remove(StorageConstants.solvedCountryCodesKey);
      await prefs.remove(StorageConstants.totalPointsKey);
    } catch (e) {
      throw CacheException('Failed to clear local data: $e');
    }
  }
}
