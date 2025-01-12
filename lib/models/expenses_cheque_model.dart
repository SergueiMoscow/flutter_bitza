class ExpensesChequeModel {
  final int id;
  final String fileName;
  final DateTime purchaseDate;
  final String user;
  final String seller;
  final String account;
  final double total;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpensesChequeModel({
    required this.id,
    required this.fileName,
    required this.purchaseDate,
    required this.user,
    required this.seller,
    required this.account,
    required this.total,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpensesChequeModel.fromJson(Map<String, dynamic> json) {
    return ExpensesChequeModel(
      id: json['id'],
      fileName: json['file_name'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      user: json['user'],
      seller: json['seller'],
      account: json['account'],
      total: json['total'].toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}