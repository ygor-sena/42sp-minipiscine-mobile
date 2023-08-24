import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'calc_controller.dart';

void main() {
  runApp(const MyCalculator());
}

class MyCalculator extends StatelessWidget {
  const MyCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculator'),
      debugShowCheckedModeBanner: false,
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
  //init instance of Data class
  CalculatorController controller = CalculatorController();

  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery.of(context).size;

    /* 24 is for notification bar on Android */
    final double itemHeight = (((sizeScreen.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            24)));
    final double itemWidth = sizeScreen.width / 2;

    var textCalcInput = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: sizeScreen.height * 0.06,
      color: const Color.fromARGB(255, 125, 125, 125),
    );

    var txtOperandStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: sizeScreen.height * 0.12,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    var txtOperatorStyle = TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: sizeScreen.height * 0.03,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    var txtOptionStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: sizeScreen.height * 0.03,
      color: const Color.fromARGB(255, 0, 0, 0),
    );

    var txtButtonStyle = ButtonStyle(
      backgroundColor: const MaterialStatePropertyAll<Color>(Colors.black12),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, side: BorderSide.none),
      ),
    );

    TextButton createButton(
        ButtonStyle bttnstyle, String function, TextStyle txtStyle) {
      return TextButton(
        style: bttnstyle,
        onPressed: () => setState(() {
          controller.updateInputScreen(function);
        }),
        child: AutoSizeText(
          function,
          style: txtStyle,
          maxLines: 1,
        ),
      );
    }

    double ratioPortraitLandScape() {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        return itemWidth / (itemHeight / 2.45);
      } else {
        return itemWidth / (itemHeight / 2.2);
      }
    }

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
            padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
            width: sizeScreen.width,
            height: (sizeScreen.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight) *
                0.4,
            color: Colors.grey[200],
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: AutoSizeText(
                  controller.data.getUserInput,
                  style: textCalcInput,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    controller.data.getResult.toString(),
                    style: txtOperandStyle,
                    maxLines: 1,
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(
            width: sizeScreen.width,
            height: (sizeScreen.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight) *
                0.6,
            child: Expanded(
              child: GridView(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: ratioPortraitLandScape(),
                  crossAxisCount: 5,
                ),
                children: [
                  for (var label in controller.buttonsLabel)
                    if (controller.isOperator(label))
                      createButton(txtButtonStyle, label, txtOperatorStyle)
                    else
                      createButton(txtButtonStyle, label, txtOptionStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
