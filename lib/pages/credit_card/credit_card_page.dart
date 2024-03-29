import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:my_financial_life/components/picker/color_picker_dialog.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/services/credit_card_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:my_financial_life/utils/formatter.dart';
import 'package:provider/provider.dart';

class CreditCardPage extends StatefulWidget {
  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  Color color = Colors.blue.shade900;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  bool _isEdition = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final creditCard = arg as CreditCard;
        _formData['id'] = creditCard.id;
        _formData['name'] = creditCard.name;
        _formData['limit'] = creditCard.limit;
        _formData['color'] = creditCard.color;
        _formData['usedLimit'] = creditCard.usedLimit ?? 0;
        color = creditCard.color;
        _isEdition = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthTextForm = MediaQuery.of(context).size.width * 0.5;

    _submitForm() async {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      _formKey.currentState?.save();

      _formData['color'] = color;

      try {
        await Provider.of<CreditCardService>(
          context,
          listen: false,
        ).saveCreditCard(_formData);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Ocorreu um erro'),
            content: Text('Ocorreu um erro ao salvar o cartão de crédito.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Ok'),
              )
            ],
          ),
        );
      } finally {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de cartão de crédito'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ColorPickerDialog(
                        color: color,
                        onColorSelected: (Color selectedColor) {
                          // Faça qualquer coisa que você deseja com a cor selecionada, por exemplo, atualizar o estado do componente pai
                          setState(() {
                            color = selectedColor;
                          });
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: widthTextForm,
                            child: TextFormField(
                              initialValue: _formData['name']?.toString(),
                              decoration: InputDecoration(
                                labelText: 'Nome',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                              ),
                              onSaved: (name) => _formData['name'] = name ?? '',
                              validator: (_name) {
                                final name = _name ?? '';

                                if (name.trim().isEmpty)
                                  return 'O nome é obrigatório';
                                if (name.trim().length < 3)
                                  return 'O nome precisa de no minímo 3 letras';

                                return null;
                              },
                            ),
                          ),
                          Container(
                            width: widthTextForm,
                            child: TextFormField(
                              initialValue: _formData['limit']?.toString(),
                              decoration: InputDecoration(
                                labelText: 'Limite',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onSaved: (limit) => _formData['limit'] =
                                  double.parse(limit ?? '0'),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          if (_isEdition)
                            Consumer<PurchaseService>(
                              builder: (
                                BuildContext context,
                                PurchaseService purchaseService,
                                Widget? child,
                              ) {
                                return FutureBuilder(
                                  future: purchaseService
                                      .getSumPurchasesNotByCreditCardId(
                                    _formData['id'].toString(),
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData) {
                                      return Text('No data available');
                                    } else {
                                      _formData['usedLimit'] = snapshot.data!;
                                      return Container(
                                        width: widthTextForm,
                                        child: Text(
                                            'Limite usado: ${Formatter().formatMoney(double.parse(_formData['usedLimit'].toString()))}'),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: Icon(Icons.save),
                      label: Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
