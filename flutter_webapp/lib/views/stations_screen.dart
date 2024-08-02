import 'package:flutter/material.dart';
import 'package:proyectointegrador/services/station_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:proyectointegrador/widgets/station_dashboard.dart';
import 'dart:convert';

class StationsScreen extends StatefulWidget {
  @override
  _StationsScreenState createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final StationService _service = StationService();
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://itt363-6.smar.com.do/ws'),
  );
  List<dynamic> stations = [];
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  void _fetchStations() {
    final data = {
      'type': 'getStations',
    };
    channel.sink.add(json.encode(data));
    channel.stream.listen((message) {
      final response = json.decode(message);
      setState(() {
        print(response['data']);
        stations = response['data'];
        _initializeNextId();
      });
    }, onError: (error) {
      print('Error: $error');
    });
  }

  void _initializeNextId() {
    if (stations.isNotEmpty) {
      _nextId = stations
              .map((s) => int.parse(s['station_id']))
              .reduce((a, b) => a > b ? a : b) +
          1;
    }
  }

  void _showCreateOrUpdateDialog({Map<String, dynamic>? station}) {
    TextEditingController nameController =
        TextEditingController(text: station?['station_name'] ?? '');
    TextEditingController locationController =
        TextEditingController(text: station?['station_location'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(station == null ? 'Create New Station' : 'Update Station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(station == null ? 'Create' : 'Update'),
              onPressed: () {
                if (station == null) {
                  _createStation(nameController.text, locationController.text);
                } else {
                  _updateStation(station['station_id'], nameController.text,
                      locationController.text);
                }
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _createStation(String name, String location) {
    final stationId = _nextId.toString();
    final data = {
      'type': 'createStation',
      'station_id': stationId,
      'station_name': name,
      'station_location': location,
    };
    channel.sink.add(json.encode(data));
    _nextId++;
    setState(() {
      stations.add({
        'station_id': stationId,
        'station_name': name,
        'station_location': location
      });
    });
  }

  void _updateStation(String id, String name, String location) {
    final data = {
      'type': 'updateStation',
      'station_id': id,
      'station_name': name,
      'station_location': location,
    };
    channel.sink.add(json.encode(data));
    _fetchStations(); // Refresh the UI after updating
  }

  void _deleteStation(String id) {
    final data = {
      'type': 'deleteStation',
      'station_id': id,
    };
    channel.sink.add(json.encode(data));
    _fetchStations(); // Refresh the UI after deleting
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meteorological Stations'),
      ),
      body: stations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: stations
                  .map((station) => Card(
                        child: ListTile(
                          title: Text(
                              '${station['station_name']} (ID: ${station['station_id']})'),
                          subtitle: Text(
                              'Location: ${station['station_location']}\nCreated: ${station['creation_date']}}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _showCreateOrUpdateDialog(station: station),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteStation(station['station_id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOrUpdateDialog(),
        tooltip: 'Add Station',
        child: Icon(Icons.add),
      ),
    );
  }
}
