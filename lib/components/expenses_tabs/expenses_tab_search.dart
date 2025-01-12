import 'package:flutter/material.dart';
import 'package:flutter_s3_app/api/expenses_api.dart'; // Импортируем новый API
import 'package:flutter_s3_app/components/expenses_cheque_card_component.dart';
import '../date_picker_field.dart';
import 'package:flutter_s3_app/models/expenses_cheque_model.dart';

class ExpensesTabSearch extends StatefulWidget {
  const ExpensesTabSearch({super.key});

  @override
  State<ExpensesTabSearch> createState() => _ExpensesTabSearchState();
}

class _ExpensesTabSearchState extends State<ExpensesTabSearch> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  String searchQuery = '';
  List<ExpensesChequeModel> searchResults = []; // Изменяем тип на ExpensesChequeModel
  bool isLoading = false;

  final ExpensesApi _expensesApi = ExpensesApi(); // Используем новый API

  Future<void> fetchExpenses() async {
    setState(() {
      isLoading = true;
    });

    try {
      searchResults = await _expensesApi.fetchExpenses(startDate, endDate, searchQuery);
    } catch (e) {
      // Обработка ошибок
      print('Error fetching expenses: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'Дата от',
                  selectedDate: startDate,
                  onDateChanged: (newDate) {
                    setState(() {
                      startDate = newDate;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DatePickerField(
                  label: 'Дата до',
                  selectedDate: endDate,
                  onDateChanged: (newDate) {
                    setState(() {
                      endDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    searchQuery = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Искать',
                  ),
                ),
              ),
              IconButton(
                onPressed: fetchExpenses,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return ExpensesChequeCardComponent(
                  cheque: searchResults[index], // Передавайте модель
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}