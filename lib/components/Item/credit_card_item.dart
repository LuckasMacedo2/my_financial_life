import 'package:flutter/material.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/services/credit_card_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class CreditCardItem extends StatelessWidget {
  final CreditCard creditCard;
  const CreditCardItem(this.creditCard, {super.key});

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: creditCard.color,
          child: Text(creditCard.name[0].toUpperCase()),
        ),
        title: Text(creditCard.name),
        subtitle: Text(Formatter().formatMoney(creditCard.limit)),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.CREDIT_CARD_FORM,
                    arguments: creditCard,
                  );
                },
                icon: Icon(Icons.edit),
                //color: Theme.of(context).primaryColor,
              ),
              IconButton(
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Excluir o cartão de crédito'),
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
                          await Provider.of<CreditCardService>(
                            context,
                            listen: false,
                          ).removeCreditCard(creditCard);
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
