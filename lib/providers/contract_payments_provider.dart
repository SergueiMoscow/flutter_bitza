import 'package:flutter/cupertino.dart';
import 'package:flutter_s3_app/api/rent_api.dart';
import 'package:flutter_s3_app/models/bank_account_model.dart';
import 'package:flutter_s3_app/models/contract_model.dart';
import 'package:flutter_s3_app/models/room_payment_model.dart';

class ContractPaymentsProvider with ChangeNotifier {
  final String roomId;
  ContractModel? _contract;
  List<RoomPaymentModel> _payments = [];
  List<BankAccountModel> _bankAccounts = [];

  ContractModel? get contract => _contract;
  List<RoomPaymentModel> get payments => _payments;
  List<BankAccountModel> get bankAccounts => _bankAccounts;
  bool _isLoading = false;

  ContractPaymentsProvider({required this.roomId});

  bool get isLoading => _isLoading;

  Future<void> fetchRoomPayments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await RentApiService().fetchRoomWithContractPayments(roomId);
      _contract = response.contract;
      _payments = response.payments;
      _bankAccounts = response.bankAccounts;
    } catch (e) {
      _contract = null;
      _payments = [];
      _bankAccounts = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPayment({
    required String roomId,
    required double amount,
    required DateTime date,
    int? discount, // Добавлено поле скидки
    String? bankAccount,
    String? bookAccount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Конвертация и установка скидки
      int amountInt = amount.toInt();
      int discountInt = discount ?? 0;

      RoomPaymentModel newPayment = await RentApiService().addPayment(
        roomId: roomId,
        date: date.toIso8601String(),
        amount: amountInt,
        discount: discountInt, // Передача скидки
        bankAccount: bankAccount,
        bookAccount: bookAccount,
      );
      _payments.add(newPayment);
    } catch (error) {
      // Обработка ошибок при добавлении платежа
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}