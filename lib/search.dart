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
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  final String _apiKey = 'pk.0340df42008e68b8520d43d331742ce1';

  int _starsIndex = 0;
  int _priceIndex = 0;
  int _distanceIndex = 0;

  bool _showFilters = false;

  void _onChanged(String value) {
    // Oculta filtros cuando escribís
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

    int distanciaMetros = (_distanceIndex == 10) ? 1100 : (_distanceIndex + 1) * 100;
    int? precioMax = (_priceIndex == 10) ? null : (_priceIndex + 1) * 500;
    int estrellas = _starsIndex + 1;

    Navigator.pop(context, {
      'coordenadas': LatLng(lat, lon),
      'direccion': displayName,
      'distancia': distanciaMetros,
      'precio': precioMax,
      'estrellas': estrellas,
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
        const Text(
          'Estrellas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      index + 1,
                          (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
                    ),
                  ),
                  selected: _starsIndex == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _starsIndex = index;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            }),
          ),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(11, (int index) {
              final label = index < 10 ? '\$${(index + 1) * 500}' : '+\$5000';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: _priceIndex == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _priceIndex = index;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distancia (metros)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(11, (int index) {
              final label = index < 10 ? '${(index + 1) * 100}' : '+1000';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: _distanceIndex == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _distanceIndex = index;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar dirección'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                labelText: 'Dirección de destino',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Botón Filtros
            ElevatedButton.icon(
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtros'),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),

            // Panel filtros - aparece solo si _showFilters == true
            if (_showFilters) ...[
              const SizedBox(height: 12),
              _buildStarsFilter(),
              const SizedBox(height: 12),
              _buildPriceFilter(),
              const SizedBox(height: 12),
              _buildDistanceFilter(),
              const SizedBox(height: 12),
            ],

            // Resultado o loading
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
