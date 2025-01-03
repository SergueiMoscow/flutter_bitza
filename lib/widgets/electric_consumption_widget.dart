import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../api/auth_api.dart';
import '../models/electric_consumption_model.dart'; // Для форматирования дат

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({super.key});

  @override
  _ConsumptionPageState createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  ConsumptionResponse? _consumptionData;
  String? _errorMessage;

  final AuthApiService _apiService = AuthApiService(); // Инициализируй свой сервис

  @override
  void initState() {
    super.initState();
    // Устанавливаем начальные даты: начало периода - 1 месяц назад, конец периода - сегодня
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate!.year, _endDate!.month - 1, _endDate!.day);
    // Загружаем данные при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConsumption();
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _fetchConsumption() async {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _errorMessage = 'Пожалуйста, выберите обе даты.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _consumptionData = null;
    });

    // Форматируем даты
    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    try {
      final response = await _apiService.authenticatedRequest(
        endpoint: '/api/electricity/consumption/?date_begin=$startDateStr&date_end=$endDateStr',
        method: 'GET',
        headers: {'Content-Type': 'application/json'},
        // Передаём параметры как query_parameters
        body: {
          'date_begin': startDateStr,
          'date_end': endDateStr,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _consumptionData = ConsumptionResponse.fromJson(data);
        });
      } else {
        setState(() {
          _errorMessage =
          'Ошибка: ${response.statusCode} ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Произошла ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Форматированные строки для отображения дат
    final startDateText = _startDate != null
        ? 'Начало: ${DateFormat('dd.MM.yyyy').format(_startDate!)}'
        : 'Выберите дату начала';
    final endDateText = _endDate != null
        ? 'Конец: ${DateFormat('dd.MM.yyyy').format(_endDate!)}'
        : 'Выберите дату конца';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Выбор даты начала
            Row(
              children: [
                Expanded(
                  child: Text(
                    startDateText,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectStartDate(context),
                  child: Text('Выбрать'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Выбор даты конца
            Row(
              children: [
                Expanded(
                  child: Text(
                    endDateText,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectEndDate(context),
                  child: Text('Выбрать'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Кнопка отправки запроса
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchConsumption,
              child: _isLoading
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text('Загрузить данные'),
            ),
            SizedBox(height: 16),
            // Отображение ошибки, если есть
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            // Отображение графика
            if (_consumptionData != null) _buildChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final data = _consumptionData!.results;
    if (data.isEmpty) {
      return Text('Нет данных для отображения.');
    }

    final maxY = data.map((e) => e.consumption).reduce((a, b) => a > b ? a : b);

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        // title: AxisTitle(text: 'Комнаты'),
        labelRotation: 45,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Потребление'),
        minimum: 0,
        maximum: maxY * 1.2,
        interval: (maxY * 1.2) / 5, // Корректируем интервал
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <BarSeries<RoomConsumption, String>>[
        BarSeries<RoomConsumption, String>(
          dataSource: data,
          xValueMapper: (RoomConsumption result, _) => result.room,
          yValueMapper: (RoomConsumption result, _) => result.consumption,
          // Используем pointColorMapper для задания индивидуальных цветов колонок
          pointColorMapper: (RoomConsumption result, _) => result.colorValue,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          width: 0.9,
          spacing: 0.1,
        )
      ],
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: 'Потребление электроэнергии по комнатам'),
    );
  }
}