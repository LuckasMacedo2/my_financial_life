import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ChartBar extends StatelessWidget {

  final String? label;
  final double? value;
  final double? pecentage;

  ChartBar({this.label, this.value, this.pecentage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
        children: <Widget> [
          Container(
            height: constraints.maxHeight * 0.15,
            child: FittedBox(
              child: Text('${value!.toStringAsFixed(2)}'),
              ),
          ),
          SizedBox(height: constraints.maxHeight * 0.05,),
          Container(
            height: constraints.maxHeight * 0.6,
            width: 10,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0
                    ),
                    color: Color.fromRGBO(220, 220, 220, 1),
                    borderRadius: BorderRadius.circular(5)
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: pecentage,
                  child: Container(
                    decoration:  BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.05,),
          Container(
            height: constraints.maxHeight * 0.15,
            child: FittedBox(child: Text(label!))
            ),
        ],
      );
      }
    );
  }
}