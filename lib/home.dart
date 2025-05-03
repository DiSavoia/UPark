import 'package:flutter/material.dart';
import 'package:upark/search.dart';
import 'package:upark/favorites.dart';
import 'package:upark/parking_management.dart';
import 'package:upark/settings.dart';
import 'package:upark/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const primaryColor = Color(0xFF1E90FF);
  int _selectedIndex = 0; // Starting with search tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed from the previous screen
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final username = arguments?['username'] ?? 'Nombre Apellido';
    final email = arguments?['email'] ?? 'nombreapellido@gmail.com';
    final phone = arguments?['phone'] ?? '+54 11 1234-5678';
    final isManager = arguments?['is_manager'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _getSelectedScreen(username, email, phone, isManager),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.map, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Navigation bar removed as requested
    );
  }

  Widget _getSelectedScreen(
    String username,
    String email,
    String phone,
    bool isManager,
  ) {
    switch (_selectedIndex) {
      case 0:
        return const SearchPage();
      case 1:
        return isManager
            ? const ParkingManagementPage()
            : const FavoritesPage();
      case 2:
        return const SettingsPage();
      case 3:
        return ProfilePage(
          username: username,
          email: email,
          phone: phone,
          isManager: isManager,
        );
      default:
        return const Center(
          child: Text('Página no encontrada', style: TextStyle(fontSize: 20)),
        );
    }
  }
}
