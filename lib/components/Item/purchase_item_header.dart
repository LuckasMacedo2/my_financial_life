import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial_life/models/purchase_header.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class PurchaseHeaderItem extends StatelessWidget {
  final PurchaseHeader purchaseHeader;
  const PurchaseHeaderItem(this.purchaseHeader, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5),
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Consumer<PurchaseCategoryService>(
                    builder: (BuildContext context, purchaseCategoryService,
                        Widget? child) {
                      return FutureBuilder(
                        future:
                            purchaseCategoryService.loadPurchaseCategoryById(
                                purchaseHeader.categoryId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return Text('No data available');
                          } else {
                            purchaseHeader.category = snapshot.data!;
                            return CircleAvatar(
                              backgroundColor: purchaseHeader.category!.color,
                              child: Stack(children: [
                                if (purchaseHeader.fullPaid)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.green.shade400,
                                      size: 50,
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    purchaseHeader.description[0].toUpperCase(),
                                  ),
                                ),
                              ]),
                            );
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(width: 20),
                  Text(
                    '${purchaseHeader.description} - Desde ${DateFormat('dd/MM/yyyy').format(purchaseHeader.startDate)}',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Parcelas ${purchaseHeader.installmentsPaidQuantity.toString()}/${purchaseHeader.installmentsQuantity.toString()} ${purchaseHeader.nextPayDate != null ? '- Próximo pagamento ${DateFormat('dd/MM/yyyy').format(purchaseHeader.startDate)}' : ''}',
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Valor total: ${Formatter().formatMoney(purchaseHeader.totalValue).toString()}'),
                  Text(
                      'Falta pagar: ${Formatter().formatMoney(purchaseHeader.notPaidValue).toString()}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
