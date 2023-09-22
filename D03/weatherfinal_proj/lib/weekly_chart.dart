
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartExampleWeekly extends StatelessWidget {
  final List<List<String>> hourlyDataList; // Your data goes here

  //Create constructor Chartexample
  ChartExampleWeekly(this.hourlyDataList);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 45,
            // Adjust this based on your data range
            lineBarsData: [
              LineChartBarData(
                spots: hourlyDataList
                    .asMap()
                    .map((index, data) => MapEntry(
                          index.toDouble(),
                          FlSpot(index.toDouble(),
                              double.parse(data[1].split('°')[0])),
                        ))
                    .values
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: hourlyDataList
                    .asMap()
                    .map((index, data) => MapEntry(
                          index.toDouble(),
                          FlSpot(index.toDouble(),
                              double.parse(data[2].split('°')[0])),
                        ))
                    .values
                    .toList(),
                isCurved: true,
                color: Colors.red,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      );
  }
}

class ChartExampleToday extends StatelessWidget {
  final List<List<String>> hourlyDataList; // Your data goes here

  //Create constructor Chartexample
  ChartExampleToday(this.hourlyDataList);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 23,
            minY: 0,
            maxY: 45,
            // Adjust this based on your data range
            lineBarsData: [
              LineChartBarData(
                spots: hourlyDataList
                    .asMap()
                    .map((index, data) => MapEntry(
                          index.toDouble(),
                          FlSpot(index.toDouble(),
                              double.parse(data[1].split('°')[0])),
                        ))
                    .values
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      );
  }
}