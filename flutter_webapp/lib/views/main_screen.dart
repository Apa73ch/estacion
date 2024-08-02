import 'package:flutter/material.dart';
import 'package:proyectointegrador/views/alertas_screen.dart';
import 'package:proyectointegrador/views/exportar_screen.dart';
import 'package:proyectointegrador/views/truedashboard_screen.dart';
import 'package:proyectointegrador/views/usuarios_screen.dart';
import '../widgets/side_menu.dart'; // Importa el widget del menú lateral
import 'dashboard_screen.dart'; // Importa la pantalla del dashboard (lecturas)
import 'stations_screen.dart'; // Importa la pantalla de estaciones
import 'login_screen.dart'; // Importa la pantalla de login

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    TrueDashboardScreen(), // Nueva pantalla del dashboard
    UsuariosScreen(),
    DashboardScreen(), // Pantalla de lecturas
    StationsScreen(),
    AlertasScreen(),
    ExportarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Mostrar un cuadro de diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar cierre de sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ); // Redirige a la pantalla de inicio de sesión
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WeatherWAD'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar sesión'),
                ),
              ];
            },
            icon: Icon(Icons.people),
          ),
        ],
      ),
      drawer: SideMenu(
          onItemTapped: _onItemTapped), // Pasa la función al menú lateral
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
