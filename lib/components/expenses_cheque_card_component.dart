import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expenses_cheque_model.dart'; // Для форматирования дат

class ExpensesChequeCardComponent extends StatelessWidget {
  final ExpensesChequeModel cheque;

  const ExpensesChequeCardComponent({
    Key? key,
    required this.cheque,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Здесь можно будет обработать нажатие на карточку
        // Например, отправить новый запрос с использованием cheque.id
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cheque.seller,
                      style: const TextStyle(
                        fontSize: 18, // Крупнее
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${cheque.total}₽', // Сумма
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Отступ
              Text(
                cheque.notes,
                style: const TextStyle(
                  fontSize: 14, // Поменьше
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4), // Отступ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cheque.account.isNotEmpty ? cheque.account : 'Нет аккаунта',
                      style: const TextStyle(
                        fontSize: 12, // Мельче
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Text(
                    cheque.user,
                    style: const TextStyle(
                      fontSize: 12, // Мельче
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Отступ
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('d MMMM').format(cheque.purchaseDate), // Форма '12 января'
                  style: const TextStyle(
                    fontSize: 10, // Ещё мельче
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}