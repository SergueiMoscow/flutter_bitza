import 'dart:ui';

import 'package:flutter/material.dart';

class ConsumptionResponse {
  final String dateBegin;
  final String dateEnd;
  final List<RoomConsumption> results;

  ConsumptionResponse({
    required this.dateBegin,
    required this.dateEnd,
    required this.results,
  });

  factory ConsumptionResponse.fromJson(Map<String, dynamic> json) {
    return ConsumptionResponse(
      dateBegin: json['date_begin'],
      dateEnd: json['date_end'],
      results: List<RoomConsumption>.from(
        json['results'].map((x) => RoomConsumption.fromJson(x)),
      ),
    );
  }
}

class RoomConsumption {
  final String room;
  final double consumption;
  final String color;

  RoomConsumption({
    required this.room,
    required this.consumption,
    required this.color,
  });

  factory RoomConsumption.fromJson(Map<String, dynamic> json) {
    return RoomConsumption(
      room: json['room'],
      consumption: (json['consumption'] as num).toDouble(),
      color: json['color'],
    );
  }
  Color get colorValue {
    // Убедимся, что строка цвета начинается с '#'
    if (color.startsWith('#')) {
      String hex = color.substring(1); // Убираем '#'

      // Проверяем длину строки, ожидаем 8 символов (RRGGBBAA)
      if (hex.length == 8) {
        // Извлекаем компоненты цвета
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        final a = int.parse(hex.substring(6, 8), radix: 16);

        // Создаём цвет в формате ARGB
        return Color.fromARGB(a, r, g, b);
      } else if (hex.length == 6) {
        // Если без альфа, добавляем полностью непрозрачный альфа-канал
        return Color(int.parse('0xff$hex', radix: 16));
      } else {
        // Некорректная длина строки, задаём цвет по умолчанию
        return Colors.blue;
      }
    } else {
      // Если строка не начинается с '#', задаём цвет по умолчанию
      return Colors.blue;
    }
  }

}