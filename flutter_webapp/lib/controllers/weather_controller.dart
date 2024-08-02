import 'dart:async';
import 'dart:convert';
import 'package:proyectointegrador/models/station.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/weather_data.dart';

class WeatherController {
  WebSocketChannel? channel;
  Timer? timer;
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  int currentInterval = 600; // Default interval in seconds
  final List<int> intervalOptions = [10, 30, 60, 300, 600];

  void initWebSocket() {
    channel =
        WebSocketChannel.connect(Uri.parse('wss://itt363-6.smar.com.do/ws'));
    channel!.stream.listen(
      (message) {
        final parsedMessage = jsonDecode(message);
        handleReceivedData(parsedMessage);
      },
      onError: (error) {
        isLoading = false;
      },
      onDone: () {
        isLoading = false;
      },
    );
  }

  void handleReceivedData(dynamic parsedMessage) {
    isLoading = true;
    try {
      data.clear();
      for (var item in parsedMessage['data']) {
        data.add({
          'station_id': item['station_id'] ?? 'unknown',
          'temperature': item['temperature'] ?? 0,
          'humidity': item['humidity'] ?? 0,
          'atmospheric_pressure': item['atmospheric_pressure'] ?? 0,
          'rainfall': item['rainfall'] ?? 0,
          'wind_speed': item['wind_speed'] ?? 0,
          'wind_direction': item['wind_direction'] ?? 'unknown',
          'time': item['time'] ?? "n/a",
        });
      }
      isLoading = false;
    } catch (e) {
      print('Error handling data: $e');
      isLoading = false;
    }
  }

  void refreshData() {
    if (channel != null) {
      channel!.sink.add(jsonEncode({'type': 'fetch'}));
    }
  }

  void setInterval(int seconds) {
    currentInterval = seconds;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: currentInterval), (Timer t) {
      refreshData();
    });
  }

  void reconnectWebSocket() {
    channel?.sink.close();
    initWebSocket();
  }

  void dispose() {
    channel?.sink.close(status.goingAway);
    timer?.cancel();
  }
}
