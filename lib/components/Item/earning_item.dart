import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial_life/models/earning.dart';
import 'package:my_financial_life/models/earning.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/services/earning_service.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class EarningItem extends StatelessWidget {
  final Earning earning;
  const EarningItem(this.earning, {super.key});

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return Card(
      elevation: 5,
      child: ListTile(
        leading: Consumer<PurchaseCategoryService>(
          builder:
              (BuildContext context, earningCategoryService, Widget? child) {
            return FutureBuilder(
              future: earningCategoryService
                  .loadPurchaseCategoryById(earning.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('No data available');
                } else {
                  earning.category = snapshot.data!;
                  return CircleAvatar(
                    backgroundColor: earning.category!.color,
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          earning.description[0].toUpperCase(),
                        ),
                      ),
                    ]),
                  );
                }
              },
            );
          },
        ),
        title: Text(
            '${earning.description} - ${DateFormat('dd/MM/yyyy').format(earning.date)}'),
        subtitle: Text('${Formatter().formatMoney(earning.value)} ${(earning.profit != 0.0 ? ' - Lucro: ${Formatter().formatMoney(earning.profit!)}' : '')}'),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.EARNING_FORM,
                    arguments: earning,
                  );
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Excluir o ganho'),
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
                          await Provider.of<EarningService>(
                            context,
                            listen: false,
                          ).removeEarning(earning);
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
