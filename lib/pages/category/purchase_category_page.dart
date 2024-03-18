import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/picker/color_picker_dialog.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  Color color = Colors.blue.shade900;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final category = arg as PurchaseCategory;
        _formData['id'] = category.id;
        _formData['name'] = category.name;
        _formData['description'] = category.description ?? '';
        _formData['color'] = category.color;
        color = category.color;
      }
    }
  }

  _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();

    _formData['color'] = color;

    try {
      await Provider.of<PurchaseCategoryService>(
        context,
        listen: false,
      ).savePurchaseCategory(_formData);
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro'),
          content: Text('Ocorreu um erro ao salvar a categoria.'),
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

  @override
  Widget build(BuildContext context) {
    final widthTextForm = MediaQuery.of(context).size.width * 0.75;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de categorias'),
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
                          setState(
                            () {
                              color = selectedColor;
                            },
                          );
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
                              initialValue:
                                  _formData['description']?.toString(),
                              decoration: InputDecoration(
                                labelText: 'Descrição',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                              ),
                              onSaved: (description) =>
                                  _formData['description'] = description ?? '',
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
