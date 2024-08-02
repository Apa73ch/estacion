import 'package:flutter/material.dart';
import 'views/dashboard_screen.dart';
import 'views/login_screen.dart';
import 'views/main_screen.dart';
import 'views/stations_screen.dart';
// Importa las demás pantallas que necesites

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherWAD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        //'/dashboard': (context) => DashboardScreen(),
        //'/usuarios': (context) => UsersScreen(),
        //'/mantenimiento': (context) => MaintenanceScreen(),
        //'/alertas': (context) => AlertsScreen(),
        //'/exportar': (context) => ExportScreen(),
      },
    );
  }
}
