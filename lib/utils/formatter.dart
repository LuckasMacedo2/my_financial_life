import 'package:money_formatter/money_formatter.dart';

class Formatter {
  String formatMoney(double value) {
    MoneyFormatterOutput fmf = MoneyFormatter(
      amount: value,
      settings: MoneyFormatterSettings(
        symbol: 'R\$',
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 2,
      ),
    ).output;

    // Retorna o valor formatado
    return fmf.symbolOnLeft;
  }
}