import 'package:flutter/material.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/Item/credit_card_item.dart';
import 'package:my_financial_life/components/floating_sum.dart';
import 'package:my_financial_life/services/credit_card_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class CreditCardListPage extends StatefulWidget {
  const CreditCardListPage({super.key});

  @override
  State<CreditCardListPage> createState() => _CreditCardListPageState();
}

class _CreditCardListPageState extends State<CreditCardListPage> {
  Future<void> _refreshCreditCards(BuildContext context) {
    return Provider.of<CreditCardService>(
      context,
      listen: false,
    ).loadCreditCards();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<CreditCardService>(
      context,
      listen: false,
    ).loadCreditCards().then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width * 0.25;
    final CreditCardService creditCards = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartões de crédito'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.CREDIT_CARD_FORM);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshCreditCards(context),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: creditCards.itemsCount,
                itemBuilder: (ctx, i) => Column(
                  children: [
                    CreditCardItem(creditCards.items[i]),
                  ],
                ),
              ),
            ),
            FloatingSum(
              deviceSize: deviceSize,
              children: [
                Text(
                    'Limite total: ${Formatter().formatMoney(creditCards.sumLimits())}'),
                Consumer<PurchaseService>(
                  builder: (BuildContext context,
                      PurchaseService purchaseService, Widget? child) {
                    return FutureBuilder(
                      future: purchaseService.getSumPurchasesNotByCreditCard(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return Text('No data available');
                        } else {
                          return Container(
                            child: Text(
                                'Limite usado: ${Formatter().formatMoney(double.parse(snapshot.data!.toString()))}'),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
