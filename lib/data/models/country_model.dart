import '../../domain/entities/country.dart';
import '../../core/constants/api_constants.dart';

class CountryModel extends Country {
  const CountryModel({
    required super.name,
    required super.alpha2Code,
    required super.flagUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final code = (json['alpha2Code'] as String).toLowerCase();
    return CountryModel(
      name: json['name'] as String,
      alpha2Code: code,
      flagUrl: ApiConstants.flagUrl(code),
    );
  }
}
