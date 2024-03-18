import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class PurchaseItem extends StatelessWidget {
  final Purchase purchase;
  const PurchaseItem(this.purchase, {super.key});

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return Card(
      elevation: 5,
      child: ListTile(
        leading: Consumer<PurchaseCategoryService>(
          builder: (BuildContext context, purchaseCategoryService, Widget? child) {
            return FutureBuilder(
              future: purchaseCategoryService.loadPurchaseCategoryById(purchase.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('No data available');
                } else {
                  purchase.category = snapshot.data!;
                  return CircleAvatar(
                    backgroundColor: purchase.category!.color,
                    child: Text(purchase.description[0].toUpperCase()),
                  );
                }
              },
            );
          },
        ),
        title: Text(purchase.description),
        subtitle: Text(Formatter().formatMoney(purchase.value)),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.PURCHASE_FORM,
                    arguments: purchase,
                  );
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Excluir a compra/dívida'),
                      content: Text('Tem certeza?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('Não')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                            child: Text('Sim')),
                      ],
                    ),
                  ).then(
                    (value) async {
                      if (value ?? false) {
                        try {
                          await Provider.of<PurchaseService>(
                            context,
                            listen: false,
                          ).removePurchase(purchase);
                        } catch (error) {
                          msg.showSnackBar(
                            SnackBar(
                              content: Text(
                                error.toString(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
                icon: Icon(Icons.delete),
                color: Colors.red,
              )
            ],
          ),
        ),
      ),
    );
  }
}
