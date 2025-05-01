import 'package:flutter/material.dart';

// Parking model class
class Parking {
  final String name;
  final String address;
  final int spots;

  Parking({required this.name, required this.address, required this.spots});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const primaryColor = Color(0xFF1E90FF);
  int _selectedIndex = 3; // Profile tab selected by default
  List<Parking> _parkings = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed from the previous screen
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final username = arguments?['username'] ?? 'Nombre Apellido';
    final email = arguments?['email'] ?? 'nombreapellido@gmail.com';
    final phone = arguments?['phone'] ?? '+54 11 1234-5678';

    // Use testing flag to override is_manager for testing
    final isManager = arguments?['is_manager'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _getSelectedScreen(username, email, phone, isManager),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.map, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(isManager ? Icons.edit : Icons.favorite_outline),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getSelectedScreen(
    String username,
    String email,
    String phone,
    bool isManager,
  ) {
    switch (_selectedIndex) {
      case 0:
        return const Center(
          child: Text('Búsqueda', style: TextStyle(fontSize: 20)),
        );
      case 1:
        return isManager
            ? _buildParkingManagementTab()
            : const Center(
              child: Text('Favoritos', style: TextStyle(fontSize: 20)),
            );
      case 2:
        return const Center(
          child: Text('Configuración', style: TextStyle(fontSize: 20)),
        );
      case 3:
        return _buildProfileTab(username, email, phone, isManager);
      default:
        return const Center(
          child: Text('Página no encontrada', style: TextStyle(fontSize: 20)),
        );
    }
  }

  Widget _buildParkingManagementTab() {
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

  Widget _buildProfileTab(
    String username,
    String email,
    String phone,
    bool isManager,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              "UPARK",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Mi cuenta",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            // Profile avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Personal data button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Datos Personales",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Display phone and email
            Text(phone, style: const TextStyle(fontSize: 16)),
            Text(email, style: const TextStyle(fontSize: 16)),
            // Only show parking section if user is a manager
            if (isManager) ...[
              const SizedBox(height: 16),
              // Parking data button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Datos Estacionamiento",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Parking info fields
              Row(
                children: const [
                  Text('Nombre:', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text('Dirección:', style: TextStyle(fontSize: 16)),
                ],
              ),
            ] else ...[
              // Vehicle data section for non-managers
              const SizedBox(height: 16),
              // Vehicle data button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Datos Vehículo",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Vehicle info fields
              Row(
                children: const [
                  Text('Marca:', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text('Modelo:', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text('Patente:', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
            const SizedBox(height: 120), // Space for FAB
          ],
        ),
      ),
    );
  }
}
