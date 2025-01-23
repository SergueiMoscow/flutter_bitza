import 'package:flutter/material.dart';

import '../../api/expenses_api.dart';
import '../../models/expenses_cheque_model.dart';
import '../expenses_cheque_card_component.dart';

class ExpensesTabHistory extends StatefulWidget {
  const ExpensesTabHistory({super.key});

  @override
  State<ExpensesTabHistory> createState() => _ExpensesTabHistoryState();
}

class _ExpensesTabHistoryState extends State<ExpensesTabHistory> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  String searchQuery = '';
  List<ExpensesChequeModel> searchResults =
      []; // Изменяем тип на ExpensesChequeModel
  bool isLoading = false;

  final ExpensesApi _expensesApi = ExpensesApi();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchHistoryExpenses();
  }

  Future<void> fetchHistoryExpenses() async {
    setState(() {
      isLoading = true;
    });
    try {
      searchResults =
          await _expensesApi.fetchExpenses(startDate, endDate, searchQuery);
      // Прокручиваем в конец после загрузки данных
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
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
    return isLoading
        ? Center( child:
            CircularProgressIndicator()
          )
        : Expanded(
            child: ListView.builder(
              controller: _scrollController, // Привязываем ScrollController
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return ExpensesChequeCardComponent(
                  cheque: searchResults[index],
                );
              },
            ),
          );
  }
}
