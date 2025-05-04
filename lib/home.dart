import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
    requestPermissions();  // Solicitar permisos de ubicación al inicio
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
                    child: Icon(Icons.navigation, color: Colors.white),
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
