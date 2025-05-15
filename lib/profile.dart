import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Nombre Apellido';
  String phone = '+54 11 1234-5678';
  String email = 'nombreapellido@gmail.com';
  
  // Datos del vehículo (inventados)
  String marca = '';
  String modelo = '';
  String patente = '';

  @override
  void initState() {
    super.initState();
    // Cargar datos del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        username = args['username'] ?? 'Nombre Apellido';
        email = args['email'] ?? 'nombreapellido@gmail.com';
        phone = args['phone'] ?? '+54 11 1234-5678';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('UPARK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20)),
              Text('Mi cuenta', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 16)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Perfil Icon
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.person_outline,
                size: 70,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            // Nombre
            Text(
              username,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            // Datos Personales
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            // Información de contacto
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phone),
                  Text(email),
                ],
              ),
            ),
            
            SizedBox(height: 10),
            
            // Datos Vehículo
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Datos Vehículo',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            // Información de vehículo
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marca:'),
                  Text('Modelo:'),
                  Text('Patente:'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
