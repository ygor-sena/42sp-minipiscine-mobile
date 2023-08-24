import 'package:math_expressions/math_expressions.dart';
import 'package:function_tree/function_tree.dart';

class CalculatorModel {
  String userInput;
  num result;

  CalculatorModel({this.userInput = '0', this.result = 0});

  String get getUserInput => userInput;
  num get getResult => result;

  void setUserInput(String userInput) {
    this.userInput = userInput;
  }

  void setResult(num result) {
    this.result = result;
  }

  void addToUserInput(String input) {
    userInput += input;
  }

  void equalPressed() {
    Parser p = Parser();
    Expression exp = p.parse(userInput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    setResult(eval.toString().interpret());
  }
}
