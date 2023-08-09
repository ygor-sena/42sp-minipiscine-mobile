import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WeeklyTab extends StatelessWidget {
  final String location;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final TextStyle textStyle;
  const WeeklyTab(
      {Key? key, required this.location, required this.textStyle, required this.region, required this.country, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AutoSizeText(
        "Currently\n$location\n$region\n$country",
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }
}
