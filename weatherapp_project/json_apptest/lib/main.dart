import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<CityRetrieve> fetchCityRetrieve() async {
  final response = await http.get(Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=Berlin&count=10&language=en&format=json'));

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
  final int id;
  ////final String title;

  const CityRetrieve({
    required this.results,
    required this.id,

    ///required this.title,
  });

  factory CityRetrieve.fromJson(Map<String, dynamic> json) {
    return CityRetrieve(
      results: json['results'],
      id: json['results'].length,
      ////title: json['title'],
    );
  }

  List<List<String>>extractCityNames() {
    List<List<String>> infoCities = [];

    for (final result in results) {
      final String cityName = result['name'];
      final String regionName = result['admin1'];
      final String countryName = result['country'];
      infoCities.add([cityName, regionName, countryName]);
    }

    return infoCities;
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<CityRetrieve> futureCityRetrieve;

  @override
  void initState() {
    super.initState();
    futureCityRetrieve = fetchCityRetrieve();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<CityRetrieve>(
            future: futureCityRetrieve,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<List<String>> infoCities = snapshot.data!.extractCityNames();

                return ListView.builder(
                  itemCount: infoCities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(infoCities[index][0]),
                      subtitle: Text(infoCities[index][1] + ', ' + infoCities[index][2]),
                    );
                  },
                );
                ////return Text(snapshot.data!.results.toString());
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
