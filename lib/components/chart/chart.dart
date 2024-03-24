import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/chart/chart_bar.dart';

class Chart extends StatelessWidget {
  List<PieChartSectionData> pieChartData;

  Chart({super.key, required this.pieChartData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: pieChartData.map(
            (tr) {
              return Flexible(
                fit: FlexFit.tight,
                child: ChartBar(
                    label: tr.title.toString(),
                    value: double.tryParse(tr.value.toString()),
                    pecentage: 0.1),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
