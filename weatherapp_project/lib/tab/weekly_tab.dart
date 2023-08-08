import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WeeklyTab extends StatelessWidget {
  final String userLocation;
  final TextStyle textStyle;
  const WeeklyTab(
      {Key? key, required this.userLocation, required this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AutoSizeText(
        "Weekly\n$userLocation",
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }
}
