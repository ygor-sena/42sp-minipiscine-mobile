///import 'dart:js_interop';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'tab/weather_api.dart';

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
  double latitude = 0.0;
  double longitude = 0.0;
  String country = '';
  String region = '';
  String timezone = '';

  String geoLocationOutput = '';

  String temperature = '';
  String weatherCode = '';
  String windSpeed = '';

  String time = '';
  String temperature2m = '';
  String windspeed10m = '';

  Future<List<List<Object?>>> fetchCitySuggestions(String pattern) async {
    final response = await http.get(Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$pattern&count=10&language=en&format=json'));

    if (response.statusCode == 200) {
      final cityAPI = CityAPI.fromJson(jsonDecode(response.body));
      return cityAPI.results!
          .map((cityInfo) => [
                cityInfo.name ?? 'N/A',
                cityInfo.admin1 ?? 'N/A',
                cityInfo.country ?? 'N/A',
                cityInfo.longitude,
                cityInfo.latitude,
                cityInfo.timezone,
              ])
          .toList();
    } else {
      return []; // Handle error if necessary
    }
  }

  Future<TodayTabAPI?> fetchWeather(
      double latitude, double longitude) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min,windspeed_10m_max&current_weather=true&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TodayTabAPI.fromJson(jsonResponse);
    } else {
      // Handle error if necessary
      return null;
    }
  }

  final weatherDescriptions = {
    0: 'Clear (No cloud at any level)',
    1: 'Partly cloudy (Scattered or broken)',
    2: 'Continuous layer(s) of blowing snow',
    3: 'Sandstorm, duststorm, or blowing snow',
    4: 'Fog, thick dust or haze',
    5: 'Drizzle',
    6: 'Rain',
    7: 'Snow, or rain and snow mixed',
    8: 'Shower(s)',
    9: 'Thunderstorm(s)',
  };

  String getDescriptionFromValue(int? value, Map<int, String> descriptions) {
    if (descriptions.containsKey(value)) {
      return descriptions[value]!;
    } else {
      return 'Description not found';
    }
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
        region = '';
        country = '';
        temperature = '';
        weatherCode = '';
        windSpeed = '';
      });
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          geoLocationOutput = 'Location permissions are denied';
          region = '';
          country = '';
          temperature = '';
          weatherCode = '';
          windSpeed = '';
        });
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        geoLocationOutput =
            'Location permissions are permanently denied, we cannot request permissions';
        region = '';
        country = '';
        temperature = '';
        weatherCode = '';
        windSpeed = '';
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
        region = '';
        country = '';
        temperature = '';
        weatherCode = '';
        windSpeed = '';
      });
      return;
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() =>

          ///longitude = position.longitude.toString(),
          ///latitude = position.latitude.toString(),
          geoLocationOutput = longitude.toString() + latitude.toString());

      ///geoLocationOutput = '$longitude.toString() $latitude.toString()',
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

        ///debugPrint(latitude);
        ///debugPrint(longitude);
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
              return await fetchCitySuggestions(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                //display the city name, the region and the country
                title: Text(suggestion[0] +
                    ', ' +
                    suggestion[1] +
                    ', ' +
                    suggestion[2]),
              );
            },
            onSuggestionSelected: (suggestion) async {
              TodayTabAPI? currentlyTabAPI =
                  await fetchWeather(latitude, longitude);
              double? temperature1 = currentlyTabAPI?.currentWeather!.temperature;
              int? weatherCode1 = currentlyTabAPI?.currentWeather!.weathercode;
              double? windSpeed1 = currentlyTabAPI?.currentWeather!.windspeed;

              setState(() {
                location = suggestion[0];
                region = suggestion[1];
                country = suggestion[2];
                latitude = suggestion[3];
                longitude = suggestion[4];
                timezone = suggestion[5];

                temperature = '${temperature1.toString()} °C';
                weatherCode =
                    getDescriptionFromValue(weatherCode1, weatherDescriptions);
                windSpeed = windSpeed1.toString();

                debugPrint(temperature);
                debugPrint(weatherCode);
                debugPrint(windSpeed);
                debugPrint(timezone);
              });
            },
            textFieldConfiguration: TextFieldConfiguration(
              controller: myController,
              autofocus: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                labelText: 'Search location...',
              ),
              onSubmitted: (pattern) async {
                if (pattern.isEmpty) {
                  setState(() {
                    location = '';
                  });
                  "Currently\n$location\n$region\n$country";
                }
                List<List<Object?>> call = await fetchCitySuggestions(pattern);
                if (call.isEmpty) {
                  setState(() {
                    location = 'City not found';
                  });
                } else {
                  setState(() {
                    location = call[0][0] as String;
                    latitude = call[0][3] as double;
                    longitude = call[0][4] as double;
                    location = '$latitude $longitude';
                  });
                }
              },
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
            Center(
              child: AutoSizeText(
                "Currently\n$location\n$region\n$country\n$temperature\n$weatherCode\n$windSpeed",
                style: pageTextStyle,
                textAlign: TextAlign.center,
                maxLines: 6,
              ),
            ),
            Center(
              child: AutoSizeText(
                "Currently\n$time\n$temperature2m\n$windspeed10m\n",
                style: pageTextStyle,
                textAlign: TextAlign.center,
                maxLines: 6,
              ),
            ),
            Center(
              child: AutoSizeText(
                "Currently\n$location\n$region\n$country\n",
                style: pageTextStyle,
                textAlign: TextAlign.center,
                maxLines: 6,
              ),
            ),
            /* CurrentlyTab(
                location: location,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                temperature: temperature,
                weatherCode: weatherCode,
                windSpeed: windSpeed,
                textStyle: pageTextStyle), */
            /* TodayTab(
                location: location,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                textStyle: pageTextStyle),
            WeeklyTab(
                location: location,
                region: region,
                country: country,
                latitude: latitude,
                longitude: longitude,
                textStyle: pageTextStyle), */
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
