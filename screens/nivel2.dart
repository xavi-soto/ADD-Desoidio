import 'package:flutter/material.dart';

class Nivel2Page extends StatefulWidget {
  @override
  _Nivel2PageState createState() => _Nivel2PageState();
}

class _Nivel2PageState extends State<Nivel2Page> {
  int _currentImageIndex = 0; // Estado para controlar el índice de la imagen actual

  final List<String> _images = [
    'nivel1pata2.png',
    'nivel1pata3.png',
    'nivel1pata4.png',
  ]; // Lista de imágenes, excluyendo las eliminadas

  void _nextImage() {
    setState(() {
      if (_currentImageIndex < _images.length - 1) {
        _currentImageIndex++;
      } else {
        // Si se llega a la última imagen, navegar a la pantalla nivel3.dart
        Navigator.pushNamed(context, '/nivel3');
      }
    });
  }

  void _previousImage() {
    setState(() {
      if (_currentImageIndex > 0) {
        _currentImageIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Deshabilitar el botón de regreso de Android
      child: Scaffold(
        backgroundColor: Color.fromRGBO(201, 201, 201, 1), // Fondo de color especificado
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              _nextImage(); // Deslizar hacia la izquierda para la siguiente imagen
            } else if (details.primaryVelocity! > 0) {
              _previousImage(); // Deslizar hacia la derecha para la imagen anterior
            }
          },
          child: Stack(
            children: [
              // Imagen fija
              Image.asset(
                'assets/nivel1pata.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              // Imagen que cambia
              Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Image.asset(
                    'assets/${_images[_currentImageIndex]}',
                    key: ValueKey<int>(_currentImageIndex),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
