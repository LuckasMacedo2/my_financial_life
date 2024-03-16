import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_financial_life/models/credit_cart.dart';

class CreditCardPage extends StatefulWidget {
  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  //Color color = Color.fromRGBO(236, 30, 30, 0.004);
  Color color = Colors.blue.shade900;
  final _formKey = GlobalKey<FormState>();

  _selectColor() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Selecione a cor'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: color,
                onColorChanged: (Color color) => setState(
                  () => this.color = color,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Selecione',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final widthTextForm = MediaQuery.of(context).size.width * 0.5;
    final SIZE_SELECT_COLOR = 75.0;
    final _formData = Map<String, Object>();

    _submitForm() {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      _formKey.currentState?.save();

      _formData['color'] = color;
      print(_formData);
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: SIZE_SELECT_COLOR,
                          child: IconButton(
                            icon: Icon(
                              Icons.color_lens,
                              size: SIZE_SELECT_COLOR,
                            ),
                            onPressed: () {
                              _selectColor();
                            },
                          ),
                        ),
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
                              onSaved: (limit) =>
                                  _formData['limit'] = double.parse(limit ?? '0'),
                            ),
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
