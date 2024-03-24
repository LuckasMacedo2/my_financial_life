import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/chart/chart.dart';
import 'package:my_financial_life/components/chart/pie_chart.dart';
import 'package:my_financial_life/models/filters/filter.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_header.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  Filter? _filter = Filter();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PieChartSectionData> pieChartData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PurchaseService>(
      context,
      listen: false,
    ).loadPurchase();
  }

  double _sumValues() {
    double sum = 0.0;
    pieChartData.forEach((p) {
      sum += p.value;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    //final PurchaseService provider = Provider.of(context);
    //final List<Purchase> purchases = provider.items;

    //double sum = _sumValues();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem vindo!'),
      ),
      drawer: AppDrawer(),
      body: Column(
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
                          future:
                              provider.getPurchasesSumByCategories(Filter()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData) {
                              return Text('No data available');
                            } else {
                              pieChartData = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      PieChartComponent(
                                        pieChartData: pieChartData,
                                      ),
                                      Chart(pieChartData: pieChartData, sum: _sumValues()),
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Resumo dos dados'),
                                        SizedBox(height: 5,),
                                        Text('Período: ${DateFormat('dd/MM/yyyy').format(widget._filter?.startDate! ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(widget._filter?.finalDate! ?? DateTime.now())}'),
                                        SizedBox(height: 5,),
                                        Text('Total: ${Formatter().formatMoney(_sumValues())}'),
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
    );
  }
}
