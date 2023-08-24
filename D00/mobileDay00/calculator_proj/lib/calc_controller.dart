import 'package:flutter/cupertino.dart';
import 'calc_model.dart';

class CalculatorController {
  //init instance of Data class
  CalculatorModel data = CalculatorModel();

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

  void updateInputScreen(String input) {
    switch (input) {
      case 'AC':
        data = CalculatorModel();
        break;
      case 'C':
        data.setUserInput(
            data.getUserInput.substring(0, data.getUserInput.length - 1));
        if (data.getUserInput.isEmpty) {
          data.setUserInput('0');
        }
        debugPrint(data.getUserInput);
        break;
      case 'x':
        data.addToUserInput('*');
        debugPrint(data.getUserInput);
        break;
      case '=':
        data.equalPressed();
        debugPrint(data.getResult.toString());
        break;
      default:
        if (data.getUserInput.length == 1 &&
            data.getUserInput == '0' &&
            input != '') {
          data.setUserInput('');
        }
        data.addToUserInput(input);
        debugPrint(data.getUserInput);
        break;
    }
  }

  bool isOperator(String input) {
    List<String> values = ['C', 'AC', '+', '-', 'x', '/', '=', ''];
    return values.contains(input);
  }
}
