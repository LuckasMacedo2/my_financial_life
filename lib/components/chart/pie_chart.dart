import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartComponent extends StatefulWidget {
  final List<PieChartSectionData> pieChartData;
  final Function(List<PieChartSectionData>)? onChartTapped;

  PieChartComponent({required this.pieChartData, this.onChartTapped});

  @override
  _PieChartComponentState createState() => _PieChartComponentState();
}

class _PieChartComponentState extends State<PieChartComponent> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: PieChart(
        PieChartData(
          sections: widget.pieChartData,
        ),
      ),
    );
  }
}
