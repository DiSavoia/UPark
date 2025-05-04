//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:location/location.dart' as location;
//import 'package:http/http.dart' as http;
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late location.Location locationService;
  late MapController mapController;
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> route = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    locationService = location.Location();
    mapController = MapController();
    requestLocationPermission();  // Solicitar permisos de ubicación al inicio
  }

  Future<void> requestLocationPermission() async {
    // Solicitar permisos de ubicación
    permission_handler.PermissionStatus permissionStatus = await permission_handler.Permission.locationWhenInUse.request();
    if (permissionStatus.isGranted) {
      initializeLocation();  // Si se concede permiso, inicializar la ubicación
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de ubicación denegado")),
        );
      }
    }
  }

  Future<void> initializeLocation() async {
    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        return; // Si no se habilita, no continuar
      }
    }

    // Verificar si el permiso de ubicación está concedido
    location.PermissionStatus permissionGranted = await locationService.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await locationService.requestPermission();
      if (permissionGranted != location.PermissionStatus.granted) {
        return; // Si no se concede permiso, no continuar
      }
    }

    // Obtener la ubicación actual
    location.LocationData userLocation = await locationService.getLocation();

    // Asegurarse de que la ubicación se haya obtenido correctamente antes de actualizar el estado
    if (mounted) {
      setState(() {
        currentLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
        isLoading = false;  // Deja de mostrar el indicador de carga
      });
    }
  }



  /*
  Future<void> fetchCoordinatesPoints(String location) async {
    final url = Uri.parse("https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);

        setState(() {
          destination = LatLng(lat, lon);
        });
        await fetchRoute();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron coordenadas.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener coordenadas. Código: ${response.statusCode}')),
      );
    }
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null || destination == null) {
      return;
    }
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
          '${currentLocation!.longitude},${currentLocation!.latitude};'
          '${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      decodePolyline(geometry);
    } else {
      // Muestra un mensaje de error usando un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ruta. Código: ${response.statusCode}')),
      );
    }
  }

  void decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
    setState(() {
      route = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
    });
  }
  */

  Future<void> userCurrentLocation() async {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15); // Mueve el mapa a la ubicación actual
    } else {
      // Si currentLocation es nulo, se espera a que se obtenga la ubicación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún estamos obteniendo tu ubicación...')),
      );
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

    /*
    // Si estamos cargando la ubicación, mostrar el indicador de carga
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  */

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? LatLng(-34.6037, -58.3816), // Buenos Aires
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: const Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
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
                      icon: const Icon(Icons.favorite_border),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pushNamed(context, '/favorites');
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
