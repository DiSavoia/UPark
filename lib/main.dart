import 'package:flutter/material.dart';
import 'package:upark/inicio.dart';
import 'home.dart';
import 'login.dart';
import 'register.dart';
import 'olvide_contraseña.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'UPark',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InicioPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/ChangePassword': (context) => const ChangePasswordPage(),
        '/home': (context) => const Home()
      },
    );
  }
}
