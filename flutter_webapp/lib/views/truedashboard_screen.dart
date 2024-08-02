import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class TrueDashboardScreen extends StatefulWidget {
  @override
  _TrueDashboardScreenState createState() => _TrueDashboardScreenState();
}

class _TrueDashboardScreenState extends State<TrueDashboardScreen> {
  late WebSocketChannel channel;
  int totalStations = 0;
  int disconnectedStations = 0;
  List<List<String>> tableData = [];
  List<String> statistics = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _fetchData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _connectToWebSocket();
      _fetchData();
    });
  }

  void _fetchData() {
    channel =
        WebSocketChannel.connect(Uri.parse('wss://itt363-6.smar.com.do/ws'));
    channel.sink.add(jsonEncode({'type': 'fetch', 'page': 1}));
    channel.stream.listen((data) {
      final response = jsonDecode(data);
      if (response['total_count'] > 0) {
        setState(() {
          _processData(response['data_for_stats']);
          tableData = response['data'].map<List<String>>((doc) {
            return [
              doc['station_id'].toString(),
              doc['temperature'].toString(),
              doc['wind_speed'].toString() + ' km/h',
              doc['wind_direction'].toString()
            ];
          }).toList();
        });
      }
    });
  }

  void _connectToWebSocket() {
    channel =
        WebSocketChannel.connect(Uri.parse('wss://itt363-6.smar.com.do/ws'));
    channel.sink.add(jsonEncode({'type': 'getStations'}));
    channel.stream.listen((data) {
      final response = jsonDecode(data);
      if (response['status'] == 'success') {
        setState(() {
          totalStations = response['data'].length;
          disconnectedStations = totalStations -
              1; // Assuming one station is always disconnected for demonstration
        });
      }
    });
  }

  void _processData(dynamic rawData) {
    List<dynamic> data =
        rawData as List<dynamic>; // Asegura que rawData es una lista
    if (data.isEmpty) return;

    double totalTemp = 0;
    double maxTemp = double.negativeInfinity;
    double minTemp = double.infinity;
    double maxWindSpeed = double.negativeInfinity;
    double totalHumidity = 0;
    double maxHumidity = double.negativeInfinity;
    double minHumidity = double.infinity;
    double totalPrecipitation = 0;
    double presionpromedio = 0;

    for (var doc in data) {
      double temp = doc['temperature'] ?? 0;
      double windSpeed = doc['wind_speed'] ?? 0;
      double humidity = doc['humidity'] ?? 0;
      double precipitation = doc['rainfall'] ?? 0;
      double presion = doc['atmospheric_pressure'] ?? 0;

      presionpromedio += presion;

      totalTemp += temp;
      if (temp > maxTemp) maxTemp = temp;
      if (temp < minTemp) minTemp = temp;

      if (windSpeed > maxWindSpeed) maxWindSpeed = windSpeed;

      totalHumidity += humidity;
      if (humidity > maxHumidity) maxHumidity = humidity;
      if (humidity < minHumidity) minHumidity = humidity;

      totalPrecipitation += precipitation;
    }

    int count = data.length;
    setState(() {
      statistics = [
        'Temperatura promedio: ${totalTemp / count}',
        'Maxima Temperatura Registrada: $maxTemp',
        'Minima Temperatura Registrada: $minTemp',
        'Velocidad máxima del viento: ${maxWindSpeed}km/s',
        'Humedad promedio: ${totalHumidity / count}%',
        'Máxima Humedad Registrada: $maxHumidity%',
        'Mínima Humedad Registrada: $minHumidity%',
        'Precipitación Total: $totalPrecipitation mm',
        'Presión promedio: ${presionpromedio / count}'
      ];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de estaciones',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryCard(
                      'Estaciones Disponibles', '$totalStations', Colors.blue),
                  _buildSummaryCard('Estaciones Conectadas', '1', Colors.green),
                  _buildSummaryCard('Estaciones Desconectadas',
                      '$disconnectedStations', Colors.red),
                ],
              ),
              SizedBox(height: 16),
              _buildSectionHeader('Ultimas mediciones'),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildDataTable(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildStatisticsCard('Estadisticas', statistics),
                        SizedBox(height: 16),
                        //_buildAlertCard('Alertas Emitidas', '3'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      color: Color(0xFFE3F2F1), // Color de fondo
      child: Container(
        width: 250,
        height: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 3,
      color: Color(0xFFE3F2F1), // Color de fondo
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(100),
            2: FixedColumnWidth(100),
            3: FixedColumnWidth(100),
          },
          children: [
            _buildTableRow([
              'Estacion ID',
              'Temperatura',
              'Velocidad del viento',
              'Direccion del viento'
            ], isHeader: true),
            ...tableData.map((row) => _buildTableRow(row)).toList(),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.map((cell) {
        return Container(
          color: isHeader ? Colors.grey[200] : Colors.white,
          padding: EdgeInsets.all(8),
          child: Text(
            cell,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatisticsCard(String title, List<String> stats) {
    return Card(
      elevation: 3,
      color: Color(0xFFE3F2F1), // Color de fondo
      child: Container(
        width: double.infinity,
        //height: 200, // Aumentar la altura
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...stats.map((stat) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(stat),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String value) {
    return Card(
      elevation: 3,
      color: Color(0xFFE3F2F1), // Color de fondo
      child: Container(
        width: double.infinity,
        //height: 100, // Ajustar la altura
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications, size: 32),
                SizedBox(width: 8),
                Text(value,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
