import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/chart/chart.dart';
import 'package:my_financial_life/components/chart/pie_chart.dart';
import 'package:my_financial_life/models/filters/filter.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_header.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PurchaseService>(
      context,
      listen: false,
    ).loadPurchase();
  }

  @override
  Widget build(BuildContext context) {
    //final PurchaseService provider = Provider.of(context);
    //final List<Purchase> purchases = provider.items;

    List<PieChartSectionData> pieChartData = [];

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
                              return Row(
                                children: [
                                  Expanded(
                                    child: PieChartComponent(
                                      pieChartData: pieChartData,
                                    ),
                                  ),
                                  //Expanded(child: Chart(pieChartData: pieChartData)),
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
