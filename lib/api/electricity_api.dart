import 'dart:convert';
import '../models/electricity_reading_model.dart';
import 'auth_api.dart';

class ElectricityService {
  final AuthApiService _authApiService = AuthApiService();

  Future<List<ElectricityReading>> fetchLatestReadings() async {
    final response = await _authApiService.authenticatedRequest(
      endpoint: '/api/electricity/latest/',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ElectricityReading.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось загрузить данные');
    }
  }

  Future<bool> addReadings(List<ElectricityReading> readings) async {
    final response = await _authApiService.authenticatedRequest(
      endpoint: '/api/electricity/add/',
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: readings.map((r) => r.toJson()).toList(),
    );
    print('Request addReadings sent');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      // Можно добавить обработку ошибок более подробно
      return false;
    }
  }


}