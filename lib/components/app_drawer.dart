import 'package:flutter/material.dart';
import 'package:my_financial_life/utils/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Bem vindo usuário'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Início'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.HOME_PAGE,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Cartões de crédito'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.CREDIT_CARD_LIST,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category_outlined),
            title: Text('Categorias'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.CATEGORY_LIST,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shopping_bag_sharp),
            title: Text('Compras/Dívidas'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.PURCHASE_LIST,
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
