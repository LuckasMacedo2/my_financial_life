import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();

  final Function(DateTime) onDateSelected;
  DatePicker({Key? key, required this.onDateSelected}) : super(key: key);
}

class _DatePickerState extends State<DatePicker> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(
        () {
          selectedDate = picked;
          widget.onDateSelected(selectedDate);
        },
      );
  }

  @override
  void initState() {
    super.initState();
    // Inicialize o formato de data para o idioma desejado
    initializeDateFormatting('pt_BR', null);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMd('pt_BR')
        .format(selectedDate); // Utilizando o formato pt_BR
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(formattedDate),
          SizedBox(width: 3.0),
          ElevatedButton.icon(
            icon: Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
            label: Text('Data'),
          ),
        ],
      ),
    );
  }
}
