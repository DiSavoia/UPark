import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Lugar {
  final String nombre;
  final String direccion;
  final String imagen;
  final LatLng coordenadas;

  Lugar({
    required this.nombre,
    required this.direccion,
    required this.imagen,
    required this.coordenadas,
  });
}

class _HomePageState extends State<HomePage> {
  late location.Location locationService;
  late MapController mapController;
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];
  bool isLoading = true;
  bool isManager = false;
  List<Map<String, dynamic>> nearbyPlaces = [];
  Map<String, dynamic>? selectedPlace;

  @override
  void initState() {
    super.initState();
    locationService = location.Location();
    mapController = MapController();
    requestPermissions();  // Solicitar permisos de ubicación al inicio
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('is_manager')) {
      setState(() {
        isManager = args['is_manager'] ?? false;
      });
    }
  }

  // Función para solicitar permisos de ubicación
  Future<void> requestPermissions() async {
    // Verificar si el permiso ya ha sido otorgado
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      // Si el permiso ya está concedido, inicializamos la ubicación
      initializeLocation();
    } else if (status.isDenied) {
      // Si el permiso está denegado, directamente lo solicitamos
      requestPermission();
    } else if (status.isPermanentlyDenied) {
      // Si el permiso ha sido permanentemente denegado, pedir que abran la configuración
      openAppSettings();
    }
  }

  // Función para solicitar el permiso de ubicación
  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      initializeLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permiso de ubicación denegado")),
      );
    }
  }

  // Inicializa la ubicación del usuario
  Future<void> initializeLocation() async {
    bool serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        return; // Si no se habilita el servicio de ubicación, no continuar
      }
    }

    location.LocationData userLocation = await locationService.getLocation();

    if (mounted) {
      setState(() {
        currentLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
        isLoading = false;
      });

      // Mueve el mapa a la ubicación actual
      mapController.move(currentLocation!, 15);
      await loadNearbyPlaces();
    }
  }

  // Función para mover el mapa a la ubicación actual del usuario
  Future<void> userCurrentLocation() async {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún estamos obteniendo tu ubicación...')),
      );
    }
  }

  //Traductor direccion a LatLng
  Future<LatLng?> geocodeAddress(String direccion) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$direccion&format=json&limit=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  //Centra el mapa a una direccion y carga lugares cercanos a esa direccion
  Future<void> loadNearbyPlaces({String? direccionCentro}) async {
    LatLng center;

    if (direccionCentro != null) {
      final coords = await geocodeAddress(direccionCentro);
      if (coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo geocodificar la dirección')),
        );
        return;
      }
      center = coords;
    } else if (currentLocation != null) {
      center = currentLocation!;
    } else {
      return;
    }

    final allPlaces = await obtenerLugaresDesdeBase();

    final Distance distance = Distance();
    List<Map<String, dynamic>> filteredPlaces = [];

    for (var place in allPlaces) {
      final placeCoords = await geocodeAddress(place['direccion']!);
      if (placeCoords != null) {
        final meters = distance(center, placeCoords);
        if (meters <= 10000) {
          filteredPlaces.add({
            'nombre': place['nombre']!,
            'direccion': place['direccion']!,
            'imagen': place['imagen']!,
            'latLng': placeCoords,
          });
        }
      }
    }

    setState(() {
      nearbyPlaces = filteredPlaces;
      if (direccionCentro != null) {
        mapController.move(center, 15);
      }
      selectedPlace = null;
    });
  }


  Future<List<Lugar>> obtenerLugaresConCoordenadas() async {
    final lugaresBase = await obtenerLugaresDesdeBase();

    List<Lugar> lugares = [];

    for (var lugar in lugaresBase) {
      final coords = await geocodeAddress(lugar['direccion']!);
      if (coords != null) {
        lugares.add(
          Lugar(
            nombre: lugar['nombre']!,
            direccion: lugar['direccion']!,
            imagen: lugar['imagen']!,
            coordenadas: coords,
          ),
        );
      }
    }

    return lugares;
  }


  //FALSA BASE DE DATOS
  Future<List<Map<String, String>>> obtenerLugaresDesdeBase() async {
    return [
      {
        'nombre': 'American Century Investments',
        'direccion': '1665 Charleston Road, Mountain View, CA 94043',
        'imagen': 'https://via.placeholder.com/400x200.png?text=Plaza+Central',
      },
      {
        'nombre': 'Algun lugar',
        'direccion': '1075 Terra Bella Avenue, Mountain View, CA 94043',
        'imagen': 'https://via.placeholder.com/400x200.png?text=Cafe+del+Sol',
      },
    ];
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? LatLng(-34.6037, -58.3816),
              initialZoom: 15,
              onTap: (_, __) {
                setState(() {
                  selectedPlace = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.navigation, color: Colors.white),
                  ),
                  markerSize: const Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              MarkerLayer(
                markers: nearbyPlaces
                    .map((place) {
                  final latLng = place['latLng'];

                  if (latLng == null) {
                    return null;
                  }

                  return Marker(
                    point: latLng,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlace = place;
                        });
                      },
                      child: const Icon(
                        Icons.garage,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                })
                    .whereType<Marker>() // Filtra los null para que no entren en la lista
                    .toList(),
              ),

            ],
          ),

          // Segundo botón flotante en esquina inferior derecha
          Positioned(
            bottom: 120,
            right: 10,
            child: SafeArea(
              child: SizedBox(
                height: 70,
                width: 70,
                child: FloatingActionButton(
                  onPressed: currentLocation == null ? null : userCurrentLocation, // Solo habilitar si la ubicación está disponible
                  backgroundColor: Colors.blue,
                  elevation: 2,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.my_location, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),

          //Barra media
          if (selectedPlace != null)
            Positioned(
              bottom: 140,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: Nombre + dirección + botón cerrar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${selectedPlace!['nombre']} - ${selectedPlace!['direccion']}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPlace = null;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (selectedPlace!['imagen'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          selectedPlace!['imagen'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Acción adicional
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // color azul
                        minimumSize: const Size(double.infinity, 35), // ancho completo, alto 35
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Más información',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),


          // Barra superior blanca con logo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 80,
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/logo_upark_a.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Bottom bar
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
                        Navigator.pushNamed(context, '/search');
                      },
                    ),
                    IconButton(
                      icon: Icon(isManager ? Icons.edit : Icons.favorite_border),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        if (isManager) {
                          // Navigate to edit page or perform edit action
                        } else {
                          Navigator.pushNamed(context, '/favorites');
                        }
                      },
                    ),
                    const SizedBox(width: 80), // espacio para FAB central
                    IconButton(
                      icon: const Icon(Icons.settings),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Primer botón flotante central
      floatingActionButton: SizedBox(
        height: 150,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            // Acción del botón flotante central
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
