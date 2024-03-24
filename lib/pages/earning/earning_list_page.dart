import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/Item/earning_item.dart';
import 'package:my_financial_life/components/Item/purchase_item.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/floating_sum.dart';
import 'package:my_financial_life/services/earning_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class EarningListPage extends StatefulWidget {
  const EarningListPage({super.key});

  @override
  State<EarningListPage> createState() => _EarningListPageState();
}

class _EarningListPageState extends State<EarningListPage> {
  Future<void> _refreshEarnings(BuildContext context) async {
    return Provider.of<EarningService>(
      context,
      listen: false,
    ).loadEarnings();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshEarnings(context);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width * 0.25;
    final EarningService earnings = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ganhos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.EARNING_FORM);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshEarnings(context),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: earnings.itemsCount,
                itemBuilder: (ctx, i) => Column(
                  children: [
                    EarningItem(earnings.items[i]),
                  ],
                ),
              ),
            ),
            FloatingSum(deviceSize: deviceSize, children: [
              Text(
                'Total: ${Formatter().formatMoney(earnings.sum())}',
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
