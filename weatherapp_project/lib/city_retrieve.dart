import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<CityRetrieve> fetchCityRetrieve(String country) async {
  final response = await http.get(Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$country&count=10&language=en&format=json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return CityRetrieve.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load CityRetrieve');
  }
}

class CityRetrieve {
  final List<dynamic> results;

  const CityRetrieve({
    required this.results,
  });

  factory CityRetrieve.fromJson(Map<String, dynamic> json) {
    return CityRetrieve(
      results: json['results'],
    );
  }

  List<List<String>>extractCityNames() {
    List<List<String>> infoCities = [];

    for (final result in results) {
      final String cityName = result['name'];
      final String regionName = result['admin1'];
      final String countryName = result['country'];
      final String latitude = result['latitude'].toString();
      final String longitude = result['longitude'].toString();
      infoCities.add([cityName, regionName, countryName, latitude, longitude]);
    }

    return infoCities;
  }
}
