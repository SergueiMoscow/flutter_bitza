import 'package:flutter/material.dart';
import 'package:flutter_s3_app/models/room_payment_model.dart';

class PaymentList extends StatelessWidget {
  final List<RoomPaymentModel> payments;
  const PaymentList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Text('Нет оплат');
    }
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          child: ListTile(
            title: Text('Счёт ${payment.bankAccount}'),
            subtitle: Text('Дата ${payment.formattedDate}'),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Сумма: ${payment.amount.toString()}'),
                Text('Скидка: ${payment.discount.toString()}'),
                Text(
                  payment.total.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}