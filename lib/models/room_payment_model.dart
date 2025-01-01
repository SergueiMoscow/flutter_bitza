import 'package:intl/intl.dart';

class RoomPaymentModel {
  final String room;
  final String date;
  final String? bankAccount;
  final String? bookAccount;
  final int amount;
  final int discount;
  final int total;

  RoomPaymentModel(
      {required this.room,
        required this.date,
      required this.bankAccount,
      required this.bookAccount,
      required this.amount,
      required this.discount,
      required this.total});

  factory RoomPaymentModel.fromJson(Map<String, dynamic> json) {
    return RoomPaymentModel(
        room: json['room'],
        date: json['date'],
        bankAccount: json['bank_account'] ?? 'Not defined',
        bookAccount: json['book_account'] ?? 'Not defined',
        amount: json['amount'],
        discount: json['discount'] ?? 0,
        total: json['total']);
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      final formatter = DateFormat('dd.MM.yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return date;
    }
  }
}
