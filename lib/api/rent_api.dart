import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_s3_app/models/contract_payments_response.dart';
import 'package:flutter_s3_app/models/room_payment_model.dart';
import 'package:flutter_s3_app/models/room_summary.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_api.dart';

class RentApiService {
  final String _host = dotenv.env['API_HOST'] ?? '';
  final _storage = const FlutterSecureStorage();

  Future<List<RoomSummary>> fetchRoomSummary() async {
    final response = await AuthApiService().authenticatedRequest(
      endpoint: '/api/rent/summary/',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final List data = jsonDecode(body);
      return data.map((json) => RoomSummary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load summary data');
    }
  }

  Future<ContractPaymentsResponse> fetchRoomWithContractPayments(String roomId) async {
    final response = await AuthApiService().authenticatedRequest(
        endpoint: '/api/rent/rooms/$roomId/payments/', method: 'GET');
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(body);
      // Так возвращаем только платежи
      // return data.map((json) => RoomPayment.fromJson(json)).toList();
      return ContractPaymentsResponse.fromJson(data);
    } else {
      throw Exception('Failed to load room payment');
    }
  }

  Future<RoomPaymentModel> addPayment({
    required String roomId,
    required String date, // Добавил дату, так как она обязательна в модели
    String? bankAccount,
    String? bookAccount,
    required int amount,
    int discount = 0, // По умолчанию 0
  }) async {
    final body = {
      'room': roomId,
      'date': date,
      'bank_account': bankAccount,
      'book_account': bookAccount,
      'amount': amount,
      'discount': discount,
    };

    final response = await AuthApiService().authenticatedRequest(
      endpoint: '/api/rent/rooms/$roomId/payments/',
      headers: {'Content-Type': 'application/json'},
      method: 'POST',
      body: body,
    );

    if (response.statusCode == 201) {
      final body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = jsonDecode(body);
      return RoomPaymentModel.fromJson(data);
    } else {
      throw Exception('Failed to add payment: ${response.statusCode}');
    }
  }
}
