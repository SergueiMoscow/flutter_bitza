class BankAccountModel {
  final int id;
  final String name;

  BankAccountModel({required this.id, required this.name});

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'],
      name: json['name'],
    );
  }
}