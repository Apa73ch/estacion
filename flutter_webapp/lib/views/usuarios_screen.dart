import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  DateTime _fechaCreacion = DateTime.now();
  late WebSocketChannel channel;
  final String wsUrl = 'wss://itt363-6.smar.com.do/ws';

  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
    _fetchUsers();
  }

  void connectToWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  void sendMessage(String message) {
    if (channel != null) {
      channel.sink.close(); // Cierra la conexión actual
      connectToWebSocket(); // Reconecta al WebSocket
      channel.sink.add(message); // Envía el mensaje
      listenToResponse(); // Escucha la respuesta
    }
  }

  void listenToResponse() {
    channel.stream.listen((data) {
      // Procesa la data recibida
      print("Received: $data");
    }, onDone: () {
      // Se ejecuta cuando el stream se cierra
      print("Stream closed");
    }, onError: (error) {
      print("Error: $error");
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  int? _selectedIndex;

  void _guardarUsuario() {
    if (_nombreController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _usuarioController.text.isEmpty) {
      _mostrarError('Por favor, completa todos los campos requeridos.');
      return;
    }

    Map<String, dynamic> updates = {
      'nombre': _nombreController.text,
      'telefono': _telefonoController.text,
      'username': _usuarioController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    };

    Map<String, dynamic> userData = {
      'nombre': _nombreController.text,
      'telefono': _telefonoController.text,
      'username': _usuarioController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    };

    if (_selectedIndex == null) {
      // Crear un nuevo usuario
      userData['type'] = 'createUser';
    } else {
      // Actualizar un usuario existente
      userData['type'] = 'updateUser';
      userData['id'] = _usuarios[_selectedIndex ?? -1]
          ['_id']; // Asumiendo que cada usuario tiene un '_id'
      userData['updates'] = updates;
    }

    // Enviando la información al WebSocket
    if (channel != null) {
      channel.sink.close();
    }
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    channel.sink.add(json.encode(userData));

    // Escuchando la respuesta del servidor
    channel.stream.listen((data) {
      final response = json.decode(data);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_selectedIndex == null
                  ? 'Usuario creado exitosamente!'
                  : 'Usuario actualizado exitosamente!')),
        );
        _fetchUsers(); // Recargar la lista de usuarios
        _selectedIndex = null; // Resetear el índice seleccionado
        _limpiarCampos();
      } else {
        _mostrarError(response['message']);
      }
    });
  }

  void _fetchUsers() {
    if (channel != null) {
      channel.sink.close();
    }
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    channel.sink.add(jsonEncode({'type': 'getUsers'}));
    channel.stream.first.then((data) {
      final response = jsonDecode(data);
      if (response['status'] == 'success') {
        setState(() {
          _usuarios = List<Map<String, dynamic>>.from(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _mostrarError("Error al cargar usuarios.");
      }
    });
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
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

  void _eliminarUsuario() {
    if (_selectedIndex != null) {
      final String wsUrl =
          'wss://itt363-6.smar.com.do/ws'; // Asegúrate de que la URL es correcta
      Map<String, dynamic> selectedUser = _usuarios[_selectedIndex!];

      if (channel != null) {
        channel.sink.close();
      }
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Enviar solicitud para eliminar el usuario
      channel.sink.add(jsonEncode({
        'type': 'deleteUser',
        'id': selectedUser[
            '_id'] // Asegúrate de que '_id' está correctamente almacenado y utilizado
      }));

      channel.stream.listen((data) {
        final response = jsonDecode(data);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Usuario eliminado exitosamente!')));
          // Actualiza el estado para eliminar el usuario de la lista después de confirmar la eliminación
          setState(() {
            _usuarios.removeAt(_selectedIndex!);
            _selectedIndex = null;
            _limpiarCampos();
          });
        } else {
          _mostrarError(response['message']);
        }
      }, onDone: () {
        // Cerrar el canal cuando el stream se haya completado
        channel.sink.close();
      }, onError: (error) {
        _mostrarError('Error al conectar con el servidor');
        print(error);
      });
    }
  }

  void _editarUsuario(int index) {
    if (_selectedIndex == index) {
      // Si el índice seleccionado es el mismo, significa que estamos enviando una actualización
      Map<String, dynamic> userData = {
        'type': 'updateUser',
        'id': _usuarios[index][
            '_id'], // Asegúrate de que el ID está disponible en el mapa del usuario
        'updates': {
          'nombre': _nombreController.text,
          'apellido': _telefonoController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'username': _usuarioController.text
        }
      };

      // Enviando la información al WebSocket
      channel.sink.add(json.encode(userData));

      // Escuchando la respuesta del servidor
      channel.stream.listen((data) {
        final response = json.decode(data);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario actualizado exitosamente!')),
          );
          _fetchUsers(); // Recargar la lista de usuarios después de una actualización
        } else {
          _mostrarError(response['message']);
        }
      });

      // Resetear el índice seleccionado y limpiar los campos
      _limpiarCampos();
      setState(() {
        _selectedIndex = null;
      });
    } else {
      // Cargando datos del usuario en los campos del formulario para editar
      setState(() {
        _selectedIndex = index;
        Map<String, dynamic> usuario = _usuarios[index];
        _nombreController.text = usuario['nombre'] ?? '';
        _passwordController.text = usuario['password'] ?? '';
        _telefonoController.text = usuario['apellido'] ?? '';
        _emailController.text = usuario['email'] ?? '';
        _usuarioController.text = usuario['username'] ?? '';
        _fechaCreacion = DateTime.parse(usuario['fecha_creacion']!);
      });
    }
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _passwordController.clear();
    _telefonoController.clear();
    _emailController.clear();
    _usuarioController.clear();
    _fechaCreacion = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInputTable(),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _guardarUsuario,
                  child:
                      Text(_selectedIndex == null ? 'Guardar' : 'Actualizar'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _eliminarUsuario,
                  child: Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildRegisteredUsersTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInputTable() {
    return Card(
      elevation: 3,
      color: Color(0xFFE3F2F1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
          },
          children: [
            _buildTableRow('Nombre', _nombreController),
            _buildTableRow('Apellido', _telefonoController),
            _buildTableRow('Password', _passwordController, isPassword: true),
            _buildTableRow('Email', _emailController),
            _buildTableRow('Usuario', _usuarioController),
            _buildTableRow(
              'Fecha de Creación',
              TextEditingController(text: _formatDate(_fechaCreacion)),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, TextEditingController controller,
      {bool enabled = true, bool isPassword = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            enabled: enabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisteredUsersTable() {
    return Expanded(
      child: Card(
        elevation: 3,
        color: Color(0xFFE3F2F1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuarios Registrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(),
                    columnWidths: {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(3),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Nombre',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Apellido',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Password',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Email',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Usuario',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Fecha de Creación',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ..._usuarios.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> user = entry.value;
                        return TableRow(
                          children: [
                            GestureDetector(
                              onTap: () => _editarUsuario(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(user['nombre'] ?? ''),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editarUsuario(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(user['apellido'] ?? ''),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editarUsuario(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(user['password'] ?? ''),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editarUsuario(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(user['email'] ?? ''),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editarUsuario(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(user['username'] ?? ''),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editarUsuario(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_formatDate(
                                    DateTime.parse(user['fecha_creacion']!))),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
