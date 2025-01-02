import 'package:flutter/material.dart';
import 'package:flutter_s3_app/components/common_app_bar.dart';

import '../forms/electricity_form.dart';

class ElectricMeterScreen extends StatelessWidget {
  const ElectricMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: ElectricityForm(),
    );
  }
}
