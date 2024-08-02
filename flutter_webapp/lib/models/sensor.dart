class Sensor {
  int id;
  String name;
  String brand;
  String model;
  String readingType;
  dynamic lastReading;

  Sensor({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.readingType,
    this.lastReading,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'readingType': readingType,
      'lastReading': lastReading,
    };
  }

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      readingType: json['readingType'],
      lastReading: json['lastReading'],
    );
  }
}
