import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mapa(),
    );
  }
}

Widget mapa() {
  return FlutterMap(options: MapOptions(
      initialCenter: LatLng(-34.6037, -58.3816),
      initialZoom: 11,
      interactionOptions: InteractionOptions(
          flags: InteractiveFlag.doubleTapZoom | InteractiveFlag.drag
      )
  ),
    children: [
      openStreetMapTileLayer,
      MarkerLayer(markers: [
        Marker(
            point: LatLng(-34.6037, -58.3816),
            width: 60,
            height: 60,
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.location_pin,
              size: 60,
              color: Colors.red,
            )
        )
      ])
    ],
  );
}

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
  userAgentPackageName: "com.upark.map"
);