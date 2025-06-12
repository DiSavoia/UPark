import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:latlong2/latlong.dart';

class SearchPage extends StatefulWidget {
  final int starsIndex;
  final double precioActual;
  final int distanciaKm;

  const SearchPage({
    super.key,
    required this.starsIndex,
    required this.precioActual,
    required this.distanciaKm,
  });


  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;


  final String _apiKey = 'pk.0340df42008e68b8520d43d331742ce1';

  late int _starsIndex;
  late double _precioActual;
  late int _distanciaKm;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _starsIndex = widget.starsIndex;
    _precioActual = widget.precioActual;
    _distanciaKm = widget.distanciaKm;
  }

  void _onChanged(String value) {
    if (_showFilters) {
      setState(() {
        _showFilters = false;
      });
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      _searchSuggestions(value);
    });
  }

  void _searchSuggestions(String value) async {
    if (value.length < 3) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://us1.locationiq.com/v1/search?key=$_apiKey&q=$value&format=json&limit=5',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _suggestions = [];
        });
        debugPrint("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _suggestions = [];
      });
      debugPrint("Error al consultar LocationIQ: $e");
    }
  }

  void _selectSuggestion(dynamic suggestion) {
    final double lat = double.parse(suggestion['lat']);
    final double lon = double.parse(suggestion['lon']);
    final String displayName = suggestion['display_name'];

    int distanciaMetros = _distanciaKm * 500;
    int? precioMax = _precioActual.round();
    int estrellas = _starsIndex;

    Navigator.pop(context, {
      'coordenadas': LatLng(lat, lon),
      'direccion': displayName,
      'distancia': distanciaMetros,
      'precio': precioMax,
      'estrellas': estrellas,
      'filtros': {
        'starsIndex': _starsIndex,
        'precioActual': _precioActual,
        'distanciaKm': _distanciaKm,
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStarsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Valoración', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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
        const Text('Precio máximo (ARS)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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
        Text('\$${_precioActual.round()}', style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Distancia (cuadras aprox.)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        Slider(
          value: _distanciaKm.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_distanciaKm * 500} m',
          activeColor: const Color(0xFF2196F3),
          inactiveColor: Colors.black26,
          onChanged: (value) {
            setState(() {
              _distanciaKm = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return CircleAvatar(
              radius: 8,
              backgroundColor: _distanciaKm == index + 1 ? const Color(0xFF2196F3) : Colors.grey[300],
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buscar dirección', style: TextStyle(color: Colors.black)),
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
                hintText: 'Buscar...',
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
            mainAxisAlignment: MainAxisAlignment.start,
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
            ],
          ),
            const SizedBox(height: 12),
            if (_showFilters) ...[
              _buildStarsFilter(),
              const SizedBox(height: 12),
              _buildPriceFilter(),
              const SizedBox(height: 12),
              _buildDistanceFilter(),
              const SizedBox(height: 12),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(suggestion['display_name']),
                      onTap: () => _selectSuggestion(suggestion),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
