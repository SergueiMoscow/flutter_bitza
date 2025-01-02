// widgets/electricity_form.dart

import 'package:flutter/material.dart';
import '../api/electricity_api.dart';
import '../models/electricity_reading.dart';
import 'dart:async';

class ElectricityForm extends StatefulWidget {
  const ElectricityForm({super.key});

  @override
  _ElectricityFormState createState() => _ElectricityFormState();
}

class _ElectricityFormState extends State<ElectricityForm> {
  final ElectricityService _electricityService = ElectricityService();
  late Future<List<ElectricityReading>> _futureReadings;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _futureReadings = _electricityService.fetchLatestReadings();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Если есть ошибки валидации, не отправляем данные
      return;
    }

    List<ElectricityReading> newReadings = [];

    _controllers.forEach((shortname, controller) {
      final input = controller.text.trim();
      if (input.isNotEmpty) {
        final reading = ElectricityReading(
          shortname: shortname,
          name: '', // Имя можно передать дополнительно если нужно
          kwtCount: double.parse(input),
          date: DateTime.now().toIso8601String().split('T')[0],
        );
        newReadings.add(reading);
      } else {
        // Если поле пустое, можно передать null или пропустить
      }
    });

    bool success = await _electricityService.addReadings(newReadings);

    // bool allSuccess = true;
    // for (var reading in newReadings) {
    //   bool success = await _electricityService.addReading(reading);
    //   if (!success) {
    //     allSuccess = false;
    //     // Можно добавить уведомление об ошибке
    //   }
    // }

    if (success) {
      // Уведомление об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Показания успешно отправлены!')),
      );
      // Обновляем данные
      setState(() {
        _futureReadings = _electricityService.fetchLatestReadings();
        _controllers.clear();
      });
    } else {
      // Уведомление об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке некоторых показаний')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ElectricityReading>>(
      future: _futureReadings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Ошибка: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('Нет данных для отображения'),
          );
        } else {
          final readings = snapshot.data!;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...readings.map((reading) {
                    // Инициализируем контроллеры
                    if (!_controllers.containsKey(reading.shortname)) {
                      _controllers[reading.shortname] = TextEditingController();
                    }
                    final controller = _controllers[reading.shortname]!;

                    // Определяем, нужно ли префиллить поле
                    final today = DateTime.now().toIso8601String().split('T')[0];
                    final isToday = reading.date == today;
                    if (isToday && controller.text.isEmpty) {
                      controller.text = reading.kwtCount?.toString() ?? '';
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RoomReadingWidget(
                        reading: reading,
                        controller: controller,
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Отправить показания'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class RoomReadingWidget extends StatefulWidget {
  final ElectricityReading reading;
  final TextEditingController controller;

  RoomReadingWidget({required this.reading, required this.controller});

  @override
  _RoomReadingWidgetState createState() => _RoomReadingWidgetState();
}

class _RoomReadingWidgetState extends State<RoomReadingWidget> {
  Color borderColor = Colors.grey;
  String? errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    final input = widget.controller.text.trim();
    double? newValue = double.tryParse(input);
    double? oldValue = widget.reading.kwtCount;

    setState(() {
      if (input.isEmpty) {
        borderColor = Colors.grey;
        errorText = null;
      } else if (newValue == null) {
        borderColor = Colors.red;
        errorText = 'Неверный формат';
      } else if (oldValue != null && newValue < oldValue) {
        borderColor = Colors.red;
        errorText = 'Новое значение меньше предыдущего';
      } else {
        borderColor = Colors.green;
        errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reading = widget.reading;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final isToday = reading.date == today;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reading.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text('Дата: '),
            Text(
              reading.date ?? 'нет',
              style: TextStyle(
                color: reading.date != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('Показания: '),
            Text(
              reading.kwtCount?.toString() ?? '0',
              style: TextStyle(
                color: reading.kwtCount != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Новые показания',
            hintText: reading.kwtCount != null ? reading.kwtCount.toString() : 'нет',
            errorText: errorText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Разрешаем пустое значение
            }
            final newValue = double.tryParse(value.trim());
            if (newValue == null) {
              return 'Введите число';
            }
            if (widget.reading.kwtCount != null && newValue < widget.reading.kwtCount!) {
              return 'Новое значение меньше предыдущего';
            }
            return null;
          },
        ),
      ],
    );
  }
}