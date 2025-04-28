import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/busqueda': (context) => const SearchPage(),
        '/favoritos': (context) => const FavoritesPage(),
        '/configuracion': (context) => const SettingsPage(),
        '/perfil': (context) => const ProfilePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Mapa de fondo
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-34.6037, -58.3816), // Coordenadas de Buenos Aires
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          // Contenido superior, que incluye los botones
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              elevation: 0,
              color: Colors.grey.shade100,
              notchMargin: 8,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/busqueda');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/favoritos');
                      },
                    ),
                    const SizedBox(width: 80), // espacio para el botón flotante
                    IconButton(
                      icon: const Icon(Icons.settings),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/configuracion');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/perfil');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 150,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            // Acción del botón flotante (como centrar en la ubicación)
          },
          backgroundColor: Colors.blue,
          elevation: 2,
          shape: const CircleBorder(),
          child: const Icon(Icons.map, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Aquí tienes ejemplos de las pantallas a las que navegas (esto es opcional).
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Pantalla de búsqueda')));
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Pantalla de favoritos')));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Pantalla de configuración')));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Pantalla de perfil')));
  }
}
