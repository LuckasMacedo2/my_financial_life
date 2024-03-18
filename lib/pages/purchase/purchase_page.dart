import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_financial_life/components/dropbox_item.dart';
import 'package:my_financial_life/components/picker/date_picker.dart';
import 'package:my_financial_life/models/credit_cart.dart';
import 'package:my_financial_life/models/purchase.dart';
import 'package:my_financial_life/models/purchase_category.dart';
import 'package:my_financial_life/services/credit_card_service.dart';
import 'package:my_financial_life/services/purchase_category_service.dart';
import 'package:my_financial_life/services/purchase_service.dart';
import 'package:provider/provider.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  DateTime? _selectedDate;
  CreditCard? _selectedCreditCard;
  PurchaseCategory? _selectedCategory;

  bool _isEdition = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<CreditCardService>(
      context,
      listen: false,
    ).loadCreditCards().then((value) {});

    Provider.of<PurchaseCategoryService>(
      context,
      listen: false,
    ).loadPurchaseCategory().then((value) {});
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final purchase = arg as Purchase;
        _formData['id'] = purchase.id;
        _formData['value'] = purchase.value;
        _formData['description'] = purchase.description;
        _formData['installmentsQuantity'] = purchase.installmentsQuantity;
        _formData['date'] = purchase.date;
        _formData['creditCardId'] = purchase.creditCardId ?? '';
        _formData['categoryId'] = purchase.categoryId;
        _selectedDate = purchase.date;
        _isEdition = true;
        // TODO: Load credit card and category
        //_selectedCategory = purchase.category;
        //_selectedCreditCard = purchase.cre
      }
    }
  }

  _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();

    _formData['creditCardId'] = _selectedCreditCard?.id ?? '';
    _formData['date'] = _selectedDate == null
        ? DateTime.now().toIso8601String()
        : _selectedDate!.toIso8601String();
    _formData['categoryId'] = _selectedCategory!.id;
    
    try {
      await Provider.of<PurchaseService>(
        context,
        listen: false,
      ).savePurchase(_formData);
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
    final widthTextForm = MediaQuery.of(context).size.width * 0.30;
    final CreditCardService creditCards = Provider.of(context);
    final PurchaseCategoryService categories = Provider.of(context);

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
                        width: 15,
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
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: widthTextForm,
                        child: TextFormField(
                          enabled: !_isEdition,
                          initialValue: '1',
                          decoration: InputDecoration(
                            labelText: 'Quantidade de parcelas',
                          ),
                          onSaved: (installmentsQuantity) =>
                              _formData['installmentsQuantity'] =
                                  installmentsQuantity ?? '',
                          validator: (_price) {
                            final priceStr = _price ?? '';
                            final price = double.tryParse(priceStr) ?? -1;

                            if (price <= 0)
                              return 'Informe a quantidade de parcelas maior ou igual á 1';
                            return null;
                          },
                        ),
                      )
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
                          onDateSelected: (DateTime date) {
                            // Faça qualquer coisa que você deseja com a cor selecionada, por exemplo, atualizar o estado do componente pai
                            setState(
                              () {
                                _selectedDate = date;
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: widthTextForm,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Cartão de crédito',
                            border: InputBorder.none,
                          ),
                          child: DropdownButtonFormField(
                            value: _selectedCreditCard,
                            isExpanded: true,
                            items: creditCards.items.map(
                              (CreditCard item) {
                                return DropdownMenuItem<CreditCard>(
                                  value: item,
                                  child: CategoryDropdownItem(
                                    color: item.color,
                                    name: item.name,
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (CreditCard? value) {
                              setState(
                                () {
                                  if (value!.id != null) {
                                    _selectedCreditCard = value;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: widthTextForm,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            border: InputBorder.none,
                          ),
                          child: DropdownButtonFormField<PurchaseCategory?>(
                            value: _selectedCategory,
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
