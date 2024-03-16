import 'package:flutter/material.dart';
import 'package:my_financial_life/pages/credit_card_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(), // standard dark theme
      themeMode: ThemeMode.system, // device controls theme
      home: CreditCardPage(),
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

