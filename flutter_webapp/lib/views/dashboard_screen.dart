import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:proyectointegrador/widgets/station_dashboard.dart'; // Importa el widget del dashboard de la estación
import '../widgets/side_menu.dart'; // Importa el widget del menú lateral

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Data Dashboard',
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WebSocketChannel? channel;
  Timer? _timer;
  int _interval = 600;
  List<Map<String, dynamic>> _data = [];
  List<dynamic> _stations = [];
  int _currentPage = 1; // Empezar desde la página 1
  final int _rowsPerPage = 10;
  int _totalRecords = 0; // Total de registros obtenidos del servidor
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _selectedStation;

  final List<int> _intervalOptions = [10, 30, 60, 300, 600];

  @override
  void dispose() {
    channel?.sink.close(status.goingAway);
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage([String? message]) {
    setState(() {
      _isLoading = true;
    });
    // Envía la solicitud con la página actual
    channel?.sink.add(jsonEncode({'type': 'fetch', 'page': _currentPage}));
    setState(() {
      _isLoading = false;
    });
  }

  void _setInterval(int seconds) {
    _timer?.cancel();
    _interval = seconds;
    _timer = Timer.periodic(Duration(seconds: _interval), (timer) {
      _sendMessage();
    });
  }

  void _handleReceivedData(dynamic parsedMessage) {
    try {
      setState(() {
        _isLoading = true;
        _totalRecords = parsedMessage['total_count'];
        _data
            .clear(); // Limpia los datos existentes para cargar la nueva página
        for (var item in parsedMessage['data']) {
          _data.add({
            'station_id': item['station_id'] ?? 'unknown',
            'temperature': item['temperature'] ?? 0.0,
            'humidity': item['humidity'] ?? 0.0,
            'atmospheric_pressure': item['atmospheric_pressure'] ?? 0.0,
            'rainfall': item['rainfall'] ?? 0.0,
            'wind_speed': item['wind_speed'] ?? 0.0,
            'wind_direction': item['wind_direction'] ?? 'unknown',
            'time': item['time'] ?? "n/a",
          });
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error handling data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _connectWebSocket() {
    channel =
        WebSocketChannel.connect(Uri.parse('wss://itt363-6.smar.com.do/ws'));

    channel!.stream.listen((message) {
      final parsedMessage = jsonDecode(message);
      if (parsedMessage['data'] != null &&
          parsedMessage['total_count'] == null) {
        _handleStationsData(parsedMessage);
      } else {
        _handleReceivedData(parsedMessage);
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _handleStationsData(dynamic parsedMessage) {
    try {
      setState(() {
        _stations = parsedMessage['data'];
      });
    } catch (e) {
      print('Error handling stations data: $e');
    }
  }

  void _fetchStations() {
    channel?.sink.add(jsonEncode({'type': 'getStations'}));
  }

  void _showNoNewDataAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No hay datos nuevos'),
          content: Text('No hay datos nuevos para mostrar.'),
          actions: [
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _setInterval(_interval);
    _fetchStations();
  }

  int get _totalPages => (_totalRecords / _rowsPerPage).ceil();

  List<DataRow> _buildRows() {
    return _data.map((data) {
      return DataRow(cells: [
        DataCell(Text(data['station_id'].toString())),
        DataCell(Text(data['temperature'].toString())),
        DataCell(Text(data['humidity'].toString())),
        DataCell(Text(data['atmospheric_pressure'].toString())),
        DataCell(Text(data['rainfall'].toString())),
        DataCell(Text(data['wind_speed'].toString())),
        DataCell(Text(data['wind_direction'].toString())),
        DataCell(Text(data['time'].toString())),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Data '),
      ),
      //drawer: SideMenu(), // Incluye el menú lateral aquí
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => _sendMessage(),
                  child: Text('Refrescar'),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _interval,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _setInterval(value);
                      });
                    }
                  },
                  items: _intervalOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(_getDropdownText(value)),
                    );
                  }).toList(),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _connectWebSocket,
                  child: Text('Reconectar'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Station ID')),
                    DataColumn(label: Text('Temperature')),
                    DataColumn(label: Text('Humidity')),
                    DataColumn(label: Text('Pressure')),
                    DataColumn(label: Text('Rainfall')),
                    DataColumn(label: Text('Wind Speed')),
                    DataColumn(label: Text('Wind Direction')),
                    DataColumn(label: Text('Time')),
                  ],
                  rows: _buildRows(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                            _sendMessage();
                          });
                        }
                      : null,
                ),
                Text('Página ${_currentPage} de $_totalPages'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: (_currentPage < _totalPages)
                      ? () {
                          setState(() {
                            _currentPage++;
                            _sendMessage();
                          });
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDropdownText(int value) {
    switch (value) {
      case 10:
        return '10 segundos';
      case 30:
        return '30 segundos';
      case 60:
        return '1 minuto';
      case 300:
        return '5 minutos';
      case 600:
        return '10 minutos';
      default:
        return '';
    }
  }
}
