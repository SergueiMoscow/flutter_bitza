import 'package:intl/intl.dart';

String formatDate(String dateStr) {
  try {
    DateTime date = DateTime.parse(dateStr);
    // Устанавливаем локаль на русский
    Intl.defaultLocale = 'ru_RU';
    // Форматируем дату, например, "1 февраля 2025"
    String formattedDate = DateFormat('d MMMM yyyy', 'ru').format(date);
    return formattedDate;
  } catch (e) {
    // Если строка даты некорректна, вернуть оригинальную строку
    return dateStr;
  }
}