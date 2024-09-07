import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Importa el paquete de audioplayers

import 'inicio.dart'; // Asegúrate de importar la página inicio.dart si aún no lo has hecho
import 'mexico.dart'; // Importa la página MexicoPage

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  bool _isLoading = true;
  bool _showOpcImage = false;
  bool _showOpc2Image = false; // Nueva variable para opc2.png
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _hideImages() {
    setState(() {
      _showOpcImage = false;
      _showOpc2Image = false; // Ocultar opc2.png también
    });
  }

  void _showOpcImageFunc() async {
    await _playClickSound(); // Reproduce el sonido
    setState(() {
      _showOpcImage = true;
      _showOpc2Image = false; // Asegurarse de que opc2.png esté oculto cuando se muestra opc.png
    });
  }

  void _showOpc2ImageFunc() async {
    await _playClickSound(); // Reproduce el sonido
    setState(() {
      _showOpc2Image = true;
      _showOpcImage = false; // Asegurarse de que opc.png esté oculto cuando se muestra opc2.png
    });
  }

  Future<void> _playClickSound() async {
    await _audioPlayer.play(AssetSource('click.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Deshabilita el botón de regreso de Android
      child: Scaffold(
        backgroundColor: Color.fromRGBO(201, 201, 201, 1), // Cambiar el color de fondo aquí
        body: GestureDetector(
          onTap: _hideImages,
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true, // Habilitar desplazamiento
                scaleEnabled: true, // Habilitar zoom
                minScale: 1.0,
                maxScale: 4.0,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/mapa.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                    if (_showOpcImage)
                      Center(
                        child: Image.asset(
                          'assets/opc.png',
                          width: 270, // Tamaño de la imagen opc.png
                          height: 270, // Tamaño de la imagen opc.png
                        ),
                      ),
                    if (_showOpc2Image) // Nueva condición para opc2.png
                      Center(
                        child: Image.asset(
                          'assets/opc22.png',
                          width: 270, // Mismo tamaño que opc.png
                          height: 270, // Mismo tamaño que opc.png
                        ),
                      ),
                    Positioned(
                      left: 66,
                      top: 63,
                      child: GestureDetector(
                        onTap: () async {
                          await _playClickSound(); // Reproduce el sonido
                          Navigator.pop(context); // Volver a la página anterior (inicio.dart)
                        },
                        child: Image.asset(
                          'assets/regreso.png',
                          width: 53,
                          height: 53,
                        ),
                      ),
                    ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 34,
                        bottom: 520,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo2.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 74,
                        bottom: 446,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo3.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 274,
                        bottom: 466,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo4.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 283,
                        bottom: 356,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo5.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 160,
                        bottom: 324,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo6.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 50,
                        bottom: 314,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo7.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 90,
                        bottom: 164,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo8.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 270,
                        bottom: 219,
                        child: GestureDetector(
                          onTap: _showOpc2ImageFunc, // Abrir opc2.png en lugar de navegar
                          child: Image.asset(
                            'assets/ojo9.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    // Nuevo botón para abrir la página MexicoPage
                    if (_showOpcImage)
                      Positioned(
                        top: MediaQuery.of(context).size.height / 2 - 85, // Ajustar la posición vertical
                        left: MediaQuery.of(context).size.width / 2 - 25, // Centrar horizontalmente
                        child: GestureDetector(
                          onTap: () async {
                            await _playClickSound(); // Reproduce el sonido
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MexicoPage()));
                          },
                          child: Image.asset(
                            'assets/boton1.png',
                            width: 100, // Nuevo tamaño más pequeño de la imagen boton1.png
                            height: 25, // Nuevo tamaño más pequeño de la imagen boton1.png
                          ),
                        ),
                      ),
                    // Posicionar ojo1.png por encima de todas las imágenes
                    if (!_showOpcImage && !_showOpc2Image)
                      Positioned(
                        left: 195,
                        bottom: 550,
                        child: GestureDetector(
                          onTap: _showOpcImageFunc, // Este sigue abriendo opc.png
                          child: Image.asset(
                            'assets/ojo1.png',
                            width: 20,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isLoading)
                Positioned(
                  left: 146, // Mover hacia la izquierda
                  bottom: 36, // Mover hacia abajo
                  child: Image.asset(
                    'assets/logocargando.png',
                    width: 100,
                    height: 100,
                  ),
                )
              else
                Positioned(
                  left: 146, // Mover hacia la izquierda
                  bottom: 36, // Mover hacia abajo
                  child: Image.asset(
                    'assets/logoselec.png',
                    width: 100,
                    height: 100,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
