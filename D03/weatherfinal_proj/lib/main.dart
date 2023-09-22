///import 'dart:js_interop';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'tab/weather_api.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'city_retrieve.dart';

import 'weekly_chart.dart';

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

  /* First API Call: GeoLocator */
  String location = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String country = '';
  String region = '';
  String timezone = '';

  String geoLocationOutput = '';
  Position? currentCityGPS;

  /* Second API Call: WeatherForecast API */
  String temperature = '';
  String weatherCode = '';
  String windSpeed = '';

  String time = '';
  String temperature2m = '';
  String windspeed10m = '';

  List<List<String>> hourlyDataList = [];
  List<List<String>> dailyDataList = [];

  /* Error handle */
  String errMsgNoInternet = "Can't connect to API. Without internet connection";
  String errMsgWrongParam =
      "Can't retrieve API data. Wrong parameters passed to API";

  void resetVariables() {
    setState(() {
      location = '';
      latitude = 0.0;
      longitude = 0.0;
      country = '';
      region = '';
      timezone = '';

      geoLocationOutput = '';

      /* Second API Call: WeatherForecast API */
      temperature = '';
      weatherCode = '';
      windSpeed = '';

      time = '';
      temperature2m = '';
      windspeed10m = '';

      dailyDataList = [];
      hourlyDataList = [];
    });
  }

  Future<List<List<Object?>>> fetchCitySuggestions(String pattern) async {
    try {
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$pattern&count=5&language=en&format=json'));

      if (response.statusCode == 200) {
        final cityAPI = CityAPI.fromJson(jsonDecode(response.body));
        return cityAPI.results!
            .map((cityInfo) => [
                  cityInfo.name ?? 'N/A',
                  cityInfo.admin1 ?? 'N/A',
                  cityInfo.country ?? 'N/A',
                  cityInfo.latitude,
                  cityInfo.longitude,
                  cityInfo.timezone,
                ])
            .toList();
      } else {
        setState(() {
          resetVariables();
          location = 'No API connection';
        });
        return []; // Handle error if necessary
      }
    } catch (e) {
      setState(() {
        resetVariables();
        location = 'No internet connection';
      });
      return [];
    }
  }

  Future<WeatherAPI?> fetchWeather(double latitude, double longitude) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=${latitude.toString()}&longitude=${longitude.toString()}&hourly=temperature_2m,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min&current_weather=true&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return WeatherAPI.fromJson(jsonResponse);
    } else {
      // Handle error if necessary
      return null;
    }
  }

  Future<void> getCityFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentCityGPS!.latitude, currentCityGPS!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        location = place.locality ?? 'N/A';
        region = place.subAdministrativeArea ?? 'N/A';
        country = place.country ?? 'N/A';
        latitude = currentCityGPS!.latitude;
        longitude = currentCityGPS!.longitude;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  List<Row> createRowData(List<List<String>> hourlyDataList) {
    List<Row> rows = [];

    for (List<String> hourlyData in hourlyDataList) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(hourlyData[0]),
          Text(hourlyData[1]),
          AutoSizeText(hourlyData[2]),
          Text(hourlyData[3]),
        ],
      ));
    }
    return rows;
  }

  List<Row> createWeeklyRowData(List<List<String>> dailyDataList) {
    List<Row> rows = [];

    for (List<String> weeklyData in dailyDataList) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(weeklyData[0]),
          Text(weeklyData[1]),
          Text(weeklyData[2]),
          AutoSizeText(weeklyData[3]),
        ],
      ));
    }
    return rows;
  }

  final weatherDescriptions = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Fog',
    48: 'Fog',
    51: 'Drizzle',
    53: 'Drizzle',
    55: 'Drizzle',
    56: 'Freezing Drizzle',
    57: 'Freezing Drizzle:',
    61: 'Rain',
    63: 'Rain',
    65: 'Rain',
    66: 'Freezing Rain',
    67: 'Freezing Rain',
    71: 'Snow fall',
    73: 'Snow fall',
    75: 'Snow fall',
    77: 'Snow grains',
    80: 'Rain showers',
    81: 'Rain showers',
    82: 'Rain showers',
    85: 'Snow showers',
    86: 'Snow showers',
    95: 'Thunderstorm',
    96: 'Thunderstorm',
    99: 'Thunderstorm',
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
        resetVariables();
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
          resetVariables();
          location = 'Location permissions are denied';
        });
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        resetVariables();
        location =
            'Location permissions are permanently denied, we cannot request permissions';
      });
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      setState(() {
        resetVariables();
        location =
            'Geolocation is not enabled. Please, enable it in your App Settings';
      });
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() => currentCityGPS = position);
        getCityFromLatLng(currentCityGPS!);
      }).catchError((e) {
        debugPrint(e);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    void printGeoLocation() async {
      setState(() {
        _getCurrentPosition();
        //location = geoLocationOutput;

        debugPrint('Latitude of GPS: ${latitude.toString()}');
        debugPrint('Longitude of GPS: ${longitude.toString()}');
        debugPrint('City of GPS: $location');
      });

      if (latitude != 0.0 && longitude != 0.0)
      {
        WeatherAPI? currentlyTabAPI = await fetchWeather(latitude, longitude);
        double? temperature1 = currentlyTabAPI?.currentWeather?.temperature;
        int? weatherCode1 = currentlyTabAPI?.currentWeather?.weathercode;
        double? windSpeed1 = currentlyTabAPI?.currentWeather?.windspeed;

        setState(() {
          temperature = '${temperature1.toString()}°';
          weatherCode =
              getDescriptionFromValue(weatherCode1, weatherDescriptions);
          windSpeed = '${windSpeed1.toString()} km/h';

          debugPrint('Time: $time');
          debugPrint('Temperature: $temperature2m');
          debugPrint('Weather Code: $weatherCode');
          debugPrint('Windspeed: $windspeed10m');

          hourlyDataList.clear();
          dailyDataList.clear();

          for (int i = 0; i < 24; i++) {
            String time = currentlyTabAPI!.hourly!.time![i].split('T')[1];
            String temperature2m =
                '${currentlyTabAPI.hourly!.temperature2m![i].toString()}°';
            String weatherCode = getDescriptionFromValue(
                currentlyTabAPI.hourly!.weathercode![i], weatherDescriptions);
            String windspeed10m =
                '${currentlyTabAPI.hourly!.windspeed10m![i].toString()} km/h';
            hourlyDataList.add([time, temperature2m, weatherCode, windspeed10m]);
          }

          for (int i = 0; i < 7; i++) {
            String time = currentlyTabAPI!.daily!.time![i].split('T')[0];
            String temperature2mMin =
                '${currentlyTabAPI.daily!.temperature2mMin![i].toString()}°';
            String temperature2mMax =
                '${currentlyTabAPI.daily!.temperature2mMax![i].toString()}°';
            String weatherCode = getDescriptionFromValue(
                currentlyTabAPI.daily!.weathercode![i], weatherDescriptions);
            dailyDataList.add([
              time,
              temperature2mMin,
              temperature2mMax,
              weatherCode,
            ]);
          }
        });  
      }
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[50],
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
                title: Text(suggestion[0]),
                subtitle: Text(suggestion[1] + ', ' + suggestion[2]),
              );
            },
            onSuggestionSelected: (suggestion) async {
              setState(() {
                location = suggestion[0];
                region = suggestion[1];
                country = suggestion[2];
                latitude = suggestion[3];
                longitude = suggestion[4];
                timezone = suggestion[5];
              });

              WeatherAPI? currentlyTabAPI =
                  await fetchWeather(suggestion[3], suggestion[4]);
              double? temperature1 =
                  currentlyTabAPI?.currentWeather?.temperature;
              int? weatherCode1 = currentlyTabAPI?.currentWeather?.weathercode;
              double? windSpeed1 = currentlyTabAPI?.currentWeather?.windspeed;

              setState(() {
                temperature = '${temperature1.toString()}°';
                weatherCode =
                    getDescriptionFromValue(weatherCode1, weatherDescriptions);
                windSpeed = '${windSpeed1.toString()} km/h';

                debugPrint('Time: $time');
                debugPrint('Temperature: $temperature2m');
                debugPrint('Weather Code: $weatherCode');
                debugPrint('Windspeed: $windspeed10m');

                hourlyDataList.clear();
                dailyDataList.clear();

                for (int i = 0; i < 24; i++) {
                  String time = currentlyTabAPI!.hourly!.time![i].split('T')[1];
                  String temperature2m =
                      '${currentlyTabAPI.hourly!.temperature2m![i].toString()}°';
                  String weatherCode = getDescriptionFromValue(
                      currentlyTabAPI.hourly!.weathercode![i],
                      weatherDescriptions);
                  String windspeed10m =
                      '${currentlyTabAPI.hourly!.windspeed10m![i].toString()} km/h';
                  hourlyDataList
                      .add([time, temperature2m, weatherCode, windspeed10m]);
                }

                for (int i = 0; i < 7; i++) {
                  String time = currentlyTabAPI!.daily!.time![i].split('T')[0];
                  String temperature2mMin =
                      '${currentlyTabAPI.daily!.temperature2mMin![i].toString()}°';
                  String temperature2mMax =
                      '${currentlyTabAPI.daily!.temperature2mMax![i].toString()}°';
                  String weatherCode = getDescriptionFromValue(
                      currentlyTabAPI.daily!.weathercode![i],
                      weatherDescriptions);
                  dailyDataList.add([
                    time,
                    temperature2mMin,
                    temperature2mMax,
                    weatherCode,
                  ]);
                }
                for (List<String> hourlyData in hourlyDataList) {
                  String time = hourlyData[0];
                  String temperature2m = hourlyData[1];
                  String weatherCode = hourlyData[2];
                  String windspeed10m = hourlyData[3];

                  debugPrint('Time: $time');
                  debugPrint('Temperature: $temperature2m');
                  debugPrint('Weather Code: $weatherCode');
                  debugPrint('Windspeed: $windspeed10m');
                }
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
                    resetVariables();
                    location = '';
                  });
                  "Currently\n$location\n$region\n$country";
                }
                List<List<Object?>> call = await fetchCitySuggestions(pattern);
                if (call.isEmpty) {
                  setState(() {
                    resetVariables();
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
              icon: const Icon(Icons.gps_fixed_sharp),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_sky_2.jpg'),
              fit: BoxFit.cover,
              opacity: 900.0,
            ),
          ),
          child: TabBarView(
            children: <Widget>[
              Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        location,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.035,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      Text(
                        "$region\n$country\n",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      Text(
                        temperature,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.08,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      Text(
                        '$weatherCode\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height * 0.035,
                          color: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (windSpeed != '')
                            const Icon(Icons.wind_power_rounded),
                          Text(
                            ' $windSpeed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02,
                              color: const Color.fromRGBO(0, 0, 0, 1),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.035,
                            color: const Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        Text(
                          "$region\n$country\n",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: const Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        Text(
                          "\nTouch the graph to see the temperature throughout the day",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.013,
                            color: const Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.05,
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.05,
                              bottom: MediaQuery.of(context).size.width * 0.05),
                          child: ChartExampleToday(hourlyDataList),
                        ),
                        //Create a horizontal scrollable list for hourlyDataLista=
                        Container(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05),
                          height: MediaQuery.of(context).size.height * 0.25,
                          alignment: Alignment.center,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourlyDataList.length,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                  '${hourlyDataList[index][0]}\n'),
                                              Text(
                                                hourlyDataList[index][1],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.035,
                                                  color: const Color.fromRGBO(
                                                      0, 0, 0, 1),
                                                ),
                                              ),
                                              Wrap(
                                                direction: Axis.vertical,
                                                children: [
                                                  Text(
                                                    '${hourlyDataList[index][2]}\n',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.02,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                      Icons.wind_power_rounded),
                                                  Text(
                                                    ' ${hourlyDataList[index][3]}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ]),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(children: [
                    Text(
                      location,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height * 0.035,
                        color: const Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    Text(
                      "$region\n$country\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        color: const Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    Text(
                      "\nTouch the graph to see the temperature throughout the week",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.013,
                        color: const Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.05,
                          left: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.05,
                          bottom: MediaQuery.of(context).size.width * 0.05),
                      child: ChartExampleWeekly(dailyDataList),
                    ),
                    //Create a horizontal scrollable list for hourlyDataLista=
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.05),
                      height: MediaQuery.of(context).size.height * 0.25,
                      alignment: Alignment.center,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dailyDataList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text('${dailyDataList[index][0]}\n'),
                                        Text(
                                          dailyDataList[index][2],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.035,
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 1),
                                          ),
                                        ),
                                        Wrap(
                                          direction: Axis.vertical,
                                          children: [
                                            Text(
                                              '${dailyDataList[index][1]}\n',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.info_outline),
                                            Text(
                                              ' ${dailyDataList[index][3]}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color:
                                                    Color.fromRGBO(0, 0, 0, 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
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
