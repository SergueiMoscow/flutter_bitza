import 'dart:convert';

import 'package:flutter_s3_app/models/contract_print_response.dart';

import 'auth_api.dart';
import 'dart:html' as html;


class ContractPrintApi {
  Future<List<ContractPrintResponse>> fetchContractPrintResponse() async {
    final response = await AuthApiService().authenticatedRequest(
      endpoint: '/api/rent/print-contracts/',
      method: 'GET',
    );
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final List data = jsonDecode(body);
      return data.map((json) => ContractPrintResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load summary data');
    }
  }

  Future<void> contractGetPDF(String contractNumber) async {
    final response = await AuthApiService().authenticatedRequest(
      endpoint: '/api/rent/generate-contract-pdf/',
      method: 'POST',
      headers: {'Content-Type': 'application/json', 'Accept-Encoding': 'gzip, deflate, br', 'Accept': '*/*'},
      body: {'contract_id': contractNumber},
    );

    if (response.statusCode == 200) {
      // Получаем бинарные данные PDF
      final bytes = response.bodyBytes;

      // Создаём Blob из полученных байт
      final blob = html.Blob([bytes], 'application/pdf');

      // Создаём URL для Blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Открываем PDF в новой вкладке
      html.window.open(url, '_blank');

      // Освобождаем ресурсы
      html.Url.revokeObjectUrl(url);

      print('PDF успешно открыт в новой вкладке.');
    } else {
      // Обработка других кодов ответа
      print('Ошибка при получении PDF: ${response.statusCode}');
    }

  }

  Future<bool> addContractPrint(String? recommendedDate, String contractNumber) async {
    final response = await AuthApiService().authenticatedRequest(
      endpoint: '/api/rent/print-contracts/add/',
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: {'date': recommendedDate, 'contract': contractNumber},
    );
    if (response.statusCode == 201) {
      // TODO: доделать
      print('Перезагрузить этот экран');
      return true;
    }
    return false;
  }

}

