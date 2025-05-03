import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const primaryColor = Color(0xFF1E90FF);
  // This should be configured based on your environment
  // For physical devices, use your computer's IP address instead of localhost
  static const apiBaseUrl = 'http://10.0.2.2:3100/api'; // For Android emulator
  // static const apiBaseUrl = 'http://YOUR_COMPUTER_IP:3200/api'; // For physical devices

  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isManager = ValueNotifier<bool>(false);
  bool _isLoading = false;

  // Function to register user
  Future<void> _registerUser(
    BuildContext context, {
    required String username,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required bool isManager,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
          'password': password,
          'is_manager': isManager,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        // Registration successful
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));

        // Navigate to home and clear previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // This clears all previous routes
          arguments: {
            'username': '$firstName $lastName',
            'email': email,
            'phone': phone,
            'is_manager': isManager,
          },
        );
      } else {
        // Registration failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${responseData['error'] ?? 'Ocurrió un error al registrarse'}',
            ),
          ),
        );
      }
    } catch (e) {
      // Network or other error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo_upark_a.png', height: 125),
                const Text(
                  'Registrarse',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              final username = usernameController.text.trim();
                              final firstName = firstNameController.text.trim();
                              final lastName = lastNameController.text.trim();
                              final phone = phoneController.text.trim();
                              final email = emailController.text.trim();
                              final pass1 = passwordController.text;
                              final pass2 = confirmPasswordController.text;

                              if (username.isEmpty ||
                                  firstName.isEmpty ||
                                  lastName.isEmpty ||
                                  phone.isEmpty ||
                                  email.isEmpty ||
                                  pass1.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Todos los campos son obligatorios',
                                    ),
                                  ),
                                );
                              } else if (pass1 != pass2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Las contraseñas no coinciden',
                                    ),
                                  ),
                                );
                              } else if (!email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'El correo electrónico no es válido',
                                    ),
                                  ),
                                );
                              } else {
                                _registerUser(
                                  context,
                                  username: username,
                                  firstName: firstName,
                                  lastName: lastName,
                                  phone: phone,
                                  email: email,
                                  password: pass1,
                                  isManager: isManager.value,
                                );
                              }
                            },
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
