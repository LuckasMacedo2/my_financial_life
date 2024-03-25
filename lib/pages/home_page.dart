import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/chart/chart.dart';
import 'package:my_financial_life/components/chart/chart_card.dart';
import 'package:my_financial_life/components/chart/pie_chart.dart';
import 'package:my_financial_life/models/filters/filter.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_header.dart';
import 'package:my_financial_life/services/earning_service.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  List<PieChartSectionData> pieChartDataPurchases = [];
  List<PieChartSectionData> pieChartDataEarning = [];

  Filter? _filterPurchase = Filter(
      startDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 1),
      finalDate: DateTime(DateTime.now().year, DateTime.now().month + 2, 0),
      isPaid: false);

  Filter? _filterEarning = Filter(
      startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      finalDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
      isPaid: false);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PurchaseService>(
      context,
      listen: false,
    ).loadPurchase();

    Provider.of<EarningService>(
      context,
      listen: false,
    ).loadEarnings();
  }

  double _sumValues(List<PieChartSectionData> pieChartData) {
    double sum = 0.0;
    pieChartData.forEach((p) {
      sum += p.value;
    });

    return sum;
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem vindo!'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumo dos dados',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .fontSize,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                                'Ganhos no período ${DateFormat('dd/MM/yyyy').format(widget._filterEarning!.startDate!)} - ${DateFormat('dd/MM/yyyy').format(widget._filterEarning!.finalDate!)}  ${Formatter().formatMoney(_sumValues(widget.pieChartDataEarning))}'),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                'Gastos no período ${DateFormat('dd/MM/yyyy').format(widget._filterPurchase!.startDate!)} - ${DateFormat('dd/MM/yyyy').format(widget._filterPurchase!.finalDate!)}  ${Formatter().formatMoney(_sumValues(widget.pieChartDataPurchases))}'),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Final:  ${Formatter().formatMoney(_sumValues(widget.pieChartDataEarning) - _sumValues(widget.pieChartDataPurchases))}',
                              style: TextStyle(
                                color: _sumValues(widget.pieChartDataEarning) -
                                            _sumValues(
                                                widget.pieChartDataPurchases) <
                                        0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Consumer<PurchaseService>(
                        builder:
                            (BuildContext context, provider, Widget? child) {
                          return FutureBuilder(
                            future: provider
                                .getPurchasesSumByCategories(
                              widget._filterPurchase!,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return Text('No data available');
                              } else {
                                widget.pieChartDataPurchases = snapshot.data!;
                                return ChartCard(
                                  pieChartData: widget.pieChartDataPurchases,
                                  filter: widget._filterPurchase!,
                                  route: AppRoutes.PURCHASE_LIST,
                                  total:
                                      _sumValues(widget.pieChartDataPurchases),
                                  title: 'Compras/Dívidas',
                                  search: (initialDate, finalDate) {
                                    setState(
                                      () {
                                        widget._filterPurchase!.startDate =
                                            initialDate;
                                        widget._filterPurchase!.finalDate =
                                            finalDate;
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Consumer<EarningService>(
                        builder:
                            (BuildContext context, provider, Widget? child) {
                          return FutureBuilder(
                            future: provider.getEarningsSumByCategories(
                                widget._filterEarning!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return Text('No data available');
                              } else {
                                widget.pieChartDataEarning = snapshot.data!;
                                return ChartCard(
                                  pieChartData: widget.pieChartDataEarning,
                                  filter: widget._filterEarning!,
                                  route: AppRoutes.EARNING_LIST,
                                  title: 'Ganhos',
                                  total: _sumValues(widget.pieChartDataEarning),
                                  search: (initialDate, finalDate) {
                                    setState(() {
                                      widget._filterEarning!.startDate =
                                          initialDate;
                                      widget._filterEarning!.finalDate =
                                          finalDate;
                                    });
                                  },
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
