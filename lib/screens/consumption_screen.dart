import 'package:flutter/material.dart';

import '../components/common_app_bar.dart';
import '../widgets/electric_consumption_widget.dart';

class ConsumptionScreen extends StatelessWidget {
  const ConsumptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: ConsumptionPage(),
    );
  }
}
