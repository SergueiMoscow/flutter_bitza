import 'package:flutter/material.dart';
import 'package:flutter_s3_app/components/common_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: const Center(child: Text('Profile screen')),
    );
  }
}
