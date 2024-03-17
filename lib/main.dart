import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/pages/category/category_list_page.dart';
import 'package:my_financial_life/pages/category/category_page.dart';
import 'package:my_financial_life/pages/credit_card/credit_card_list.dart';
import 'package:my_financial_life/pages/credit_card/credit_card_page.dart';
import 'package:my_financial_life/pages/home_page.dart';
import 'package:my_financial_life/services/credit_card_service.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/utils/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CreditCardService>(
          // Um provider que depende de outro. O de lista de produtos depende do provider de autenticação
          create: (_) => CreditCardService(),
        ),
        ChangeNotifierProvider<PurchaseCategoryService>(
          // Um provider que depende de outro. O de lista de produtos depende do provider de autenticação
          create: (_) => PurchaseCategoryService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(),
        darkTheme: ThemeData.dark(), // standard dark theme
        themeMode: ThemeMode.system, // device controls theme
        //home: HomePage(),
        routes: {
          AppRoutes.CREDIT_CARD_FORM: (ctx) => CreditCardPage(),
          AppRoutes.CREDIT_CARD_LIST: (ctx) => CreditCardListPage(),
          AppRoutes.CATEGORY_FORM: (ctx) => CategoryPage(),
          AppRoutes.CATEGORY_LIST: (ctx) => CategoryListPage(),
          AppRoutes.HOME_PAGE: (ctx) => HomePage(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modo Escuro Flutter'),
      ),
      body: Center(
        child: Text(
          'Modo Escuro!',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
