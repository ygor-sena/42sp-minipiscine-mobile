import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'currently_tab_api.dart';

class CurrentlyTab extends StatelessWidget {
  final String location;
  final String region;
  final String country;
  final String? temperature;
  final String? weatherCode;
  final String? windSpeed;
  final double latitude;
  final double longitude;
  final TextStyle textStyle;
  const CurrentlyTab(
      {Key? key,
      required this.location,
      required this.textStyle,
      required this.region,
      required this.country,
      required this.temperature,
      required this.weatherCode,
      required this.windSpeed,
      required this.latitude,
      required this.longitude})
      : super(key: key);

  Future<CurrentlyTabAPI?> fetchWeather(
      double latitude, double longitude) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return CurrentlyTabAPI.fromJson(jsonResponse);
    } else {
      // Handle error if necessary
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AutoSizeText(
        "Currently\n$location\n$region\n$country\n$temperature\n$weatherCode\n$windSpeed",
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }
}
