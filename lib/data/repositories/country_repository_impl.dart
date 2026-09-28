import '../../domain/entities/country.dart';
import '../../domain/repositories/country_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/country_remote_datasource.dart';

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  List<Country>? _cachedCountries;

  CountryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Country>> getCountries() async {
    if (_cachedCountries != null) {
      return _cachedCountries!;
    }
    final countries = await remoteDataSource.getAllCountries();
    _cachedCountries = countries;
    return countries;
  }

  @override
  Future<List<String>> getSolvedCountryCodes() {
    return localDataSource.getSolvedCountryCodes();
  }

  @override
  Future<void> saveSolvedCountryCode(String code) {
    return localDataSource.saveSolvedCountryCode(code);
  }

  @override
  Future<int> getTotalPoints() {
    return localDataSource.getTotalPoints();
  }

  @override
  Future<void> saveTotalPoints(int points) {
    return localDataSource.saveTotalPoints(points);
  }

  @override
  Future<void> resetProgress() {
    _cachedCountries = null;
    return localDataSource.clearAll();
  }
}
