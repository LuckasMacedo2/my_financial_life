import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final Widget child;

  final Function(bool expanded) onExpandedChanged;

  FilterWidget({required this.child, required this.onExpandedChanged});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final itemsHeight = 50.0;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _expanded ? itemsHeight + 80 : 80,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less: Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                      widget.onExpandedChanged(_expanded);
                    });
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _expanded ? itemsHeight : 0,
                  child: ListView(
                  
                    children: [
                      Align(alignment: Alignment.bottomLeft, child: widget.child),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
