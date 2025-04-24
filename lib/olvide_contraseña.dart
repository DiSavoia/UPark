import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ChangePasswordPage()));

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  static const primaryColor = Color(0xFF1E90FF);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(),
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
                'Cambiar Contraseña',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmNewPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nueva Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final email = emailController.text.trim();
                    final pass1 = newPasswordController.text;
                    final pass2 = confirmNewPasswordController.text;

                    if (!email.contains('@')) {
                      print('El correo electrónico no es válido');
                    } else if (pass1 != pass2) {
                      print('Las contraseñas no coinciden');
                    } else {
                      print('Contraseña cambiada exitosamente');
                    }
                  },
                  child: const Text('Cambiar Contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}