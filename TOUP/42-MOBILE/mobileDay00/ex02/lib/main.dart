import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> buttonsLabel = [
    '7',
    '8',
    '9',
    'C',
    'AC',
    '4',
    '5',
    '6',
    '+',
    '-',
    '1',
    '2',
    '3',
    'x',
    '/',
    '0',
    '.',
    '00',
    '=',
    '',
  ];

  @override
  Widget build(BuildContext context) {
    ElevatedButton createButton(
        ButtonStyle bttnstyle, String function, TextStyle txtStyle) {
      return ElevatedButton(
        style: bttnstyle,
        onPressed: () => {debugPrint(function)},
        child: Text(
          function,
          style: txtStyle,
        ),
      );
    }

    var sizeScreen = MediaQuery.of(context).size;

    /* 24 is for notification bar on Android */
    final double itemHeight = (((sizeScreen.height - kToolbarHeight - 24))) / 3.05;
    final double itemWidth = sizeScreen.width / 2;

    var textCalcInput = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: sizeScreen.height * 0.06,
      color: const Color.fromARGB(255, 125, 125, 125),
    );

    var textCalcOutput = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: sizeScreen.height * 0.12,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    var textOptionStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: sizeScreen.height * 0.03,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    var buttonShapeStyle = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll<Color>(Colors.black12),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black12)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            width: sizeScreen.width,
            height: (sizeScreen.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight) * 0.5,
            color: Colors.grey[200],
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                '0',
                style: textCalcInput,
              ),
              Text(
                '0',
                style: textCalcOutput,
              ),
            ]),
          ),
          SizedBox(
            width: sizeScreen.width,
            height: (sizeScreen.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight) * 0.5,
            child: GridView(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: (itemWidth / itemHeight),
                crossAxisCount: 5,
              ),
              children: [
                for (var label in buttonsLabel)
                  createButton(buttonShapeStyle, label, textOptionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
