import 'package:flutter/material.dart';
import 'package:my_financial_life/components/dropbox_item.dart';
import 'package:my_financial_life/components/picker/date_picker.dart';
import 'package:my_financial_life/models/earning.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/services/earning_service.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:provider/provider.dart';

class EarningPage extends StatefulWidget {
  const EarningPage({super.key});

  @override
  State<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends State<EarningPage> {
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  DateTime? _selectedDate;
  PurchaseCategory? _selectedCategory;

  bool _isEdition = false;

  @override
  void initState() {
    Provider.of<PurchaseCategoryService>(
      context,
      listen: false,
    ).loadPurchaseCategory().then((value) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final earning = arg as Earning;
        _formData['id'] = earning.id;
        _formData['value'] = earning.value;
        _formData['description'] = earning.description;
        _formData['observation'] = earning.observation ?? '';
        _formData['date'] = earning.date;
        _formData['categoryId'] = earning.categoryId;
        _formData['profit'] = earning.profit ?? '0';
        _selectedDate = earning.date;
        _isEdition = true;
      }
    }
  }

  _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();

    _formData['date'] = _selectedDate == null
        ? DateTime.now().toIso8601String()
        : _selectedDate!.toIso8601String();
    _formData['categoryId'] = _selectedCategory!.id;

    try {
      await Provider.of<EarningService>(
        context,
        listen: false,
      ).saveEarning(_formData);
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro'),
          content: Text('Ocorreu um erro ao salvar o ganho.'),
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
    final widthTextForm = MediaQuery.of(context).size.width * 0.45;
    final PurchaseCategoryService categories = Provider.of(context);

    if (_formData['categoryId'] != null &&
        _formData['categoryId'] != "" &&
        categories.items.length > 0)
      _selectedCategory = categories.items
          .where((c) => c.id == _formData['categoryId'].toString())
          .first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de ganhos'),
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
                //mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: widthTextForm,
                        child: TextFormField(
                          initialValue: _formData['description']?.toString(),
                          decoration: InputDecoration(
                            labelText: 'Descrição',
                          ),
                          onSaved: (description) =>
                              _formData['description'] = description ?? '',
                          validator: (_name) {
                            final name = _name ?? '';

                            if (name.trim().isEmpty)
                              return 'A descrição é obrigatória';
                            if (name.trim().length < 3)
                              return 'A descrição precisa de no minímo 3 letras';

                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: widthTextForm,
                        child: TextFormField(
                          initialValue: _formData['value']?.toString(),
                          decoration: InputDecoration(
                            labelText: 'Valor',
                          ),
                          onSaved: (value) => _formData['value'] = value ?? '',
                          validator: (_price) {
                            final priceStr = _price ?? '';
                            final price = double.tryParse(priceStr) ?? -1;

                            if (price <= 0) return 'Informe um valor válido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        width: widthTextForm,
                        child: DatePicker(
                          initialDate: _selectedDate,
                          onDateSelected: (DateTime date) {
                            setState(
                              () {
                                _selectedDate = date;
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: widthTextForm,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            border: InputBorder.none,
                          ),
                          child: DropdownButtonFormField<PurchaseCategory?>(
                            value: _selectedCategory != null
                                ? _selectedCategory
                                : null,
                            isExpanded: true,
                            items: categories.items.map(
                              (PurchaseCategory item) {
                                return DropdownMenuItem<PurchaseCategory>(
                                  value: item,
                                  child: CategoryDropdownItem(
                                    color: item.color,
                                    name: item.name,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (PurchaseCategory? value) {
                              setState(
                                () {
                                  _selectedCategory = value;
                                },
                              );
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor, selecione uma categoria';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: widthTextForm,
                    child: TextFormField(
                      initialValue: _formData['profit']?.toString(),
                      decoration: InputDecoration(
                        labelText: 'Lucro',
                      ),
                      onSaved: (profit) => _formData['profit'] = profit ?? '',
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      initialValue: _formData['observation']?.toString(),
                      decoration: InputDecoration(
                        labelText: 'Observações',
                      ),
                      onSaved: (observation) =>
                          _formData['observation'] = observation ?? '',
                    ),
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
