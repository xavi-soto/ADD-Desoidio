import 'package:flutter/material.dart';
import 'package:oidos_sordos/screens/inicio.dart'; 
import 'package:oidos_sordos/screens/mapa.dart'; 



void main() { 
  runApp(MyApp()); 
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Eliminar el letrero "DEBUG"
      initialRoute: '/', 
      routes: {
        '/': (context) => InicioPage(), 
        '/mapa': (context) => MapaPage(),
      },
    );
  }
}
