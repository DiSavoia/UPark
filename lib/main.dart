import 'package:flutter/material.dart';
import 'package:upark/splash.dart';
import 'package:upark/start.dart';
import 'home.dart';
import 'login.dart';
import 'register.dart';
import 'changePassword.dart';
import 'search.dart';
import 'settings.dart';
import 'favorites.dart';
import 'profile.dart';
import 'reviews.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash', // 🔹 Empieza aquí
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/changePassword': (context) => const ChangePasswordPage(),
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
        '/favorites': (context) => const Favorites(),
        '/profile': (context) => const ProfilePage(),
        '/reviews': (context) => const Reviews(),
      },
    );
  }
}
