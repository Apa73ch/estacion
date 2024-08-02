import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AlertasScreen extends StatefulWidget {
  @override
  _AlertasScreenState createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://itt363-6.smar.com.do/ws/fetchLatest'),
  );
  List<Map<String, String>> alertas = [];

  @override
  void initState() {
    super.initState();
    fetchLatestData();
  }

  void fetchLatestData() {
    channel.sink.add(jsonEncode({'type': 'fetchLatest'}));
    channel.stream.listen((data) {
      final response = jsonDecode(data);
      processAlertData(response['data']);
    }, onError: (error) {
      print('Error fetching data: $error');
    });
  }

  void processAlertData(List<dynamic> data) {
    double totalWindSpeed = 0;
    double totalRainfall = 0;
    double totalTemperature = 0;
    int count = data.length;

    for (var entry in data) {
      totalWindSpeed += entry['wind_speed'] ?? 0;
      totalRainfall += entry['rainfall'] ?? 0;
      totalTemperature += entry['temperature'] ?? 0;
    }

    double averageWindSpeed = totalWindSpeed / count;
    double averageTemperature = totalTemperature / count;

    setState(() {
      alertas = [];
      if (averageWindSpeed > 35) {
        alertas.add({
          'tipo': 'Advertencia de Tormenta',
          'descripcion':
              'Se espera una tormenta severa con posibilidad de granizo.',
          'fecha': '28/07/2024'
        });
      }
      if (totalRainfall > 2) {
        alertas.add({
          'tipo': 'Alerta de Inundación',
          'descripcion':
              'Riesgo de inundaciones en áreas bajas debido a fuertes lluvias.',
          'fecha': '27/07/2024'
        });
      }
      if (averageTemperature > 35) {
        alertas.add({
          'tipo': 'Aviso de Calor',
          'descripcion':
              'Temperaturas extremadamente altas esperadas durante el día.',
          'fecha': '26/07/2024'
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas Actuales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: alertas.length,
                itemBuilder: (context, index) {
                  final alerta = alertas[index];
                  return Card(
                    elevation: 3,
                    color: Color(0xFFE3F2F1),
                    child: ListTile(
                      leading: Icon(Icons.warning_amber_rounded,
                          color: Colors.redAccent, size: 40),
                      title: Text(alerta['tipo'] ?? 'Tipo de Alerta',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alerta['descripcion'] ??
                              'Descripción de la alerta'),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
