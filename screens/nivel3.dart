import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Importa el paquete de audioplayers
import 'mapa.dart';
import 'nivel4.dart'; // Importa el archivo nivel4.dart aquí

class Nivel3Page extends StatefulWidget {
  @override
  _Nivel3PageState createState() => _Nivel3PageState();
}

class _Nivel3PageState extends State<Nivel3Page> {
  String _foregroundImage = 'assets/nivel3pa.png'; // Imagen de fondo
  List<String> _bottomImages = List.generate(20, (index) => 'assets/p${index + 1}.png'); // Imágenes en movimiento
  String _correctImagePath = 'assets/correcto2.png';
  String _errorImagePath = 'assets/vuelve.png';
  String _buttonMapImagePath = 'assets/botonmap.png';
  String _logoCaraImagePath = 'assets/logocara.png';
  String _opcImagePath = 'assets/opc2.png'; // Imagen de inicio
  String _opc1ImagePath = 'assets/opc1.png'; // Nueva imagen opc1.png

  ui.Image? _loadedForegroundImage;
  List<ui.Image?> _loadedBottomImages = [];
  ui.Image? _correctImage;
  ui.Image? _errorImage;
  ui.Image? _successImage; // Imagen de éxito para mostrar después de completar el objetivo
  ui.Image? _opc1Image; // Cargar imagen opc1.png
  Uint8List? _buttonMapImageData;
  Uint8List? _logoCaraImageData;
  Uint8List? _opcImageData;
  bool _imagesLoaded = false;

  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  List<Offset?> _movingImagesPositions = [];
  List<Offset?> _movingImagesVelocities = [];
  Timer? _movementTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 20;

  bool _countdownActive = false; // Variable para controlar si el cronómetro está activo
  int _touchedImageCount = 0; // Contador de imágenes correctas tocadas
  final Set<int> _touchedIndices = Set(); // Para rastrear las imágenes correctas tocadas
  bool _isImageTouched = false; // Nuevo estado para controlar el toque de imágenes
  int _currentTouchedIndex = -1; // Índice de la imagen que se está tocando actualmente

  final Set<int> _requiredIndices = {1, 4, 5, 11, 12, 18}; // Índices de las imágenes p2.png, p5.png, p6.png, p12.png, p13.png, p19.png

  bool _showOpc1 = false; // Controlar cuándo mostrar opc1.png

  @override
  void initState() {
    super.initState();
    _loadAllImages().then((_) {
      _initializeMovingImages();
      _showInitialOpcImage(); // Mostrar imagen de inicio
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel(); // Cancelar el Timer cuando el widget se destruye
    _countdownTimer?.cancel(); // Cancelar el cronómetro cuando el widget se destruye
    super.dispose();
  }

  Future<void> _loadAllImages() async {
    try {
      _loadedForegroundImage = await _loadImage(_foregroundImage);
      for (String image in _bottomImages) {
        final loadedImage = await _loadImage(image); // Cargar imágenes sin redimensionar
        _loadedBottomImages.add(loadedImage);
      }
      _correctImage = await _loadImage(_correctImagePath);
      _errorImage = await _loadImage(_errorImagePath); // Cargar imagen vuelve.png
      _successImage = await _loadImage(_correctImagePath); // Cargar imagen correcto.png
      _opc1Image = await _loadImage(_opc1ImagePath); // Cargar imagen opc1.png
      _buttonMapImageData = await _loadImageData(_buttonMapImagePath);
      _logoCaraImageData = await _loadImageData(_logoCaraImagePath);
      _opcImageData = await _loadImageData(_opcImagePath); // Cargar imagen opc2.png

      setState(() {
        _imagesLoaded = true;
      });
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  Future<ui.Image> _loadImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final Uint8List list = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer();
    
    ui.decodeImageFromList(list, (ui.Image img) {
      completer.complete(img);
    });

    return completer.future;
  }

  Future<Uint8List> _loadImageData(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    return data.buffer.asUint8List();
  }

  Future<void> _playClickSound() async {
    await _audioPlayer.play(AssetSource('click.mp3')); // Reproduce el sonido click.mp3
  }

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('exito.mp3')); // Reproduce el sonido exito.mp3
  }

  Future<void> _playErrorSound() async {
    await _audioPlayer.play(AssetSource('mal.mp3')); // Reproduce el sonido mal.mp3
  }

  void _initializeMovingImages() {
    final canvasSize = MediaQuery.of(context).size;

    for (int i = 0; i < 20; i++) {
      final x = (canvasSize.width * (i / 20)) % canvasSize.width;
      final y = (canvasSize.height * (i / 20)) % canvasSize.height;
      final velocityX = 1 + (i % 5);
      final velocityY = 1 + ((i + 3) % 5);
      _movingImagesPositions.add(Offset(x, y));
      _movingImagesVelocities.add(Offset(velocityX.toDouble(), velocityY.toDouble()));
    }

    _movementTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted) return; // Verificar si el widget está montado

      setState(() {
        final canvasSize = MediaQuery.of(context).size;

        for (int i = 0; i < _movingImagesPositions.length; i++) {
          final position = _movingImagesPositions[i]!;
          final velocity = _movingImagesVelocities[i]!;

          double newX = position.dx + velocity.dx;
          double newY = position.dy + velocity.dy;

          if (newX < 0 || newX > canvasSize.width) {
            _movingImagesVelocities[i] = Offset(-velocity.dx, velocity.dy);
          }
          if (newY < 0 || newY > canvasSize.height) {
            _movingImagesVelocities[i] = Offset(velocity.dx, -velocity.dy);
          }

          _movingImagesPositions[i] = Offset(
            newX.clamp(0.0, canvasSize.width),
            newY.clamp(0.0, canvasSize.height),
          );
        }
      });
    });
  }

  void _resetRequiredImages() {
    // Volver a las imágenes originales p2.png, p5.png, p6.png, p12.png, p13.png, p19.png
    final originalImages = {
      1: 'assets/p2.png',
      4: 'assets/p5.png',
      5: 'assets/p6.png',
      11: 'assets/p12.png',
      12: 'assets/p13.png',
      18: 'assets/p19.png',
    };

    originalImages.forEach((index, path) async {
      final newImage = await _loadImage(path);
      setState(() {
        _loadedBottomImages[index] = newImage;
      });
    });

    // Reiniciar el contador y el conjunto de imágenes tocadas
    _touchedImageCount = 0;
    _touchedIndices.clear();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = 20;
      _countdownActive = true;
      _resetRequiredImages(); // Resetear las imágenes al iniciar el cronómetro
    });

    _countdownTimer?.cancel(); // Cancelar cualquier cronómetro anterior

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _countdownActive = false;
        _showTimeUpDialog(); // Mostrar la imagen-ventana vuelve.png cuando el tiempo se agota
      }
    });
  }

  Future<void> _showTimeUpDialog() async {
    await _playErrorSound(); // Reproduce el sonido mal.mp3
    final errorImageBytes = await _getImageBytes(_errorImage!);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            _startCountdown(); // Reiniciar el cronómetro al tocar para cerrar vuelve.png
          },
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: SizedBox(
              width: 150,
              height: 150,
              child: Image.memory(
                errorImageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List> _getImageBytes(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showInitialOpcImage() {
    Future.delayed(Duration.zero, () {
      _showOpcImage();
    });
  }

  void _showOpcImage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 270,
            height: 270,
            child: Image.memory(
              _opcImageData!,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog() async {
    await _playSuccessSound(); // Reproduce el sonido exito.mp3
    _countdownTimer?.cancel(); // Detener el cronómetro cuando aparece la ventana correcto.png

    final successImageBytes = await _getImageBytes(_successImage!);

    await showDialog(
      context: context,
      barrierDismissible: true, // Permitir cerrar tocando fuera de la imagen
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Nivel4Page()), // Navegar a Nivel4Page
            );
          },
          child: Container(
            color: Colors.transparent, // Color transparente para permitir toques
            child: Center(
              child: Dialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: SizedBox(
                  width: 350,
                  height: 350,
                  child: Image.memory(
                    successImageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Deshabilitar el botón de retroceso
      child: Scaffold(
        backgroundColor: Color.fromRGBO(201, 201, 201, 1),
        body: Stack(
          children: [
            _imagesLoaded
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                      return GestureDetector(
                        onTapUp: (details) {
                          if (!_countdownActive) {
                            _startCountdown(); // Iniciar el cronómetro solo si no está activo y después de que se cierre vuelve.png
                          }

                          final touchPosition = details.localPosition;

                          for (int i = 0; i < _movingImagesPositions.length; i++) {
                            final position = _movingImagesPositions[i];
                            final imageWidth = _loadedBottomImages[i]!.width.toDouble() * 0.2;
                            final imageHeight = _loadedBottomImages[i]!.height.toDouble() * 0.2;
                            final rect = Rect.fromLTWH(
                              position!.dx,
                              position.dy,
                              imageWidth,
                              imageHeight,
                            );

                            if (rect.contains(touchPosition) && _requiredIndices.contains(i)) {
                              if (_currentTouchedIndex != -1 && _currentTouchedIndex != i) {
                                return; // No permitir tocar otra imagen mientras una ya está tocada
                              }

                              setState(() {
                                _isImageTouched = true; // Marcar que una imagen está tocada
                                _currentTouchedIndex = i;
                                _touchedIndices.add(i);
                                _touchedImageCount = _touchedIndices.length; // Actualizar el contador
                              });

                              String? replacementImagePath;
                              switch (i + 1) {
                                case 2:
                                  replacementImagePath = 'assets/p21.png';
                                  break;
                                case 5:
                                  replacementImagePath = 'assets/p51.png';
                                  break;
                                case 6:
                                  replacementImagePath = 'assets/p61.png';
                                  break;
                                case 12:
                                  replacementImagePath = 'assets/p121.png';
                                  break;
                                case 13:
                                  replacementImagePath = 'assets/p131.png';
                                  break;
                                case 19:
                                  replacementImagePath = 'assets/p191.png';
                                  break;
                                default:
                                  replacementImagePath = null;
                                  break;
                              }

                              if (replacementImagePath != null) {
                                _loadImage(replacementImagePath).then((newImage) {
                                  setState(() {
                                    _loadedBottomImages[i] = newImage;
                                    if (_touchedImageCount == 6) {
                                      _showSuccessDialog(); // Mostrar imagen correcto.png cuando se tocan las 6 imágenes correctas
                                    }
                                    _isImageTouched = false;
                                    _currentTouchedIndex = -1;
                                  });
                                });
                              } else {
                                setState(() {
                                  _isImageTouched = false;
                                  _currentTouchedIndex = -1;
                                });
                              }
                              break; // Salir del bucle después de tocar una imagen
                            }
                          }
                        },
                        child: CustomPaint(
                          painter: _MyPainter(
                            foreground: _loadedForegroundImage,
                            bottomImages: _loadedBottomImages,
                            canvasSize: canvasSize,
                            movingImagePositions: _movingImagesPositions,
                          ),
                          size: canvasSize,
                        ),
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 16,
              left: 23,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buttonMapImageData != null
                        ? GestureDetector(
                            onTap: () async {
                              await _playClickSound(); // Reproduce el sonido click.mp3
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MapaPage()),
                              );
                            },
                            child: Image.memory(
                              _buttonMapImageData!,
                              width: 50,
                              height: 50,
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(width: 26),
                    _logoCaraImageData != null
                        ? GestureDetector(
                            onTap: () async {
                              await _playClickSound(); // Reproduce el sonido click.mp3
                              _showOpcImage();
                            },
                            child: Image.memory(
                              _logoCaraImageData!,
                              width: 70,
                              height: 70,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: Text(
                '$_remainingSeconds s',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPainter extends CustomPainter {
  _MyPainter({
    required this.foreground,
    required this.bottomImages,
    required this.canvasSize,
    required this.movingImagePositions,
  });

  final ui.Image? foreground;
  final List<ui.Image?> bottomImages;
  final Size canvasSize;
  final List<Offset?> movingImagePositions;

  @override
  void paint(Canvas canvas, Size size) {
    if (foreground != null) {
      final double foregroundScale = (size.width - 40) / (foreground!.width);
      final double foregroundHeight = foreground!.height * foregroundScale;
      canvas.save();
      canvas.translate(20, 20);
      canvas.scale(foregroundScale, foregroundScale);
      canvas.drawImage(foreground!, Offset.zero, Paint());
      canvas.restore();
    }

    for (int i = 0; i < bottomImages.length; i++) {
      final image = bottomImages[i];
      final position = movingImagePositions[i];
      if (image != null && position != null) {
        final double imageWidth = image.width.toDouble() * 0.2; // Reduce width by 20%
        final double imageHeight = image.height.toDouble() * 0.2; // Reduce height by 20%
        final Rect rect = Rect.fromLTWH(
          position.dx,
          position.dy,
          imageWidth,
          imageHeight,
        );

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          rect,
          Paint(),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MyPainter oldDelegate) => true;
}
