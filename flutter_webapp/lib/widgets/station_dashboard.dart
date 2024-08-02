import 'package:flutter/material.dart';

class StationDashboard extends StatelessWidget {
  final Map<String, dynamic> stationData;

  StationDashboard({required this.stationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard for Station ${stationData['station_id']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Station ID: ${stationData['station_id']}'),
            Divider(),
            Text('Measurements:',
                style: Theme.of(context).textTheme.headlineMedium),
            _buildMeasurementCard('Temperature', '${27} °C'),
            _buildMeasurementCard('Humidity', '${23} %'),
            _buildMeasurementCard('Atmospheric Pressure', '${4} hPa'),
            _buildMeasurementCard('Rainfall', '11 mm'),
            _buildMeasurementCard('Wind Speed', '${8} km/h'),
            _buildMeasurementCard('Wind Direction', '127'),
            _buildMeasurementCard('Time', '06/21/2024'),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard(String label, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
