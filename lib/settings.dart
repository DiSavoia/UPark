import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UPARK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 20,
                ),
              ),
              Text(
                'Configuración',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            _buildSettingsButton(context, 'Cerrar Sesión', () {
              _showLogoutDialog(context);
            }),
            SizedBox(height: 20),
            _buildSettingsButton(context, 'Notificaciones', () {
              // Navigate to notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Configuración de notificaciones')),
              );
            }),
            SizedBox(height: 20),
            _buildSettingsButton(context, 'Políticas de Privacidad', () {
              // Navigate to privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Políticas de Privacidad')),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/start',
                  (route) => false,
                );
              },
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
