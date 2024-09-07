import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Importa el paquete de audioplayers
import 'package:collection/collection.dart';
import 'mapa.dart';
import 'nivel2.dart'; // Asegúrate de importar la pantalla nivel2

class MexicoPage extends StatefulWidget {
  @override
  _MexicoPageState createState() => _MexicoPageState();
}

class _MexicoPageState extends State<MexicoPage> {
  String _foregroundImage = 'assets/juego1tex.png';
  List<String> _bottomImages = [
    'assets/n1.png',
    'assets/n2.png',
    'assets/n3.png',
    'assets/n4.png',
  ];
  String _correctImagePath = 'assets/correcto.png';
  String _errorImagePath = 'assets/vuelve.png';
  String _buttonMapImagePath = 'assets/botonmap.png';
  String _logoCaraImagePath = 'assets/logocara.png';

  ui.Image? _loadedForegroundImage;
  List<ui.Image?> _loadedBottomImages = [];
  ui.Image? _correctImage;
  ui.Image? _errorImage;
  Uint8List? _buttonMapImageData;
  Uint8List? _logoCaraImageData;
  bool _imagesLoaded = false;
  List<Offset?> _drawPoints = [];
  List<int> _touchedImageIndices = [];
  final List<int> _correctOrder = [0, 1, 2, 3];
  bool _showCorrectImage = false;
  bool _showErrorImage = false;

  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  @override
  void initState() {
    super.initState();
    _loadAllImages().then((_) {
      _showInitialOpcImage();
    });
  }

  Future<void> _loadAllImages() async {
    try {
      _loadedForegroundImage = await _loadImage(_foregroundImage);
      for (String image in _bottomImages) {
        final loadedImage = await _loadImage(image);
        _loadedBottomImages.add(loadedImage);
      }
      _correctImage = await _loadImage(_correctImagePath);
      _errorImage = await _loadImage(_errorImagePath);
      _buttonMapImageData = await _loadImageData(_buttonMapImagePath);
      _logoCaraImageData = await _loadImageData(_logoCaraImagePath);
      setState(() {
        _imagesLoaded = true;
      });
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  Future<ui.Image> _loadImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
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

  bool _checkLineIntersection(Rect rect, Offset start, Offset end) {
    final double lineX1 = start.dx;
    final double lineY1 = start.dy;
    final double lineX2 = end.dx;
    final double lineY2 = end.dy;

    final double rectLeft = rect.left;
    final double rectTop = rect.top;
    final double rectRight = rect.right;
    final double rectBottom = rect.bottom;

    return _intersectsLine(lineX1, lineY1, lineX2, lineY2, rectLeft, rectTop, rectRight, rectTop) ||
        _intersectsLine(lineX1, lineY1, lineX2, lineY2, rectLeft, rectTop, rectLeft, rectBottom) ||
        _intersectsLine(lineX1, lineY1, lineX2, lineY2, rectRight, rectTop, rectRight, rectBottom) ||
        _intersectsLine(lineX1, lineY1, lineX2, lineY2, rectLeft, rectBottom, rectRight, rectBottom);
  }

  bool _intersectsLine(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
    final double denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
    if (denominator == 0) return false;

    final double ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator;
    final double ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator;

    return ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1;
  }

  void _updateTouchedImages(Size canvasSize) {
    final imageRects = _loadedBottomImages.asMap().map((index, image) {
      final position = _getImagePosition(index, canvasSize);
      final scale = _getImageScale(index, canvasSize);
      return MapEntry(index, Rect.fromLTWH(position.dx, position.dy, (image?.width ?? 0) * scale, (image?.height ?? 0) * scale));
    }).values.toList();

    _touchedImageIndices.clear();
    for (int i = 0; i < _drawPoints.length - 1; i++) {
      final start = _drawPoints[i];
      final end = _drawPoints[i + 1];
      if (start != null && end != null) {
        for (int j = 0; j < imageRects.length; j++) {
          if (_checkLineIntersection(imageRects[j], start, end)) {
            if (!_touchedImageIndices.contains(j)) {
              _touchedImageIndices.add(j);
            }
          }
        }
      }
    }

    if (_touchedImageIndices.length == _correctOrder.length &&
        ListEquality().equals(_touchedImageIndices, _correctOrder)) {
      setState(() {
        _showCorrectImage = true;
        _showErrorImage = false;
        _playSuccessSound(); // Reproduce el sonido de éxito
        _showCorrectImageDialog();
      });
    } else if (_touchedImageIndices.length == _bottomImages.length) {
      setState(() {
        _showErrorImage = true;
        _playErrorSound(); // Reproduce el sonido de error
        _showErrorImageDialog();
      });
    } else {
      setState(() {
        _showCorrectImage = false;
        _showErrorImage = false;
      });
    }
  }

  Offset _getImagePosition(int index, Size canvasSize) {
    final double bottomImageWidth = canvasSize.width / 10;
    final double bottomImageHeight = bottomImageWidth * ((_loadedBottomImages[index]?.height ?? 1) / (_loadedBottomImages[index]?.width ?? 1));

    final positions = [
      Offset(280, canvasSize.height - bottomImageHeight - 239),
      Offset(53 + bottomImageWidth + 10, canvasSize.height - bottomImageHeight - 290),
      Offset(-31 + 2 * (bottomImageWidth + 10), canvasSize.height - bottomImageHeight - 417),
      Offset(104 + 3 * (bottomImageWidth + 10), canvasSize.height - bottomImageHeight - 410),
    ];

    return positions[index];
  }

  double _getImageScale(int index, Size canvasSize) {
    final double bottomImageWidth = canvasSize.width / 10;
    return bottomImageWidth / (_loadedBottomImages[index]?.width ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Deshabilita el botón de regreso
      child: Scaffold(
        backgroundColor: Color.fromRGBO(201, 201, 201, 1),
        body: Stack(
          children: [
            _imagesLoaded
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _drawPoints.add(details.localPosition);
                            _updateTouchedImages(canvasSize);
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _drawPoints.add(null);
                          });
                        },
                        child: CustomPaint(
                          painter: _MyPainter(
                            foreground: _loadedForegroundImage,
                            bottomImages: _loadedBottomImages,
                            canvasSize: canvasSize,
                            drawPoints: _drawPoints,
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
                              await _playClickSound(); // Reproduce el sonido al hacer clic
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
                              await _playClickSound(); // Reproduce el sonido al hacer clic
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
          ],
        ),
      ),
    );
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
          child: Container(
            width: 270,
            height: 270,
            child: Image.asset(
              'assets/opc1.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  void _showCorrectImageDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/correcto.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    ).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Nivel2Page()), // Asegúrate de tener la página Nivel2Page importada
      );
    });
  }

  void _showErrorImageDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Cerrar el diálogo al hacer clic
            },
            child: Container(
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/vuelve.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _drawPoints.clear();
        _touchedImageIndices.clear();
        _showCorrectImage = false;
        _showErrorImage = false;
      });
    });
  }
}

class _MyPainter extends CustomPainter {
  _MyPainter({
    required this.foreground,
    required this.bottomImages,
    required this.canvasSize,
    required this.drawPoints,
  });

  final ui.Image? foreground;
  final List<ui.Image?> bottomImages;
  final Size canvasSize;
  final List<Offset?> drawPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (foreground != null) {
      final double foregroundScale = (canvasSize.width - 40) / (foreground!.width);
      final double foregroundHeight = foreground!.height * foregroundScale;
      canvas.save();
      canvas.translate(20, 20);
      canvas.scale(foregroundScale, foregroundScale);
      canvas.drawImage(foreground!, Offset.zero, Paint());
      canvas.restore();
    }

    final double bottomImageWidth = canvasSize.width / 10;
    final double bottomImageHeight = bottomImageWidth * ((bottomImages[0]?.height ?? 1) / (bottomImages[0]?.width ?? 1));

    final positions = [
      Offset(280, canvasSize.height - bottomImageHeight - 239),
      Offset(53 + bottomImageWidth + 10, canvasSize.height - bottomImageHeight - 290),
      Offset(-31 + 2 * (bottomImageWidth + 10), canvasSize.height - bottomImageHeight - 417),
      Offset(104 + 3 * (bottomImageWidth + 10), canvasSize.height - bottomImageHeight - 410),
    ];

    for (int i = 0; i < bottomImages.length; i++) {
      final image = bottomImages[i];
      final position = positions[i];
      if (image != null) {
        final double scale = bottomImageWidth / (image.width ?? 1);
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.scale(scale, scale);
        canvas.drawImage(image, Offset.zero, Paint());
        canvas.restore();
      }
    }

    Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < drawPoints.length - 1; i++) {
      final startPoint = drawPoints[i];
      final endPoint = drawPoints[i + 1];
      if (startPoint != null && endPoint != null) {
        canvas.drawLine(startPoint, endPoint, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_MyPainter oldDelegate) => true;
}
