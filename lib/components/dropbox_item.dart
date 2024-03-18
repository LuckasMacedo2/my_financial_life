import 'package:flutter/material.dart';

class CategoryDropdownItem extends StatelessWidget {
  final Color color;
  final String name;

  CategoryDropdownItem({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(name),
        ],
      ),
    );
  }
}
