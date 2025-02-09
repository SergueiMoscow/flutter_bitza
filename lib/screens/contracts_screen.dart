import 'package:flutter/material.dart';

import '../api/contract_api.dart';
import '../components/common_app_bar.dart';
import '../models/contract_print_response.dart';
import '../widgets/contract_list_item.dart';

class ContractsScreen extends StatefulWidget {
  @override
  _ContractsScreenState createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  late Future<List<ContractPrintResponse>> _contractsFuture;

  @override
  void initState() {
    super.initState();
    _contractsFuture = ContractPrintApi().fetchContractPrintResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      body: FutureBuilder<List<ContractPrintResponse>>(
        future: _contractsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Пока данные загружаются
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // В случае ошибки
            return Center(child: Text('Ошибка загрузки данных (${snapshot.error})'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Если данных нет
            return Center(child: Text('Нет доступных договоров'));
          } else {
            // Если данные успешно загружены
            final contracts = snapshot.data!;
            return ListView.builder(
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                final contract = contracts[index];
                return ContractListItem(contract: contract);
              },
            );
          }
        },
      ),
    );
  }
}