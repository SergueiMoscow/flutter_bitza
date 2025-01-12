import 'package:flutter/material.dart';
import 'package:flutter_s3_app/components/expenses_tabs/expenses_tab_history.dart';
import 'package:flutter_s3_app/components/expenses_tabs/expenses_tab_reports.dart';
import 'package:flutter_s3_app/components/expenses_tabs/expenses_tab_search.dart';

import '../components/common_app_bar.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.history), text: 'История'),
                Tab(icon: Icon(Icons.search), text: 'Поиск'),
                Tab(icon: Icon(Icons.report), text: 'Отчёты'),
              ],
            ),
            Expanded( // Оберните TabBarView в Expanded
              child: TabBarView(
                children: [
                  ExpensesTabHistory(),
                  ExpensesTabSearch(),
                  ExpensesTabReports(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}