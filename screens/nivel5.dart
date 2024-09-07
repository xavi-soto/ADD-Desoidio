import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'mapa.dart';

class Nivel5Page extends StatefulWidget {
  @override
  _Nivel5PageState createState() => _Nivel5PageState();
}

class _Nivel5PageState extends State<Nivel5Page> with SingleTickerProviderStateMixin {
  ui.Image? _loadedForegroundImage;
  Uint8List? _buttonMapImageData;
  bool _imagesLoaded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  @override
  void initState() {
    super.initState();
    _loadAllImages();
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_controller);

    // Deshabilitar el botón de regreso en Android
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        return; // Ignorar la acción del botón de regreso
      }
    });
  }

  Future<void> _loadAllImages() async {
    try {
      _loadedForegroundImage = await _loadImage('assets/nivel5pa.png');
      _buttonMapImageData = await _loadImageData('assets/comenzar2.png');
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

  Future<void> _playSoundAndNavigate() async {
    await _audioPlayer.play(AssetSource('click.mp3')); // Reproduce el sonido click.mp3
    Navigator.pushNamed(context, '/inicio'); // Navega a inicio.dart
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Este widget deshabilita el botón de retroceso
      onWillPop: () async => false, // Evita la acción de retroceso
      child: Scaffold(
        backgroundColor: Color.fromRGBO(201, 201, 201, 1),
        body: Stack(
          children: [
            _imagesLoaded
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return CustomPaint(
                        painter: _BackgroundPainter(
                          foreground: _loadedForegroundImage,
                          canvasSize: canvasSize,
                        ),
                        size: canvasSize,
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50), // Ajusta el padding para bajarla
                child: GestureDetector(
                  onTap: () => _playSoundAndNavigate(), // Reproduce el sonido y navega en un solo toque
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animation.value,
                        child: Image.asset(
                          'assets/comenzar2.png',
                          width: 185,
                          height: 100,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
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

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({
    required this.foreground,
    required this.canvasSize,
  });

  final ui.Image? foreground;
  final Size canvasSize;

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
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => true;
}
