import 'package:flutter/material.dart';
import 'package:flutter_s3_app/providers/contract_payments_provider.dart';
import 'package:flutter_s3_app/models/room_summary.dart';
import 'package:provider/provider.dart';

import '../forms/payment_form.dart';
import '../widgets/payment_list.dart'; // Обратите внимание на имя файла
// Если файл называется payments_list.dart, переименуйте его в payment_list.dart или наоборот

class ContractPaymentsComponent extends StatelessWidget {
  final RoomSummary room;

  const ContractPaymentsComponent({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final paymentsProvider = Provider.of<ContractPaymentsProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Комната ${room.id}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          paymentsProvider.isLoading
              ? CircularProgressIndicator()
              : PaymentList(payments: paymentsProvider.payments),
          SizedBox(height: 20),
          PaymentForm(roomId: room.id),
        ],
      ),
    );
  }
}