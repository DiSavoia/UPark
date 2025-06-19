import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reviews.dart';

class MoreInfo extends StatefulWidget {
  const MoreInfo({super.key});

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  bool _isFavorited = false;
  bool _isLoading = false;
  int? userId;
  int? parkingId;

  static const String apiBaseUrl = 'http://18.218.68.253/api';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('MoreInfo received args: $args');
    if (args != null) {
      userId = args['user_id'];
      parkingId = args['id'];
      print('User ID: $userId, Parking ID: $parkingId');
      _checkIfFavorited();
    }
  }

  Future<void> _checkIfFavorited() async {
    if (parkingId == null || userId == null) {
      print('Missing data - User ID: $userId, Parking ID: $parkingId');
      return;
    }

    try {
      final url =
          '$apiBaseUrl/favorites/check?user_id=$userId&parking_id=$parkingId';
      print('Checking favorite status at: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        'Check favorite response: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _isFavorited = data['is_favorited'];
          });
          print('Is favorited: $_isFavorited');
        }
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    print('Toggle favorite called - User ID: $userId, Parking ID: $parkingId');
    if (parkingId == null || userId == null) {
      print('Cannot toggle - missing data');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = '$apiBaseUrl/favorites';
      final body = {'user_id': userId, 'parking_id': parkingId};

      print(
        'Sending ${_isFavorited ? 'DELETE' : 'POST'} to $url with body: $body',
      );

      final response =
          _isFavorited
              ? await http.delete(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(body),
              )
              : await http.post(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(body),
              );

      print(
        'Toggle favorite response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isFavorited = !_isFavorited;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFavorited
                    ? 'Agregado a favoritos'
                    : 'Eliminado de favoritos',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar favoritos')),
          );
        }
      }
    } catch (e) {
      print('Error in toggle favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parking =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (parking == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Más Información')),
        body: Center(child: Text('No hay datos del estacionamiento')),
      );
    }

    return Scaffold(
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
                'Mas Información',
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
      ),
      body: SingleChildScrollView(
        child: Column(children: [_buildParkingCard(context, parking)]),
      ),
    );
  }

  Widget _buildParkingCard(BuildContext context, Map<String, dynamic> parking) {
    return Card(
      margin: EdgeInsets.all(10),
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
                    parking['imagen'] != null && parking['imagen'] != ''
                        ? Image.network(
                          parking['imagen'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'assets/estacionamiento.png',
                          height: 200,
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
                        (parking['estrellas'] ?? '5').toString(),
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
                  onTap: _isLoading ? null : _toggleFavorite,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            )
                            : Icon(
                              _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 24,
                            ),
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
                  '${parking['name'] ?? ''} - ${parking['address'] ?? parking['direccion'] ?? ''}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.local_parking),
                  label: Text(
                    'Cantidad de Plazas Disponibles: 1/${parking['total_spaces'] ?? parking['capacidad'] ?? ''}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
                SizedBox(height: 16),
                if (parking['description'] != null &&
                    parking['description'] != '')
                  Text(parking['description'], style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text(
                  'Precio por hora: \$${parking['hourly_rate'] ?? parking['precio'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text('Dueño: Nombre Apellido', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text(
                  'Horario de atención: 7hs - 24hs',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Medios de contacto:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Teléfono: 123-4789',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '• Whatsapp: 11-1234-6789',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Métodos de pago:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('• Efectivo', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Reviews(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Leer Reviews'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
