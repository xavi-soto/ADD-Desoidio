import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Importa el paquete de audioplayers

class InicioPage extends StatefulWidget {
  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _clicked = false; // Estado para controlar si se hizo clic en la imagen
  int _currentImageIndex = 0; // Estado para controlar el índice de la imagen actual
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  final List<String> _images = [
    'deslizar.png', 'T1.png', 'T2.png', 'T3.png', 'T4.png', 'T5.png', 'T6.png', 'T7.png', 'ABRE.png'
  ]; // Lista de imágenes
  final List<String> _logoImages = [
    'logo10.png', 'logo2.png', 'logo3.png', 'logo4.png', 'logo5.png', 'logo6.png', 'logo7.png', 'logo8.png', 'logo9.png'
  ]; // Lista de logo imágenes

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000), // Duración más corta para hacer la animación más brusca
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0, // Reducción del inicio de la escala para hacerla más evidente
      end: 1.3,   // Ampliación del final de la escala para un efecto más dramático
    ).animate(_controller);
  }

  void _nextImage() {
    setState(() {
      if (_currentImageIndex < _images.length - 1) {
        _currentImageIndex++;
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

  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource(soundFile)); // Reproduce el sonido proporcionado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(201, 201, 201, 1),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _nextImage(); // Swipe hacia la izquierda para la siguiente imagen
          } else if (details.primaryVelocity! > 0) {
            _previousImage(); // Swipe hacia la derecha para la imagen anterior
          }
          // Eliminada la línea que reproducía el sonido desliza.mp3
        },
        onTap: () {
          if (_clicked && _currentImageIndex == 0) {
            setState(() {
              _nextImage(); // Avanza a la siguiente imagen cuando se hace clic en 'pantallades.png'
            });
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/titulo.png',
                width: 310,
                height: 195,
              ),
              SizedBox(height: 1),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 360,
                    height: 295,
                  ),
                  if (_clicked)
                    AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: _currentImageIndex == 0 ? 1000 : 500
                      ),
                      child: Image.asset(
                        'assets/${_logoImages[_currentImageIndex]}',
                        key: ValueKey<int>(_currentImageIndex),
                        width: 360,
                        height: 295,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _clicked = true; // Cambia el estado cuando se hace clic
                    _currentImageIndex = 0; // Muestra la primera imagen
                  });
                  _playSound('click.mp3'); // Reproduce el sonido click.mp3 al hacer clic
                },
                child: _clicked
                    ? Column(
                        // Mostrar la imagen actual y 'logocara.png' si se hizo clic
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_images[_currentImageIndex] == 'ABRE.png') {
                                _playSound('click.mp3'); // Reproduce el sonido click.mp3 al hacer clic en ABRE.png
                                Navigator.pushNamed(context, '/mapa'); // Navega a la pantalla mapa.dart si la imagen actual es ABRE.png
                              }
                            },
                            child: _images[_currentImageIndex] == 'ABRE.png'
                                ? AnimatedBuilder(
                                    animation: _animation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _animation.value,
                                        child: Image.asset(
                                          'assets/ABRE.png',
                                          width: 250,
                                          height: 100,
                                        ),
                                      );
                                    },
                                  )
                                : AnimatedSwitcher(
                                    duration: Duration(
                                      milliseconds: _currentImageIndex == 0 ? 1000 : 500
                                    ),
                                    child: Image.asset(
                                      'assets/${_images[_currentImageIndex]}',
                                      key: ValueKey<int>(_currentImageIndex),
                                      width: 285,
                                      height: 100,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 1),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 1000),
                            child: Image.asset(
                              'assets/logocara.png',
                              key: ValueKey<int>(_currentImageIndex),
                              width: 95,
                              height: 60,
                            ),
                          ),
                        ],
                      )
                    : AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _clicked = true;
                                  _currentImageIndex = 0; // Resetea al mostrar la primera imagen
                                });
                                _playSound('click.mp3'); // Reproduce el sonido click.mp3 al hacer clic
                              },
                              child: Image.asset(
                                'assets/comenzar.png',
                                width: 185,
                                height: 100,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 10),
              _clicked
                  ? SizedBox.shrink()
                  : Image.asset(
                      // Oculta 'texto.png' si se hizo clic
                      'assets/texto.png',
                      width: 500,
                      height: 60,
                    ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/instrucciones');
                },
                child: Text(
                  '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // Liberar recursos del reproductor de audio
    super.dispose();
  }
}
