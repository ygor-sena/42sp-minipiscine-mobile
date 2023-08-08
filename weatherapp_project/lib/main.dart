///import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'tab/currently_tab.dart';
import 'tab/today_tab.dart';
import 'tab/weekly_tab.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'city_retrieve.dart';

void main() => runApp(const MyWeatherApp());

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

  ///https://docs.flutter.dev/cookbook/networking/fetch-data
  ///https://medium.com/@fernnandoptr/how-to-get-users-current-location-address-in-flutter-geolocator-geocoding-be563ad6f66a
  ///https://www.fluttercampus.com/guide/189/how-to-add-autocomplete-suggestions-on-textfield-in-flutter/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const WeatherPages(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherPages extends StatefulWidget {
  const WeatherPages({super.key});
  @override
  State<WeatherPages> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<WeatherPages> {
  final myController = TextEditingController();
  String location = '';
  String latitude = '';
  String longitude = '';
  String geoLocationOutput = '';

  late Future<CityRetrieve> futureCityRetrieve;

  @override
  void initState() {
    super.initState();
    futureCityRetrieve = fetchCityRetrieve('Berlin');
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        geoLocationOutput =
            'Location services are disabled. Please enable the services';
      });
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          geoLocationOutput = 'Location permissions are denied';
        });
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        geoLocationOutput = 'Location permissions are denied';
      });
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      setState(() {
        geoLocationOutput =
            'Geolocation is not enabled. Please, enable it in your App Settings';
      });
      return;
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => {
            longitude = position.longitude.toString(),
            latitude = position.latitude.toString(),
            geoLocationOutput = '$longitude $latitude'
          });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var pageTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: MediaQuery.of(context).size.height * 0.06,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    void printSearchLocation(String test) {
      setState(() {
        location = myController.text;
      });
    }

    void printGeoLocation() {
      setState(() {
        _getCurrentPosition();
        location = geoLocationOutput;
        debugPrint(latitude);
        debugPrint(longitude);
        debugPrint(location);
      });
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: TypeAheadField(
            suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) {
                  return [];
                }

                final cityRetrieve = await fetchCityRetrieve(pattern);
                final List<List<String>> infoCities = cityRetrieve.extractCityNames();

              return infoCities.map((cityInfo) {
                final cityName = cityInfo[0];
                final regionName = cityInfo[1];
                final countryName = cityInfo[2];
                final longitude = cityInfo[3];
                final latitude = cityInfo[4];
                return '$cityName, $regionName, $countryName, $longitude, $latitude';
              }).toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {     
                final selectCity = suggestion.split(', ');
                if (selectCity.length == 5) {
                  setState(() {
                    location = suggestion;
                    latitude = selectCity[3];
                    longitude = selectCity[4];
                    location = '$latitude $longitude';
                  });
              }
            },
            textFieldConfiguration: TextFieldConfiguration(
              controller: myController,
              autofocus: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                border: OutlineInputBorder(),
                labelText: 'Search location...',
              ),
              onSubmitted: printSearchLocation,
            ),
          ),
          actions: [
            IconButton(
              onPressed: printGeoLocation,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            CurrentlyTab(userLocation: location, textStyle: pageTextStyle),
            TodayTab(userLocation: location, textStyle: pageTextStyle),
            WeeklyTab(userLocation: location, textStyle: pageTextStyle),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: <Widget>[
            Tab(
              text: 'Currently',
              icon: Icon(Icons.settings),
            ),
            Tab(
              text: 'Today',
              icon: Icon(Icons.calendar_today),
            ),
            Tab(
              text: 'Weekly',
              icon: Icon(Icons.calendar_month),
            ),
          ],
        ),
      ),
    );
  }
}
