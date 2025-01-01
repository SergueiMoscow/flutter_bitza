import 'package:flutter/material.dart';
import 'package:flutter_s3_app/providers/contract_payments_provider.dart';
import 'package:flutter_s3_app/models/bank_account_model.dart';
import 'package:provider/provider.dart';

class PaymentForm extends StatefulWidget {
  final String roomId;

  const PaymentForm({super.key, required this.roomId});

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  BankAccountModel? _selectedBankAccount;
  bool _showMore = false;

  @override
  void initState() {
    super.initState();
    // Получение данных из провайдера после рендера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContractPaymentsProvider>(context, listen: false)
          .fetchRoomPayments()
          .then((_) {
        final provider = Provider.of<ContractPaymentsProvider>(context, listen: false);

        // Установка первого банковского счета по умолчанию
        if (provider.bankAccounts.isNotEmpty) {
          setState(() {
            _selectedBankAccount = provider.bankAccounts.first;
          });
        }

        // Установка значений из контракта
        if (provider.contract != null) {
          setState(() {
            _amountController.text = provider.contract!.price.toString();
            _discountController.text = provider.contract!.discount.toString();
            _totalController.text = (provider.contract!.price - provider.contract!.discount).toString();
            _selectedDate = DateTime.now();
            _dateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _discountController.dispose();
    _totalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _toggleMore() {
    setState(() {
      _showMore = !_showMore;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text);
      final DateTime date = _selectedDate ?? DateTime.now();
      final int discount = _discountController.text.isNotEmpty
          ? int.parse(_discountController.text)
          : 0;
      // TODO: delete unused variable
      final int total = amount.toInt() - discount;

      try {
        await Provider.of<ContractPaymentsProvider>(context, listen: false)
            .addPayment(
          roomId: widget.roomId,
          amount: amount,
          discount: discount,
          date: date,
          bankAccount: _selectedBankAccount?.name,
        );

        // Очистка полей после успешного добавления
        _amountController.clear();
        _discountController.clear();
        _totalController.clear();
        _dateController.clear();

        // Сброс выбранного банковского счета на первый из списка
        final provider = Provider.of<ContractPaymentsProvider>(context, listen: false);
        if (provider.bankAccounts.isNotEmpty) {
          setState(() {
            _selectedBankAccount = provider.bankAccounts.first;
          });
        }

        setState(() {
          _selectedDate = null;
        });

        // Отображение уведомления об успехе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Платеж успешно добавлен')),
        );
      } catch (error) {
        // Обработка ошибок
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении платежа')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContractPaymentsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.bankAccounts.isEmpty) {
          return Text('Нет доступных банковских счетов');
        }

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Добавить платеж',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Поле для ввода суммы платежа
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Сумма',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите сумму платежа';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Введите корректную сумму';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Выпадающий список для выбора банковского счета
              DropdownButtonFormField<BankAccountModel>(
                value: _selectedBankAccount,
                decoration: InputDecoration(
                  labelText: 'Банковский счет',
                  border: OutlineInputBorder(),
                ),
                items: provider.bankAccounts
                    .map((BankAccountModel account) => DropdownMenuItem<BankAccountModel>(
                  value: account,
                  child: Text(account.name),
                ))
                    .toList(),
                onChanged: (BankAccountModel? newValue) {
                  setState(() {
                    _selectedBankAccount = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Выберите банковский счет';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Ссылка "Ещё..."
              GestureDetector(
                onTap: _toggleMore,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _showMore ? 'Скрыть' : 'Ещё...',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // Дополнительные поля
              if (_showMore) ...[
                SizedBox(height: 10),

                // Поле для ввода скидки
                TextFormField(
                  controller: _discountController,
                  decoration: InputDecoration(
                    labelText: 'Скидка',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final amt = int.tryParse(_amountController.text) ?? 0;
                    final disc = int.tryParse(value) ?? 0;
                    setState(() {
                      _totalController.text = (amt - disc).toString();
                    });
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final number = int.tryParse(value);
                      if (number == null || number < 0) {
                        return 'Введите корректную скидку';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Поле для отображения итого
                TextFormField(
                  controller: _totalController,
                  decoration: InputDecoration(
                    labelText: 'Итого',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 10),

                // Поле для выбора даты платежа
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Дата платежа',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Выберите дату платежа';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
              ],

              SizedBox(height: 20),

              // Кнопка для добавления платежа
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Добавить платеж'),
              ),
            ],
          ),
        );
      },
    );
  }
}