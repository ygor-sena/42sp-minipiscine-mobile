import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D00: ex01',
      theme: ThemeData(),
      home: const MyHomePage(title: 'D00: ex01'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _titleTextField = "A sample text";

  void _changeTextField() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      if (_titleTextField == "Hello World!") {
        _titleTextField = "A sample text";
        debugPrint(_titleTextField);
      } else {
        _titleTextField = "Hello World!";
        debugPrint(_titleTextField);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    const titleTextStyle = TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.only(bottom: 5.0),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                _titleTextField,
                textAlign: TextAlign.center,
                style: titleTextStyle,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll<Color>(Colors.white70),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.white70)),
                ),
              ),
              onPressed: _changeTextField,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Click me',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(46, 125, 50, 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
