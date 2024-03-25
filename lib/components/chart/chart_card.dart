import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial_life/components/chart/chart.dart';
import 'package:my_financial_life/components/chart/pie_chart.dart';
import 'package:my_financial_life/components/picker/date_picker.dart';
import 'package:my_financial_life/models/filters/filter.dart';
import 'package:my_financial_life/utils/formatter.dart';

class ChartCard extends StatefulWidget {
  ChartCard({
    super.key,
    required this.pieChartData,
    required this.filter,
    required this.route,
    required this.total,
    required this.search,
    required this.title
  });

  Filter filter;
  String route;
  String title;
  double total;
  final List<PieChartSectionData> pieChartData;

  final Function(DateTime, DateTime) search;

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  DateTime _selectedInitialDate = DateTime.now();
  DateTime _selectedFinalDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedInitialDate = widget.filter.startDate!;
    _selectedFinalDate = widget.filter.finalDate!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            widget.title,
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
          ),
        ),
        widget.pieChartData.length == 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Nenhum dado registrado'),
              )
            : Column(
                children: [
                  PieChartComponent(
                    pieChartData: widget.pieChartData,
                  ),
                  Chart(pieChartData: widget.pieChartData, sum: widget.total),
                ],
              ),
        SizedBox(
          height: 20,
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumo dos dados'),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        //'Período: ${DateFormat('dd/MM/yyyy').format(filter.startDate! ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(filter.finalDate! ?? DateTime.now())}'),
                        'Período: ',
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      DatePicker(
                        initialDate: _selectedInitialDate,
                        onDateSelected: (DateTime date) {
                          setState(
                            () {
                              _selectedInitialDate = date;
                            },
                          );
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      DatePicker(
                        initialDate: _selectedFinalDate,
                        onDateSelected: (DateTime date) {
                          setState(
                            () {
                              _selectedFinalDate = date;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Total: ${Formatter().formatMoney(widget.total)}'),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(widget.route);
                },
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => widget.search(
              _selectedInitialDate,
              _selectedFinalDate,
            ),
            icon: Icon(Icons.search),
            label: Text('Pesquisar'),
          ),
        ),
      ],
    );
  }
}
