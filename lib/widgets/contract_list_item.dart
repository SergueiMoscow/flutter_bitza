import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/contract_api.dart';
import '../models/contract_print_response.dart';

class ContractListItem extends StatefulWidget {
  final ContractPrintResponse contract;
  final VoidCallback onUpdate;


  ContractListItem({required this.contract, required this.onUpdate});

  @override
  State<ContractListItem> createState() => _ContractListItemState();
}

class _ContractListItemState extends State<ContractListItem> {
  late DateTime? _selectedDate;
  late TextEditingController _dateController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contract.recommendedContractDate != null &&
        widget.contract.recommendedContractDate!.isNotEmpty) {
      _selectedDate = DateTime.parse(widget.contract.recommendedContractDate!);
      _dateController = TextEditingController(
        text: DateFormat('d MMMM y', 'ru').format(_selectedDate!),
      );
    } else {
      _selectedDate = null;
      _dateController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _updateDate() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, выберите дату')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    bool success = await ContractPrintApi()
        .addContractPrint(formattedDate, widget.contract.number);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Дата обновлена на $formattedDate')),
      );
      widget.onUpdate(); // Вызов обратного вызова
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении даты')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.contract.statusDescription == "Активный";
    final recommendedDate = widget.contract.recommendedContractDate;
    final backgroundColor = isActive ? Colors.white : Colors.red.shade100;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Верхняя строка: Номер комнаты и ФИО клиента
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Номер комнаты
              Text(
                widget.contract.room,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ФИО клиента
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '${widget.contract.contact.surname} ${widget.contract.contact.name}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Дата начала контракта
              Text(
                formatDate(widget.contract.latestPrint),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          // Вторая часть: Поле ввода даты или количество дней
          isActive
              ? _buildActiveContractInfo()
              : _buildInactiveContractInfo(context, recommendedDate),
        ],
      ),
    );
  }

  Widget _buildActiveContractInfo() {
    // Расчет количества дней действия контракта
    final latestPrint = DateTime.parse(widget.contract.latestPrint);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(latestPrint).inDays;

    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        SizedBox(width: 8.0),
        Text(
          'Дней действия: $difference',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.green.shade700,
          ),
        ),
        Expanded(
          child: Text(''),
        ),
        ElevatedButton(
          onPressed: () {
            ContractPrintApi().contractGetPDF(widget.contract.number);
          },
          child: Text('Печать'),
        ),
      ],
    );
  }

  Widget _buildInactiveContractInfo(BuildContext context, String? recommendedDate) {
    return Row(
      children: [
        // Поле ввода даты
        Expanded(
          child: TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Новая дата',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () async {
              // Открытие диалога выбора даты
              DateTime initialDate = _selectedDate ?? DateTime.now();
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  _dateController.text = DateFormat('d MMMM y', 'ru').format(pickedDate);
                });
              }
            },
          ),
        ),
        SizedBox(width: 8.0),
        // Кнопка "Ок"
        _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _updateDate,
          child: Text('Ок'),
        ),
      ],
    );
  }

  String formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'ru').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}