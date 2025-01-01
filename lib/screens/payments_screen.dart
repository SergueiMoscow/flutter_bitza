import 'package:flutter/material.dart';
import 'package:flutter_s3_app/components/common_app_bar.dart';
// Предположим, что этот провайдер нужен здесь

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return
      // ChangeNotifierProvider<PaymentsProvider>(
      // create: (_) => PaymentsProvider(),
      // child:
      Scaffold(
        appBar: const CommonAppBar(),
        body: Center(
          child: Text('Здесь будет экран оплат'),
        ),
      // ),
    );
  }
}