import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/chart/chart.dart';
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
  List<PieChartSectionData> pieChartDataPurchases = [];
  List<PieChartSectionData> pieChartDataEarning = [];

  @override
  void initState() {
    super.initState();
    Provider.of<PurchaseService>(
      context,
      listen: false,
    ).loadPurchase();
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
                      Text(
                        'Teste',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Consumer<PurchaseService>(
                        builder:
                            (BuildContext context, provider, Widget? child) {
                          return FutureBuilder(
                            future: provider.getPurchasesSumByCategories(
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
                                pieChartDataPurchases = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Contas/Dívidas',
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .fontSize),
                                      ),
                                    ),
                                    pieChartDataPurchases.length == 0
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text('Nenhum dado registrado'),
                                          )
                                        : Column(
                                            children: [
                                              PieChartComponent(
                                                pieChartData:
                                                    pieChartDataPurchases,
                                              ),
                                              Chart(
                                                  pieChartData:
                                                      pieChartDataPurchases,
                                                  sum: _sumValues(
                                                      pieChartDataPurchases)),
                                            ],
                                          ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Resumo dos dados'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  'Período: ${DateFormat('dd/MM/yyyy').format(widget._filterPurchase?.startDate! ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(widget._filterPurchase?.finalDate! ?? DateTime.now())}'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  'Total: ${Formatter().formatMoney(_sumValues(pieChartDataPurchases))}'),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  AppRoutes
                                                      .PURCHASE_HEADER_LIST);
                                            },
                                            icon: Icon(Icons.list),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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

            // TODO: Improve this
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Consumer<EarningService>(
                        builder:
                            (BuildContext context, provider, Widget? child) {
                          return FutureBuilder(
                            future:
                                provider.getEarningsSumByCategories(Filter()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return Text('No data available');
                              } else {
                                pieChartDataEarning = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Ganhos',
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .fontSize),
                                      ),
                                    ),
                                    pieChartDataEarning.length == 0
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text('Nenhum dado registrado'),
                                          )
                                        : Column(
                                            children: [
                                              PieChartComponent(
                                                pieChartData:
                                                    pieChartDataEarning,
                                              ),
                                              Chart(
                                                  pieChartData:
                                                      pieChartDataEarning,
                                                  sum: _sumValues(
                                                      pieChartDataEarning)),
                                            ],
                                          ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Resumo dos dados'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  'Período: ${DateFormat('dd/MM/yyyy').format(widget._filterEarning?.startDate! ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(widget._filterEarning?.finalDate! ?? DateTime.now())}'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  'Total: ${Formatter().formatMoney(_sumValues(pieChartDataEarning))}'),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  AppRoutes.EARNING_LIST);
                                            },
                                            icon: Icon(Icons.monetization_on),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
