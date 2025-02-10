import 'package:flutter/material.dart';
import 'package:flutter_s3_app/services/date_format.dart';
import 'package:intl/intl.dart';

import '../api/contract_api.dart';
import '../models/contract_print_response.dart';

class ContractListItem extends StatelessWidget {
  final ContractPrintResponse contract;

  ContractListItem({required this.contract});

  @override
  Widget build(BuildContext context) {
    final isActive = contract.statusDescription == "Активный";
    final recommendedDate = contract.recommendedContractDate;
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
                contract.room,
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
                    '${contract.contact.surname} ${contract.contact.name}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Дата начала контракта
              Text(
                'Дата: ${formatDate(contract.latestPrint)}',
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
    final latestPrint = DateTime.parse(contract.latestPrint);
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
            ContractPrintApi().contractGetPDF(contract.number);
          },
          child: Text('Печать'),
        ),
      ],
    );
  }

  Widget _buildInactiveContractInfo(BuildContext context, String? recommendedDate) {
    TextEditingController _dateController = TextEditingController(
      text: recommendedDate ?? '',
    );

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
            readOnly: false,
            onTap: () async {
              // Открытие диалога выбора даты
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: recommendedDate != null && recommendedDate.isNotEmpty
                    ? DateTime.parse(recommendedDate)
                    : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                // Здесь вы можете добавить логику сохранения новой даты на сервере
              }
            },
          ),
        ),
        SizedBox(width: 8.0),
        // Кнопка "Ок"
        ElevatedButton(
          onPressed: () {
            // Обработка нажатия кнопки "Ок"
            final newDate = _dateController.text;
            // Добавьте логику для сохранения новой даты на сервере
            ContractPrintApi().addContractPrint(contract.recommendedContractDate, contract.number);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Дата обновлена на $newDate')),
            );
          },
          child: Text('Ок'),
        ),
      ],
    );
  }
}