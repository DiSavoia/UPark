import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:latlong2/latlong.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _allParkings = [];
  List<dynamic> _filteredParkings = [];
  bool _isLoading = false;
  int? userId;

  static const String apiBaseUrl = 'http://18.218.68.253/api';

  int _starsIndex = 0;
  double _precioActual = 4500;
  int _distanciaKm = 2;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        userId = args['id'];
      }
    });
    _loadAllParkings();
  }

  void _loadAllParkings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/parkings'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _allParkings = data['data'];
            _filteredParkings = List.from(_allParkings);
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
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error loading parkings: $e");
    }
  }

  void _onChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _filteredParkings = List.from(_allParkings);
      });
    } else {
      setState(() {
        _filteredParkings =
            _allParkings.where((parking) {
              final name = (parking['name'] ?? '').toString().toLowerCase();
              final address =
                  (parking['address'] ?? '').toString().toLowerCase();
              final searchTerm = value.toLowerCase();

              return name.contains(searchTerm) || address.contains(searchTerm);
            }).toList();
      });
    }
  }

  void _selectParking(dynamic parking) {
    final lat = parking['latitude'];
    final lon = parking['longitude'];

    double? latDouble;
    double? lonDouble;

    if (lat != null) {
      if (lat is double) {
        latDouble = lat;
      } else if (lat is String) {
        latDouble = double.tryParse(lat);
      } else if (lat is int) {
        latDouble = lat.toDouble();
      }
    }

    if (lon != null) {
      if (lon is double) {
        lonDouble = lon;
      } else if (lon is String) {
        lonDouble = double.tryParse(lon);
      } else if (lon is int) {
        lonDouble = lon.toDouble();
      }
    }

    // Parse price and capacity
    double? precio;
    if (parking['hourly_rate'] != null) {
      if (parking['hourly_rate'] is num) {
        precio = (parking['hourly_rate'] as num).toDouble();
      } else if (parking['hourly_rate'] is String) {
        precio = double.tryParse(parking['hourly_rate']);
      }
    }
    int? capacidad;
    if (parking['total_spaces'] != null) {
      if (parking['total_spaces'] is int) {
        capacidad = parking['total_spaces'];
      } else if (parking['total_spaces'] is String) {
        capacidad = int.tryParse(parking['total_spaces']);
      } else if (parking['total_spaces'] is double) {
        capacidad = (parking['total_spaces'] as double).toInt();
      }
    }

    if (latDouble != null && lonDouble != null) {
      Navigator.pop(context, {
        'coordenadas': LatLng(latDouble, lonDouble),
        'direccion':
            parking['address'] ?? parking['name'] ?? 'Unknown location',
        'precio': precio,
        'capacidad': capacidad,
        'estrellas':
            parking['average_rating'] != null
                ? (parking['average_rating'] is int
                    ? parking['average_rating']
                    : int.tryParse(parking['average_rating'].toString()) ?? 5)
                : 5,
        'imagen': parking['image'],
        'name': parking['name'],
        'address': parking['address'],
        'description': parking['description'],
        'hourly_rate': parking['hourly_rate'],
        'total_spaces': parking['total_spaces'],
        'id': parking['id'],
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación no disponible para este estacionamiento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStarsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valoración mínima',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _starsIndex ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _starsIndex = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Precio máximo (ARS)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Slider(
          value: _precioActual,
          min: 1000,
          max: 5500,
          divisions: 9,
          label: '\$${_precioActual.round()}',
          activeColor: const Color(0xFF2196F3),
          inactiveColor: Colors.black26,
          onChanged: (value) {
            setState(() {
              _precioActual = value;
            });
          },
        ),
        Text(
          '\$${_precioActual.round()}',
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildParkingCard(dynamic parking) {
    final rating = parking['average_rating'] ?? 5.0;
    final reviewCount = parking['review_count'] ?? 0;
    final price = parking['hourly_rate']?.toString() ?? 'N/A';
    final address = parking['address'] ?? 'Sin dirección';
    final name = parking['name'] ?? 'Sin nombre';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectParking(parking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ),
                      Text(
                        '\$$price/h',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (reviewCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '$reviewCount reseñas',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buscar estacionamientos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o dirección...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtros'),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                ),
                Text(
                  '${_filteredParkings.length} resultados',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_showFilters) ...[
              _buildStarsFilter(),
              const SizedBox(height: 12),
              _buildPriceFilter(),
              const SizedBox(height: 12),
            ],
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filteredParkings.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No se encontraron estacionamientos',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredParkings.length,
                  itemBuilder: (context, index) {
                    return _buildParkingCard(_filteredParkings[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
