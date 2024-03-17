import 'package:flutter/material.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/credit_card_item.dart';
import 'package:my_financial_life/services/credit_card_service.dart';
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
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: EdgeInsets.all(16),
                width: deviceSize * 2,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Limite total: ${Formatter().formatMoney(creditCards.sumLimits())}'),
                        Text('Teste'),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
