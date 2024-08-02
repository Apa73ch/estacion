import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final Function(int) onItemTapped;

  SideMenu({required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFE3F2F1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud, size: 50, color: Colors.blue),
                SizedBox(height: 10),
                Text(
                  'WeatherWAD',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Usuarios'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Ver Lecturas'), // Nueva opción para ver lecturas
            onTap: () {
              Navigator.pop(context);
              onItemTapped(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: Text('Mantenimiento'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(3);
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Alertas'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(4);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Exportar'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(5);
            },
          ),
        ],
      ),
    );
  }
}
