import 'package:flutter/material.dart';

// Parking model class
class Parking {
  final String name;
  final String address;
  final int spots;

  Parking({required this.name, required this.address, required this.spots});
}

class ParkingManagementPage extends StatefulWidget {
  const ParkingManagementPage({super.key});

  @override
  State<ParkingManagementPage> createState() => _ParkingManagementPageState();
}

class _ParkingManagementPageState extends State<ParkingManagementPage> {
  static const primaryColor = Color(0xFF1E90FF);
  List<Parking> _parkings = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Estacionamientos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddParkingDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nuevo',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _parkings.isEmpty
                  ? const Center(
                    child: Text(
                      'No tienes estacionamientos registrados',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _parkings.length,
                    itemBuilder: (context, index) {
                      final parking = _parkings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(parking.name),
                          subtitle: Text(parking.address),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                ),
                                onPressed:
                                    () =>
                                        _showEditParkingDialog(parking, index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteParking(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  void _showAddParkingDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final spotsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar Estacionamiento'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  TextField(
                    controller: spotsController,
                    decoration: const InputDecoration(
                      labelText: 'Lugares disponibles',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    setState(() {
                      _parkings.add(
                        Parking(
                          name: nameController.text,
                          address: addressController.text,
                          spots: int.tryParse(spotsController.text) ?? 0,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
  }

  void _showEditParkingDialog(Parking parking, int index) {
    final nameController = TextEditingController(text: parking.name);
    final addressController = TextEditingController(text: parking.address);
    final spotsController = TextEditingController(
      text: parking.spots.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Estacionamiento'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  TextField(
                    controller: spotsController,
                    decoration: const InputDecoration(
                      labelText: 'Lugares disponibles',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    setState(() {
                      _parkings[index] = Parking(
                        name: nameController.text,
                        address: addressController.text,
                        spots: int.tryParse(spotsController.text) ?? 0,
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _deleteParking(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Estacionamiento'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este estacionamiento?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _parkings.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
