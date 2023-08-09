import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<CityAPI> fetchCityRetrieve(String country) async {
  final response = await http.get(Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$country&count=10&language=en&format=json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return CityAPI.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load CityRetrieve');
  }
}

class CityAPI {
  List<Results>? results;
  double? generationtimeMs;

  CityAPI({this.results, this.generationtimeMs});

  CityAPI.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
    generationtimeMs = json['generationtime_ms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    data['generationtime_ms'] = this.generationtimeMs;
    return data;
  }
}

class Results {
  String? name;
  double? latitude;
  double? longitude;
  String? country;
  String? admin1;
  String? timezone;


  Results(
      {
      this.name,
      this.latitude,
      this.longitude,
      this.country,
      this.admin1,
      this.timezone});

  Results.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    country = json['country'];
    admin1 = json['admin1'];
    timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['country'] = this.country;
    data['admin1'] = this.admin1;
    data['timezone'] = this.timezone;
    return data;
  }
}
