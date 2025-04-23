import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const primaryColor = Color(0xFF1E90FF);

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isManager = ValueNotifier<bool>(false);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo_upark_a.png',
                  height: 125,
                ),
                const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Usuario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: isManager,
                  builder: (context, value, child) {
                    return SwitchListTile(
                      title: const Text("¿Es gerente de estacionamiento?"),
                      activeColor: primaryColor,
                      value: value,
                      onChanged: (val) => isManager.value = val,
                    );
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final email = emailController.text.trim();
                      final pass1 = passwordController.text;
                      final pass2 = confirmPasswordController.text;

                      if (pass1 != pass2) {
                        print('Las contraseñas no coinciden');
                      } else if (!email.contains('@')) {
                        print('El correo electrónico no es válido');
                      } else {
                        print('Registrado como:');
                        print('Username: ${usernameController.text}');
                        print('Nombre: ${firstNameController.text}');
                        print('Apellido: ${lastNameController.text}');
                        print('Teléfono: ${phoneController.text}');
                        print('Email: $email');
                        print('Es gerente: ${isManager.value}');
                      }
                    },
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}