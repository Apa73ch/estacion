import 'package:flutter/material.dart';

class ExportarScreen extends StatefulWidget {
  @override
  _ExportarScreenState createState() => _ExportarScreenState();
}

class _ExportarScreenState extends State<ExportarScreen> {
  String selectedStation = 'Estacion 1';
  String selectedFormat = 'JSON';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void _exportData() {
    // Lógica de exportación según los valores seleccionados
    print('Estación: $selectedStation');
    print('Formato: $selectedFormat');
    print('Fecha de inicio: ${_formatDate(startDate)} ${_formatTime(startDate)}');
    print('Fecha de fin: ${_formatDate(endDate)} ${_formatTime(endDate)}');

    // Aquí puedes agregar la lógica para manejar la exportación real de los datos
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
              'Exportar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              color: Color(0xFFE3F2F1), // Color de fondo
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown('Estacion', selectedStation, ['Estacion 1', 'Estacion 2', 'Estacion 3'], (value) {
                      setState(() {
                        selectedStation = value ?? selectedStation;
                      });
                    }),
                    SizedBox(height: 16),
                    _buildDropdown('Formato', selectedFormat, ['JSON', 'CSV', 'XML'], (value) {
                      setState(() {
                        selectedFormat = value ?? selectedFormat;
                      });
                    }),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildDatePicker('Fecha de inicio', startDate, (date) {
                            setState(() {
                              startDate = date;
                            });
                          }),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDatePicker('Fecha de fin', endDate, (date) {
                            setState(() {
                              endDate = date;
                            });
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _exportData,
                        child: Text('Exportar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildDatePicker(String label, DateTime selectedDate, ValueChanged<DateTime> onDateChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              onDateChanged(pickedDate);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDate(selectedDate)),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        InkWell(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDate),
            );
            if (pickedTime != null) {
              DateTime pickedDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              onDateChanged(pickedDateTime);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(selectedDate)),
                Icon(Icons.access_time),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
