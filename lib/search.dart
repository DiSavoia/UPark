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

  final String _apiKey = 'TU_API_KEY_AQUI';

  void _onChanged(String value) {
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

    Navigator.pop(context, {
      'coordenadas': LatLng(lat, lon),
      'direccion': displayName,
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
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
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                labelText: 'Escribí una dirección',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
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
