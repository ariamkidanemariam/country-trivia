class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://restcountries.com';
  static const String allCountriesEndpoint = '/v2/all';
  static const String allCountriesUrl = '$baseUrl$allCountriesEndpoint';

  static String flagUrl(String alpha2Code) =>
      'https://flagcdn.com/w320/${alpha2Code.toLowerCase()}.png';
}
