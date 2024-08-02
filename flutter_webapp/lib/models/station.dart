import 'sensor.dart';

class Station {
  String id;
  String name;
  String location;
  DateTime creationDate;
  DateTime? lastReadingDate;
  bool isConnected;
  List<Sensor>? sensors;

  Station({
    required this.id,
    required this.name,
    required this.location,
    required this.creationDate,
    this.lastReadingDate,
    required this.isConnected,
    this.sensors,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'creationDate': creationDate.toIso8601String(),
      'lastReadingDate': lastReadingDate?.toIso8601String(),
      'isConnected': isConnected,
      'sensors': sensors?.map((sensor) => sensor.toJson()).toList(),
    };
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      creationDate: DateTime.parse(json['creationDate']),
      lastReadingDate: json['lastReadingDate'] != null
          ? DateTime.parse(json['lastReadingDate'])
          : null,
      isConnected: json['isConnected'],
      sensors: (json['sensors'] as List<dynamic>?)
          ?.map((sensor) => Sensor.fromJson(sensor))
          .toList(),
    );
  }
}
