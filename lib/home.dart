import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const primaryColor = Color(0xFF1E90FF);

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed from the previous screen
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final username = arguments?['username'] ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Bienvenido, $username',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
