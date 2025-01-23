import 'dart:convert';

import 'package:flutter_s3_app/api/auth_api.dart';
import 'package:flutter_s3_app/models/expenses_cheque_model.dart';

class ExpensesApi {
  final AuthApiService _authApi = AuthApiService();

  Future<List<ExpensesChequeModel>> fetchExpenses(
      DateTime startDate, DateTime endDate, String searchQuery) async {
    String endpoint = '/api/expenses/cheques/';
    String startDateString = startDate.toIso8601String();
    String endDateString = endDate.toIso8601String();

    final response = await _authApi.authenticatedRequest(
      method: 'GET',
      endpoint:
          endpoint + responseUrl(startDateString, endDateString, searchQuery),
    );

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      return parseResponse(body);
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  String responseUrl(String startDate, String endDate, String search) {
    String url = '?start_date=$startDate&end_date=$endDate';
    if (search.isNotEmpty) {
      url += '&search=$search';
    }
    return url;
  }

  List<ExpensesChequeModel> parseResponse(String responseBody) {
    // Преобразуем ответ в список
    final Map<String, dynamic> parsed = jsonDecode(responseBody);
    final List<dynamic> chequesList = parsed['cheques'];

    return chequesList
        .map<ExpensesChequeModel>((json) => ExpensesChequeModel.fromJson(json))
        .toList();
  }
}
