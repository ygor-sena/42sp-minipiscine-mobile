import 'package:flutter/material.dart';

void main() => runApp(const MyWeatherApp());

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

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

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
  
  String location = '';

  @override
  Widget build(BuildContext context) {
    var pageTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: MediaQuery.of(context).size.height * 0.06,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    void printSearchLocation() {
      setState(() {
        location = myController.text;
        debugPrint(location);
      });
    }

    void printGeoLocation() {
      setState(() {
        location = "Geolocation";
        debugPrint(location);
      });
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          leading: IconButton(
            onPressed: printSearchLocation,
            icon: const Icon(Icons.search),
          ),
          title: TextField(
            controller: myController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search location...',
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
              child: Text(
                "Currently\n$location",
                style: pageTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "Today\n$location",
                style: pageTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "Weekly\n$location",
                style: pageTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
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
