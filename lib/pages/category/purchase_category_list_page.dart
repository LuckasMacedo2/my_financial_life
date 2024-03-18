import 'package:flutter/material.dart';
import 'package:my_financial_life/components/app_drawer.dart';
import 'package:my_financial_life/components/purchase_category_item.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:provider/provider.dart';

class CategoryListPage extends StatefulWidget {
  @override
  State<CategoryListPage> createState() => _CategoryListPageState();

}

class _CategoryListPageState extends State<CategoryListPage> {
  Future<void> _refreshPurchaseCategories(BuildContext context) {
    return Provider.of<PurchaseCategoryService>(
      context,
      listen: false,
    ).loadPurchaseCategory();
  }

  @override
  void initState() {
    super.initState();
    _refreshPurchaseCategories(context);
  }

  @override
  Widget build(BuildContext context) {
    final PurchaseCategoryService purchaseCategories = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.CATEGORY_FORM);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshPurchaseCategories(context),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: purchaseCategories.itemsCount,
                itemBuilder: (ctx, i) => Column(
                  children: [
                    PurchaseCategoryItem(purchaseCategories.items[i]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}