import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desoido_app/screens/inicio.dart'; 
import 'package:desoido_app/screens/mapa.dart'; 
import 'package:desoido_app/screens/nivel2.dart'; 
import 'package:desoido_app/screens/nivel3.dart'; 
import 'package:desoido_app/screens/nivel4.dart';
import 'package:desoido_app/screens/nivel5.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Establecer la barra de estado como transparente
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color.fromRGBO(201, 201, 201, 1), // Color de la barra de estado
    statusBarIconBrightness: Brightness.dark, // Controla el color de los íconos de la barra de estado
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desoido',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => InicioPage(),
        '/inicio': (context) => InicioPage(),
        '/mapa': (context) => MapaPage(),
        '/nivel2': (context) => Nivel2Page(),
        '/nivel3': (context) => Nivel3Page(),
        '/nivel4': (context) => Nivel4Page(),
        '/nivel5': (context) => Nivel5Page(),
      },
    );
  }
}