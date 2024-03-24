import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/chart/chart_bar.dart';

class Chart extends StatelessWidget {
  List<PieChartSectionData> pieChartData;

  Chart({super.key, required this.pieChartData});

  double _sumValues() {
    double sum = 0.0;
    pieChartData.forEach((p) {
      sum += p.value;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    double sum = _sumValues();
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
                  label: '${tr.title.toString()}',
                  subLabel:  '${((tr.value / sum)*100).toStringAsFixed(2)}%',
                  value: double.tryParse(tr.value.toString()),
                  percentage: tr.value / sum,
                  color: tr.color,
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
