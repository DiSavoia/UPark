import 'dart:convert';
import 'dart:ui' as ui;
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
  final String direccion;
  final LatLng coordenadas;
  final double precio;
  final int capacidad;
  final int estrellas;
  final String imagenUrl;

  Lugar({
    required this.direccion,
    required this.coordenadas,
    required this.precio,
    required this.capacidad,
    required this.estrellas,
    required this.imagenUrl,
  });

  factory Lugar.fromMap(Map<String, dynamic> map) {
    return Lugar(
      direccion: map['direccion'] ?? '',
      coordenadas: LatLng(
        (map['latitud'] as num).toDouble(),
        (map['longitud'] as num).toDouble(),
      ),
      precio:
          double.tryParse(
            map['precio'].toString().replaceAll(RegExp(r'[^0-9\\.]'), ''),
          ) ??
          0.0,
      capacidad:
          map['capacidad'] is int
              ? map['capacidad']
              : int.tryParse(map['capacidad']?.toString() ?? '') ?? 0,
      estrellas:
          map['estrellas'] is int
              ? map['estrellas']
              : int.tryParse(map['estrellas']?.toString() ?? '') ?? 5,
      imagenUrl: map['image'] ?? '',
    );
  }
}

class _HomePageState extends State<HomePage> {
  late location.Location locationService;
  late MapController mapController;
  LatLng? currentLocation;
  bool isLoading = true;
  bool isManager = false;
  Marker? searchMarker;

  // User data for profile
  String username = 'Nombre Apellido';
  String email = 'nombreapellido@gmail.com';
  String phone = '+54 11 1234-5678';
  int? userId;

  List<Map<String, dynamic>> nearbyPlaces = [];
  Map<String, dynamic>? selectedPlace;
  static const apiBaseUrl = 'http://18.218.68.253/api';

  @override
  void initState() {
    super.initState();
    locationService = location.Location();
    mapController = MapController();
    requestPermissions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentLocation == null) {
        loadNearbyPlaces();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        isManager = args['is_manager'] ?? false;
        username = args['username'] ?? 'Nombre Apellido';
        email = args['email'] ?? 'nombreapellido@gmail.com';
        phone = args['phone'] ?? '+54 11 1234-5678';
        userId = args['id'];
      });
    }
  }

  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      await initializeLocation();
    } else if (status.isDenied) {
      await requestPermission();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await initializeLocation();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de ubicación denegado")),
        );
      }
    }
  }

  Future<void> initializeLocation() async {
    bool serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) return;
    }

    final userLocation = await locationService.getLocation();

    if (mounted) {
      setState(() {
        currentLocation = LatLng(
          userLocation.latitude!,
          userLocation.longitude!,
        );
        isLoading = false;
      });

      mapController.move(currentLocation!, 15);

      await loadNearbyPlaces();
    }
  }

  Future<void> userCurrentLocation() async {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún estamos obteniendo tu ubicación...')),
      );
    }
  }

  Future<LatLng?> geocodeAddress(String direccion) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$direccion&format=json&limit=1',
    );
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

  Future<void> loadNearbyPlaces({
    String? direccion,
    LatLng? coordenadas,
    int? distancia,
    int? precio,
    int? estrellas,
  }) async {
    try {
      LatLng? center;

      if (direccion != null) {
        final coords = await geocodeAddress(direccion);
        if (coords == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo geocodificar la dirección'),
              ),
            );
          }
          return;
        }
        center = coords;
      } else if (currentLocation != null) {
        center = currentLocation!;
      }

      final lugares = await obtenerLugaresDesdeBase(
        coordenadas: coordenadas,
        distancia: distancia,
        precio: precio,
        estrellas: estrellas,
      );

      List<Map<String, dynamic>> lugaresT = [];

      for (var lugar in lugares) {
        lugaresT.add({
          'direccion': lugar.direccion,
          'coordenadas': lugar.coordenadas,
          'precio': lugar.precio,
          'capacidad': lugar.capacidad,
          'estrellas': lugar.estrellas,
          'imagen': lugar.imagenUrl,
        });
      }

      if (mounted) {
        setState(() {
          nearbyPlaces = lugaresT;
          if (direccion != null && center != null) {
            mapController.move(center, 15);
          }
          selectedPlace = null;
        });
      }
    } catch (e) {
      print('Error loading parkings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar estacionamientos')),
        );
      }
    }
  }

  Future<List<Lugar>> obtenerLugaresDesdeBase({
    LatLng? coordenadas,
    int? distancia,
    int? precio,
    int? estrellas,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/parkings');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> data = responseData['data'];

        return data.map<Lugar>((lugarJson) {
          return Lugar(
            direccion: lugarJson['address'] ?? 'Dirección no disponible',
            coordenadas: LatLng(
              double.parse(lugarJson['latitude'].toString()),
              double.parse(lugarJson['longitude'].toString()),
            ),
            precio:
                double.tryParse(
                  lugarJson['hourly_rate'].toString().replaceAll(
                    RegExp(r'[^0-9\\.]'),
                    '',
                  ),
                ) ??
                0.0,
            capacidad:
                lugarJson['total_spaces'] is int
                    ? lugarJson['total_spaces']
                    : int.tryParse(
                          lugarJson['total_spaces']?.toString() ?? '',
                        ) ??
                        0,
            estrellas:
                lugarJson['average_rating'] is int
                    ? lugarJson['average_rating']
                    : int.tryParse(
                          lugarJson['average_rating']?.toString() ?? '',
                        ) ??
                        5,
            imagenUrl: lugarJson['image'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } else {
      throw Exception('Error al obtener los lugares desde la base de datos');
    }
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
              initialCenter:
                  currentLocation ?? LatLng(-34.6037, -58.3816), // Buenos Aires
              initialZoom: 15,
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
                markers: [
                  for (var place in nearbyPlaces)
                    if (place['coordenadas'] != null)
                      Marker(
                        point: place['coordenadas'] as LatLng,
                        width:
                            (selectedPlace != null &&
                                    selectedPlace!['coordenadas'] ==
                                        place['coordenadas'])
                                ? 60
                                : 50,
                        height:
                            (selectedPlace != null &&
                                    selectedPlace!['coordenadas'] ==
                                        place['coordenadas'])
                                ? 70
                                : 60,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPlace = {
                                'direccion': place['direccion'],
                                'coordenadas': place['coordenadas'],
                                'precio': place['precio'],
                                'capacidad': place['capacidad'],
                                'estrellas': place['estrellas'],
                                'imagen': place['imagen'],
                              };
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width:
                                    (selectedPlace != null &&
                                            selectedPlace!['coordenadas'] ==
                                                place['coordenadas'])
                                        ? 50
                                        : 40,
                                height:
                                    (selectedPlace != null &&
                                            selectedPlace!['coordenadas'] ==
                                                place['coordenadas'])
                                        ? 50
                                        : 40,
                                decoration: BoxDecoration(
                                  color:
                                      (selectedPlace != null &&
                                              selectedPlace!['coordenadas'] ==
                                                  place['coordenadas'])
                                          ? Colors.orange
                                          : Colors.blue,
                                  shape: BoxShape.circle,
                                  border:
                                      (selectedPlace != null &&
                                              selectedPlace!['coordenadas'] ==
                                                  place['coordenadas'])
                                          ? Border.all(
                                            color: Colors.deepOrange,
                                            width: 4,
                                          )
                                          : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (selectedPlace != null &&
                                                  selectedPlace!['coordenadas'] ==
                                                      place['coordenadas'])
                                              ? Colors.orange.withOpacity(0.3)
                                              : Colors.blue.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.local_parking,
                                  color: Colors.white,
                                  size:
                                      (selectedPlace != null &&
                                              selectedPlace!['coordenadas'] ==
                                                  place['coordenadas'])
                                          ? 30
                                          : 24,
                                ),
                              ),
                              CustomPaint(
                                size: Size(10, 10),
                                painter: ArrowPainter(),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ],
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

          // Parking info menu
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedPlace!['direccion'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                selectedPlace!['precio'] != null
                                    ? selectedPlace!['precio'].toString()
                                    : 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.local_parking,
                                color: Colors.blue,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                selectedPlace!['capacidad'] != null
                                    ? selectedPlace!['capacidad'].toString()
                                    : 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                final moreInfoArgs = {
                                  ...selectedPlace!,
                                  'user_id': userId,
                                  'username': username,
                                  'email': email,
                                  'phone': phone,
                                  'is_manager': isManager,
                                };
                                print(
                                  'Navigating to moreInfo with args: $moreInfoArgs',
                                );
                                Navigator.pushNamed(
                                  context,
                                  '/moreInfo',
                                  arguments: moreInfoArgs,
                                );
                              },
                              child: const Text("Más información"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stars badge
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (selectedPlace!['estrellas'] ?? '5').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/search',
                          arguments: {
                            'id': userId,
                            'username': username,
                            'email': email,
                            'phone': phone,
                            'is_manager': isManager,
                          },
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            selectedPlace = result;
                          });
                          if (result['coordenadas'] != null) {
                            mapController.move(result['coordenadas'], 15);
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isManager ? Icons.edit : Icons.favorite_border,
                      ),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        if (isManager) {
                          Navigator.pushNamed(
                            context,
                            '/createParking',
                            arguments: {
                              'id': userId,
                              'username': username,
                              'email': email,
                              'phone': phone,
                              'is_manager': isManager,
                            },
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/favorites',
                            arguments: {
                              'id': userId,
                              'username': username,
                              'email': email,
                              'phone': phone,
                              'is_manager': isManager,
                            },
                          );
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
                        Navigator.pushNamed(
                          context,
                          '/profile',
                          arguments: {
                            'username': username,
                            'email': email,
                            'phone': phone,
                            'id': userId,
                            'is_manager': isManager,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                  heroTag: "locationFab",
                  onPressed:
                      currentLocation == null
                          ? null
                          : userCurrentLocation, // Solo habilitar si la ubicación está disponible
                  backgroundColor: Colors.blue,
                  elevation: 2,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 30,
                  ),
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
          heroTag: "centerFab",
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

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    final path = ui.Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
