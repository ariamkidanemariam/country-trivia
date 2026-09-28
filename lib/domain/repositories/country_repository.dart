import '../entities/country.dart';

abstract class CountryRepository {
  Future<List<Country>> getCountries();
  Future<List<String>> getSolvedCountryCodes();
  Future<void> saveSolvedCountryCode(String code);
  Future<int> getTotalPoints();
  Future<void> saveTotalPoints(int points);
  Future<void> resetProgress();
}
