import 'station.dart';

class WeatherData {
  Station station;
  double temperature;
  double humidity;
  double atmosphericPressure;
  double rainfall;
  double windSpeed;
  String windDirection;
  String time;

  WeatherData({
    required this.station,
    required this.temperature,
    required this.humidity,
    required this.atmosphericPressure,
    required this.rainfall,
    required this.windSpeed,
    required this.windDirection,
    required this.time,
  });
}
