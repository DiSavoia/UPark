// Importa el paquete de Flutter necesario para crear interfaces gráficas
import 'package:flutter/material.dart';

void main() {
  // Punto de entrada de la app: corre la aplicación
  runApp(
    MaterialApp(
      // Título de la aplicación
      title: 'UPark',

      // Tema visual principal de la app
      theme: ThemeData(
        // Define el esquema de colores a partir de un color "semilla"
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E90FF), // Color principal: azul celeste
          // Nota: El azul que usamos se le llama Dodger Blue
          brightness: Brightness.light, // Modo claro
        ),

        // Usa el nuevo diseño Material 3 (más moderno)
        useMaterial3: true,

        // Color de fondo de toda la app
        scaffoldBackgroundColor: Colors.white,

        // Personaliza el estilo de la barra superior (AppBar)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E90FF), // Color de fondo del AppBar
          foregroundColor: Colors.white,      // Color del texto/iconos
          surfaceTintColor: Color(0xFF1E90FF),// Tono de superficie en Material 3
          elevation: 4,                       // Sombra bajo el AppBar
        ),
      ),

      // Define cuál es la primera pantalla que se muestra al iniciar
      home: const HomePage(),
    ),
  );
}

// Esta clase representa la pantalla principal: HomePage
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  // Crea el estado que maneja los datos de esta pantalla
  @override
  State<HomePage> createState() => _HomePageState();
}

// Estado de la HomePage
class _HomePageState extends State<HomePage> {
  // Controladores para leer lo que el usuario escribe
  late final TextEditingController _email;
  late final TextEditingController _password;

  // Se ejecuta cuando el widget se crea por primera vez
  @override
  void initState() {
    _email = TextEditingController();     // Prepara el controlador del email
    _password = TextEditingController();  // Prepara el controlador de contraseña
    super.initState();
  }

  // Se ejecuta cuando el widget se destruye para liberar recursos
  @override
  void dispose() {
    _email.dispose();     // Libera memoria usada por el controlador
    _password.dispose();  // Libera memoria usada por el controlador
    super.dispose();
  }

  // Construye el contenido visual de esta pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con título
      appBar: AppBar(
        title: const Text("Registrarse"), // Título visible en la barra superior
      ),

      // Cuerpo de la pantalla
      body: Center(
        child: SingleChildScrollView( // Hace que la vista sea desplazable
          padding: const EdgeInsets.all(24.0), // Espacio alrededor
          child: Column( // Organiza los elementos en vertical
            mainAxisSize: MainAxisSize.min, // Solo ocupa el espacio necesario
            children: [
              // Campo de texto para el Email
              TextField(
                controller: _email, // Controlador que captura el texto ingresado
                decoration: const InputDecoration(
                  labelText: 'Email',                 // Etiqueta visible
                  border: OutlineInputBorder(),       // Borde alrededor del campo
                ),
                keyboardType: TextInputType.emailAddress, // Tipo de teclado
              ),

              const SizedBox(height: 16), // Espacio vertical

              // Campo de texto para la Contraseña
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Oculta el texto (para contraseñas)
              ),

              const SizedBox(height: 24), // Más espacio

              // Botón para "Registrar"
              SizedBox(
                width: double.infinity, // El botón ocupa tanto ancho como pueda
                child: ElevatedButton(
                  onPressed: () {
                    // Al presionar, imprime los valores ingresados
                    final email = _email.text;
                    final password = _password.text;

                    // Acá se tendría que hacer el proceso de autenticación
                    print('Email: $email');
                    print('Password: $password');
                  },
                  child: const Text('Registrar'), // Texto visible del botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
