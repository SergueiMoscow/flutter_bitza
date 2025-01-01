import 'package:flutter_s3_app/models/bank_account_model.dart';
import 'package:flutter_s3_app/models/contract_model.dart';
import 'package:flutter_s3_app/models/room_payment_model.dart';

class ContractPaymentsResponse {
  final ContractModel contract;
  final List<RoomPaymentModel> payments;
  final List<BankAccountModel> bankAccounts;

  ContractPaymentsResponse({
    required this.contract,
    required this.payments,
    required this.bankAccounts,
  });

  factory ContractPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return ContractPaymentsResponse(
      contract: ContractModel.fromJson(json['contract']),
      payments: (json['payments'] as List)
          .map((payment) => RoomPaymentModel.fromJson(payment))
          .toList(),
      bankAccounts: (json['bank_accounts'] as List)
        .map((account) => BankAccountModel.fromJson(account))
        .toList(),
    );
  }
}
