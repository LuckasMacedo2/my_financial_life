import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
  Color color = Colors.blue.shade900;
  final Function(Color) onColorSelected;

  ColorPickerDialog({Key? key, this.color =Colors.blue, required this.onColorSelected}) : super(key: key);
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.color;
  }

  void _openColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecione a cor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (Color color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedColor);
                widget.onColorSelected(_selectedColor);
              },
              child: Text(
                'Selecionar',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SIZE_SELECT_COLOR = 75.0;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CircleAvatar(
        backgroundColor: _selectedColor,
        radius: SIZE_SELECT_COLOR,
        child: IconButton(
          icon: Icon(
            Icons.color_lens,
            size: SIZE_SELECT_COLOR,
          ),
          onPressed: () {
            _openColorPickerDialog();
          },
        ),
      ),
    );
  }
}
