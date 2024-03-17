import 'package:flutter/material.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/utils/app_routes.dart';

class PurchaseCategoryItem extends StatelessWidget {
  final PurchaseCategory purchaseCategory;
  const PurchaseCategoryItem(this.purchaseCategory, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(purchaseCategory.name[0].toUpperCase()),
        ),
        title: Text(purchaseCategory.name),
        subtitle: Text(purchaseCategory.description ?? ''),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.CATEGORY_FORM,
                    arguments: purchaseCategory,
                  );
                },
                icon: Icon(Icons.edit),
                //color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}