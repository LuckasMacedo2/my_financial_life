import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:my_financial_life/utils/formatter.dart';

class ChartBar extends StatelessWidget {
  final String? label;
  final String? subLabel;
  final double? value;
  final double? percentage;
  final Color? color;

  ChartBar({this.label, this.subLabel, this.value, this.percentage, this.color});

  @override
  Widget build(BuildContext context) {
    const int MAX_HEIGHT_CHART = 100;
    return Column(
      children: <Widget>[
        Container(
          height: MAX_HEIGHT_CHART * 0.15,
          child: FittedBox(
            child: Text('${Formatter().formatMoney(value!)}'),
          ),
        ),
        SizedBox(
          height: MAX_HEIGHT_CHART * 0.05,
        ),
        Container(
          height: MAX_HEIGHT_CHART * 0.6,
          width: 10,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: Color.fromRGBO(220, 220, 220, 1),
                    borderRadius: BorderRadius.circular(5)),
              ),
              FractionallySizedBox(
                heightFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MAX_HEIGHT_CHART * 0.05,
        ),
        FittedBox(
          child: Text('${label!}'),
        ),
        SizedBox(
          height: MAX_HEIGHT_CHART * 0.05,
        ),
        FittedBox(
          child: Text('${subLabel!}'),
        ),
      ],
    );
  }
}
