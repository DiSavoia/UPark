import 'package:flutter/material.dart';
import 'package:upark/start.dart';
import 'home.dart';
import 'login.dart';
import 'register.dart';
import 'changePassword.dart';
import 'osm.dart';

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
        '/': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/changePassword': (context) => const ChangePasswordPage(),
        '/home': (context) => const HomePage(),
        '/osm': (context) => const MapView(),
      },
    );
  }
}
