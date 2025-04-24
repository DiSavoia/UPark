import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: InicioPage()));

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  static const primaryColor = Color(0xFF1E90FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo_upark_a.png',
                height: 125,
              ),
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    print('Ir a Iniciar Sesión');
                  },
                  child: const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('o'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    side: BorderSide.none,
                  ),
                  onPressed: () {
                    print('Ir a Registro');
                  },
                  child: const Text('Registrate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}