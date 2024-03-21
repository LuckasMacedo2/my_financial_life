import 'package:flutter/material.dart';
import 'package:my_financial_life/components/Item/purchase_item_header.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/filter.dart';
import 'package:my_financial_life/components/floating_sum.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class PurchaseHeaderPage extends StatefulWidget {
  const PurchaseHeaderPage({super.key});

  @override
  State<PurchaseHeaderPage> createState() => _PurchaseHeaderPageState();
}

class _PurchaseHeaderPageState extends State<PurchaseHeaderPage> {
  bool _expanded = false;
  bool _filterPaid = false;

  Future<void> _refreshPurchases(BuildContext context) async {
    return Provider.of<PurchaseService>(
      context,
      listen: false,
    ).loadPurchase();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshPurchases(context);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width * 0.25;
    final PurchaseService purchases = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Compras/dívidas'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PURCHASE_LIST);
            },
            icon: Icon(Icons.list),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PURCHASE_FORM);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshPurchases(context),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FilterWidget(
                child: Switch(onChanged: (bool neewValue) {
                  setState(() {
                    _filterPaid = neewValue;
                  });
                }, value: _filterPaid,),
                onExpandedChanged: (bool expanded) {
                  // Aqui você pode lidar com a mudança em _expanded
                  setState(() {
                                      _expanded = expanded;

                  });
                },
              ),
            ),
            Positioned(
              top: _expanded ? 130 : 80, // Ajuste conforme necessário
              bottom: 0,
              left: 0,
              right: 0,
              child: ListView.builder(
                itemCount: purchases.itemsHeader.length,
                itemBuilder: (ctx, i) => Column(
                  children: [
                    PurchaseHeaderItem(
                      purchases.itemsHeader[i],
                    ),
                  ],
                ),
              ),
            ),
            FloatingSum(
              deviceSize: deviceSize,
              children: [
                Text(
                  'Total: ${Formatter().formatMoney(purchases.sumValues())}',
                ),
                Text(
                  'Total a pagar: ${Formatter().formatMoney(purchases.sumNotPaid())}',
                ),
                Text(
                  'Já pago: ${Formatter().formatMoney(purchases.diff())}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
