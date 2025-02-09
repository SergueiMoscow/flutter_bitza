class ContactName {
  final String? surname;
  final String? name;

  ContactName({required this.surname, required this.name});

  factory ContactName.fromJson(Map<String, dynamic> json) {
    return ContactName(
      surname: json['surname'] as String?,
      name: json['name'] as String?,
    );
  }
}

class ContractPrintResponse {
  final String number;
  final String status;
  final String dateBegin;
  final String latestPrint;
  final String statusDescription;
  final ContactName contact;
  final String room;
  final String? recommendedContractDate;

  ContractPrintResponse({
    required this.number,
    required this.status,
    required this.dateBegin,
    required this.latestPrint,
    required this.statusDescription,
    required this.contact,
    required this.room,
    this.recommendedContractDate,
  });

  factory ContractPrintResponse.fromJson(Map<String, dynamic> json) {
    // print('Parsing ContractPrintResponse: $json');
    return ContractPrintResponse(
      number: json['number'] as String,
      status: json['status'] as String,
      dateBegin: json['date_begin'] as String,
      latestPrint: (json['latest_prints'] as List<dynamic>).isNotEmpty
          ? json['latest_prints'][0]['date'] as String
          : json['date_begin'] as String,
      statusDescription: json['status_description'] as String,
      contact: ContactName.fromJson(json['contact'] as Map<String, dynamic>),
      room: json['room'] as String,
      recommendedContractDate:  json['recommended_contract_date'] as String?,
    );
  }
}