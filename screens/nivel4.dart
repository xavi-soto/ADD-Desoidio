import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart'; // Importa el paquete de audioplayers
import 'nivel5.dart';
import 'mapa.dart';

class Nivel4Page extends StatefulWidget {
  @override
  _Nivel4PageState createState() => _Nivel4PageState();
}

class _Nivel4PageState extends State<Nivel4Page> {
  String _foregroundImage = 'assets/nivel4pa.png';
  String _correctImagePath = 'assets/correcto3.png';
  String _errorImagePath = 'assets/vuelve.png';
  String _buttonMapImagePath = 'assets/botonmap.png';
  String _logoCaraImagePath = 'assets/logocara.png';
  String _opcImagePath = 'assets/opc3.png';
  String _opc1ImagePath = 'assets/opc1.png';
  String _enivelImagePath = 'assets/enivel.png';
  String _pista1ImagePath = 'assets/pista1.png';

  ui.Image? _loadedForegroundImage;
  ui.Image? _correctImage;
  ui.Image? _errorImage;
  ui.Image? _successImage;
  ui.Image? _opcImage;
  ui.Image? _opc1Image;
  ui.Image? _enivelImage;
  ui.Image? _enivel2Image;
  ui.Image? _enivel3Image;
  ui.Image? _pista1Image;
  ui.Image? _pista2Image;
  ui.Image? _pista3Image;

  Uint8List? _buttonMapImageData;
  Uint8List? _logoCaraImageData;
  Uint8List? _opcImageData;

  bool _imagesLoaded = false;

  Timer? _countdownTimer;
  StreamSubscription? _gyroscopeSubscription;
  int _remainingSeconds = 20;
  bool _countdownActive = false;

  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;

  bool _imageChanged = false;
  bool _imageChangedToEnivel3 = false;
  bool _showingDialog = false;

  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  @override
  void initState() {
    super.initState();
    _loadAllImages().then((_) {
      if (mounted) {
        _showInitialOpcImage();
        _startGyroscopeListener();
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAllImages() async {
    try {
      _loadedForegroundImage = await _loadImage(_foregroundImage);
      _correctImage = await _loadImage(_correctImagePath);
      _errorImage = await _loadImage(_errorImagePath);
      _successImage = await _loadImage(_correctImagePath);
      _opcImage = await _loadImage(_opcImagePath);
      _opc1Image = await _loadImage(_opc1ImagePath);
      _enivelImage = await _loadImage(_enivelImagePath);
      _enivel2Image = await _loadImage('assets/enivel2.png');
      _enivel3Image = await _loadImage('assets/enivel3.png');
      _pista1Image = await _loadImage(_pista1ImagePath);
      _pista2Image = await _loadImage('assets/pista2.png');
      _pista3Image = await _loadImage('assets/pista3.png');

      _buttonMapImageData = await _loadImageData(_buttonMapImagePath);
      _logoCaraImageData = await _loadImageData(_logoCaraImagePath);
      _opcImageData = await _loadImageData(_opcImagePath);

      if (mounted) {
        setState(() {
          _imagesLoaded = true;
        });
      }
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

  Future<void> _playSound(String fileName) async {
    await _audioPlayer.play(AssetSource(fileName)); // Reproduce el sonido especificado
  }

  void _startCountdown() {
    if (!mounted) return;

    setState(() {
      _remainingSeconds = 20;
      _countdownActive = true;
    });

    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _countdownActive = false;
        _showTimeUpDialog();
      }
    });
  }

  Future<void> _showTimeUpDialog() async {
    if (!mounted) return;

    final errorImageBytes = await _getImageBytes(_errorImage!);
    await _playSound('mal.mp3'); // Reproduce el sonido mal.mp3 cuando aparece vuelve.png

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            if (!mounted) return;
            Navigator.of(context).pop();
            _restartLevel();
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
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
            ),
          ),
        );
      },
    );
  }

  void _restartLevel() async {
    if (!mounted) return;

    setState(() {
      _remainingSeconds = 20;
      _imageChanged = false;
      _imageChangedToEnivel3 = false;
      _rotationX = 0.0;
      _rotationY = 0.0;
      _rotationZ = 0.0;
    });
    await _resetImages(); // Reinicia las imágenes
    _startGyroscopeListener(); // Reinicia el listener del giroscopio
    _startCountdown();
  }

  Future<void> _resetImages() async {
    if (!mounted) return;

    // Reinicia las imágenes a su estado original
    _enivelImage = await _loadImage(_enivelImagePath);
    _pista1Image = await _loadImage(_pista1ImagePath);
  }

  Future<Uint8List> _getImageBytes(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showInitialOpcImage() {
    if (!mounted) return;

    Future.delayed(Duration.zero, () {
      _showOpcImage();
    });
  }

  void _showOpcImage() {
    if (!mounted) return;

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
    if (!mounted) return;

    _countdownTimer?.cancel();

    final successImageBytes = await _getImageBytes(_successImage!);

    await _playSound('exito.mp3'); // Reproduce el sonido exito.mp3 cuando aparece correcto3.png

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            if (mounted) {
              Navigator.of(context).pop(); // Cierra el diálogo antes de navegar
              _navigateToNivel5(); // Navegar a Nivel5Page al tocar cualquier parte del diálogo
            }
          },
          child: Container( // Aquí se hace clic en cualquier parte del contenedor
            color: Colors.transparent,
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
        );
      },
    );
  }

  void _startGyroscopeListener() {
    _gyroscopeSubscription?.cancel();
    Timer? rotationTimer;
    Timer? transitionTimer;

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (_showingDialog || !mounted) return;

      setState(() {
        _rotationX += event.x;
        _rotationY += event.y;
        _rotationZ += event.z;

        double rotationZDegrees = _rotationZ * 180 / 3.14;

        if (rotationZDegrees >= 165 && rotationZDegrees <= 195) {
          if (!_imageChanged) {
            rotationTimer ??= Timer(Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                _enivelImage = _enivel2Image;
                _pista1Image = _pista2Image;
                _imageChanged = true;
              });
            });
          }
        } else if (rotationZDegrees >= 210 && rotationZDegrees <= 260) {
          if (!_imageChangedToEnivel3) {
            transitionTimer ??= Timer(Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                _enivelImage = _enivel3Image;
                _pista1Image = _pista3Image;
                _imageChangedToEnivel3 = true;
              });
            });
          }
        } else if (_enivelImage == _enivel3Image && rotationZDegrees >= 160 && rotationZDegrees <= 180) {
          _showCorrectImage();
        } else {
          if (rotationTimer?.isActive == true) {
            rotationTimer?.cancel();
            rotationTimer = null;
          }
          if (transitionTimer?.isActive == true) {
            transitionTimer?.cancel();
            transitionTimer = null;
          }
          _imageChanged = false;
          _imageChangedToEnivel3 = false;
        }
      });
    });
  }

  Future<void> _showCorrectImage() async {
    if (!mounted) return;

    _countdownTimer?.cancel(); // Detener el temporizador cuando aparece la imagen correcto2.png

    _showingDialog = true;
    final correctImageBytes = await _getImageBytes(_correctImage!);

    await _playSound('exito.mp3'); // Reproduce el sonido exito.mp3 cuando aparece correcto3.png

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            if (mounted) {
              Navigator.of(context).pop(); // Cierra el diálogo antes de navegar
              _navigateToNivel5(); // Navegar a Nivel5Page al tocar cualquier parte del diálogo
            }
          },
          child: Container(
            color: Colors.transparent, // El contenedor permite clics en cualquier parte
            child: Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 350,
                height: 350,
                child: Image.memory(
                  correctImageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        _showingDialog = false;
      }
    });
  }

  void _navigateToNivel5() {
    _gyroscopeSubscription?.cancel(); // Cancelar el listener del giroscopio
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Nivel5Page()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Deshabilitar el botón de retroceso
      child: Scaffold(
        backgroundColor: Color.fromRGBO(201, 201, 201, 1),
        body: Stack(
          children: [
            _loadedForegroundImage != null
                ? CustomPaint(
                    painter: _ForegroundPainter(image: _loadedForegroundImage!),
                    size: Size(double.infinity, double.infinity),
                  )
                : Center(child: CircularProgressIndicator()),
            _imagesLoaded
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                      return CustomPaint(
                        painter: _MyPainter(
                          foreground: _enivelImage,
                          pistaImage: _pista1Image,
                          canvasSize: canvasSize,
                          rotationX: _rotationX,
                          rotationY: _rotationY,
                          rotationZ: _rotationZ,
                        ),
                        size: Size(double.infinity, double.infinity),
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
                              await _playSound('click.mp3'); // Reproduce el sonido click.mp3
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
                              await _playSound('click.mp3'); // Reproduce el sonido click.mp3
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

class _ForegroundPainter extends CustomPainter {
  final ui.Image image;

  _ForegroundPainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final double foregroundScale = (size.width - 40) / image.width;
    final double foregroundHeight = image.height * foregroundScale;

    canvas.save();
    canvas.translate(20, 20);
    canvas.scale(foregroundScale, foregroundScale);
    canvas.drawImage(image, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MyPainter extends CustomPainter {
  final ui.Image? foreground;
  final ui.Image? pistaImage;
  final Size canvasSize;
  final double rotationX;
  final double rotationY;
  final double rotationZ;

  _MyPainter({
    this.foreground,
    this.pistaImage,
    required this.canvasSize,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pistaImage != null) {
      final Paint paint = Paint();
      final double pistaWidth = pistaImage!.width.toDouble();
      final double pistaHeight = pistaImage!.height.toDouble();

      final double pistaScaleFactor = 0.13;
      final double pistaScaledWidth = pistaWidth * pistaScaleFactor;
      final double pistaScaledHeight = pistaHeight * pistaScaleFactor;

      final double pistaX = (canvasSize.width - pistaScaledWidth) / 2;
      final double pistaY = (canvasSize.height - pistaScaledHeight) / 3 - pistaScaledHeight - 10;

      canvas.drawImageRect(
        pistaImage!,
        Rect.fromLTWH(0, 0, pistaWidth, pistaHeight),
        Rect.fromLTWH(pistaX, pistaY, pistaScaledWidth, pistaScaledHeight),
        paint,
      );
    }

    if (foreground != null) {
      final Paint paint = Paint();
      final double imageWidth = foreground!.width.toDouble();
      final double imageHeight = foreground!.height.toDouble();

      final double scaleFactor = 0.090;
      final double scaledWidth = imageWidth * scaleFactor;
      final double scaledHeight = imageHeight * scaleFactor;

      final Offset imageOffset = Offset(
        (canvasSize.width - scaledWidth) / 2,
        (canvasSize.height - scaledHeight) / 2,
      );

      canvas.save();
      canvas.translate(imageOffset.dx + scaledWidth / 2, imageOffset.dy + scaledHeight / 2);
      canvas.rotate(rotationZ);
      canvas.translate(-scaledWidth / 2, -scaledHeight / 2);

      canvas.drawImageRect(
        foreground!,
        Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        Rect.fromLTWH(0, 0, scaledWidth, scaledHeight),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
