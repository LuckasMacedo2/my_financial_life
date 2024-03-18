import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/Item/purchase_item.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:provider/provider.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: purchases.itemsCount,
                itemBuilder: (ctx, i) => Column(
                  children: [
                    PurchaseItem(purchases.items[i]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
