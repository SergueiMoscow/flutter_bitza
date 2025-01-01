class ContractModel {
  final String number;
  final String room;
  final int price;
  final int discount;

  ContractModel({required this.number, required this.room, required this.price, required this.discount});

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      number: json['number'],
      room: json['room'],
      price: json['price'],
      discount: json['discount'],

    );
  }
}