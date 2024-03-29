import 'package:flutter/material.dart';

class FloatingSum extends StatelessWidget {
  final double deviceSize;
  final List<Widget> children;

  FloatingSum({required this.deviceSize, required this.children});

  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
    final floatingSumWidth = screenWidth * 0.8; 
    return Positioned(
      left: (screenWidth - floatingSumWidth) * 2,
      right: (screenWidth - floatingSumWidth) * 2,
      bottom: 16,
      child: Container(
        width: deviceSize / 2,
        child: Card(
          color: Theme.of(context).secondaryHeaderColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
