import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/country_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

abstract class CountryRemoteDataSource {
  Future<List<CountryModel>> getAllCountries();
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final http.Client client;

  CountryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CountryModel>> getAllCountries() async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.allCountriesUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => CountryModel.fromJson(json as Map<String, dynamic>))
            .where((country) =>
                country.name.isNotEmpty && country.alpha2Code.isNotEmpty)
            .toList();
      } else {
        throw ServerException(
          'Failed to fetch countries: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch countries: $e');
    }
  }
}
