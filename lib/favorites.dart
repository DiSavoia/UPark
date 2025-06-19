import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'moreInfo.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<dynamic> _favorites = [];
  bool _isLoading = true;
  int? userId;

  static const String apiBaseUrl = 'http://18.218.68.253/api';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        userId = args['id'];
        _loadFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/$userId/favorites'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _favorites = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al cargar favoritos')));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión')));
      }
    }
  }

  Future<void> _removeFavorite(int parkingId) async {
    if (userId == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/favorites'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'parking_id': parkingId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _favorites.removeWhere((favorite) => favorite['id'] == parkingId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eliminado de favoritos'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar favorito')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UPARK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 20,
                ),
              ),
              Text(
                'Favoritos',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No tienes favoritos aún',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Agrega estacionamientos a favoritos desde la información detallada',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  return _buildFavoriteParking(context, _favorites[index]);
                },
              ),
    );
  }

  Widget _buildFavoriteParking(BuildContext context, dynamic parking) {
    final rating = parking['average_rating']?.toString() ?? '5';
    final name = parking['name'] ?? 'Sin nombre';
    final address = parking['address'] ?? 'Sin dirección';
    final price = parking['hourly_rate']?.toString() ?? 'N/A';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child:
                    parking['image'] != null && parking['image'] != ''
                        ? Image.network(
                          parking['image'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'assets/estacionamiento.png',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        rating,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _removeFavorite(parking['id']),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '\$$price/hora',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/moreInfo',
                      arguments: {
                        'id': parking['id'],
                        'name': parking['name'],
                        'address': parking['address'],
                        'description': parking['description'],
                        'hourly_rate': parking['hourly_rate'],
                        'total_spaces': parking['total_spaces'],
                        'estrellas': parking['average_rating'],
                        'imagen': parking['image'],
                        'precio': parking['hourly_rate'],
                        'capacidad': parking['total_spaces'],
                        'direccion': parking['address'],
                        'user_id': userId,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text('Más Información'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
