import 'package:flutter/material.dart';
import 'package:flutter_s3_app/components/common_app_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: const Center(
        child: Text('Добро пожаловать!'),
      ),
    );
  }
}