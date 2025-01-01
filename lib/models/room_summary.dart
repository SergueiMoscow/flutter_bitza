class RoomSummary {
  final String id;
  final double debtMonths;
  final String debtStatus;

  RoomSummary(
      {required this.id, required this.debtMonths, required this.debtStatus});

  factory RoomSummary.fromJson(Map<String, dynamic> json) {
    return RoomSummary(
        id: json['name'],
        debtMonths: double.parse(json['debt_month']),
        debtStatus: json['html_class']);
  }
}
