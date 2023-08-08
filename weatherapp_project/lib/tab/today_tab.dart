import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TodayTab extends StatelessWidget {
  final String userLocation;
  final TextStyle textStyle;
  const TodayTab(
      {Key? key, required this.userLocation, required this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AutoSizeText(
        "Today\n$userLocation",
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }
}
