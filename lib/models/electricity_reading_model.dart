class ElectricityReading {
  final String shortname;
  final String name;
  final String? date;
  final double? kwtCount;

  ElectricityReading({
    required this.shortname,
    required this.name,
    this.date,
    this.kwtCount,
  });

  factory ElectricityReading.fromJson(Map<String, dynamic> json) {
    return ElectricityReading(
      shortname: json['shortname'],
      name: json['name'],
      date: json['date'],
      kwtCount: json['kwt_count'] != null ? double.tryParse(json['kwt_count']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': shortname,
      'name': name,
      'date': date,
      'kwt_count': kwtCount,
    };
  }
}
