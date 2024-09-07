import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:osc/osc.dart';
import 'dart:io';


void main() {
  // Ocultar el letrero "DEBUG" en modo debug
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint = (String? message, {int? wrapWidth}) {};

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ocultar el banner de debug
      title: 'Busca la Forma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black, // Fondo negro
        appBarTheme: AppBarTheme(
          color: Colors.black,
          elevation: 0, // Sin sombra de la barra de navegación
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
            color: Colors.white, // Color del texto
          ),
          button: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Color del texto de los botones
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Barra superior en negro
        title: Text('Nivel 1'),
        automaticallyImplyLeading: false, // Ocultar el botón de retroceso
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido a Busca la Forma!',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Nivel1Page()),
                );
              },
              child: Text('Jugar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Nivel1Page extends StatefulWidget {
  @override
  _Nivel1PageState createState() => _Nivel1PageState();
}

class _Nivel1PageState extends State<Nivel1Page> {
  double touchX = 0, touchY = 0;
  double previousTouchX = 0, previousTouchY = 0;
  double interpolationFactor = 0.1;

  late RawDatagramSocket socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket.receive();
          if (dg != null) {
            OSCMessage msg = OSCMessage.fromBytes(dg.data);
            print("Received OSC Message: $msg");
          }
        }
      });
    } catch (e) {
      print("Error initializing socket: $e");
    }
  }

  void sendTouchSensorData(double x, double y) {
    final oscDestination = InternetAddress("172.16.31.95");
    final oscPort = 9000;
    final address = '/touch_sensor';
    final arguments = [x, y];
    final message = OSCMessage(address, arguments: arguments);
    List<int> data = message.toBytes();

    try {
      socket.send(data, oscDestination, oscPort);
      print("Sent OSC message: $message");
    } catch (e) {
      print("Error sending touch sensor data: $e");
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      double currentTouchX = details.localPosition.dx;
      double currentTouchY = details.localPosition.dy;

      touchX = currentTouchX * interpolationFactor + previousTouchX * (1 - interpolationFactor);
      touchY = currentTouchY * interpolationFactor + previousTouchY * (1 - interpolationFactor);

      touchX = touchX.clamp(0, 50);
      touchY = touchY.clamp(0, 150);

      previousTouchX = touchX;
      previousTouchY = touchY;

      sendTouchSensorData(touchX, touchY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Barra superior en negro
        title: Text('Nivel 1'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                touchX = 0;
                touchY = 0;
                previousTouchX = 0;
                previousTouchY = 0;
                sendTouchSensorData(touchX, touchY);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      backgroundColor: Colors.black, // Fondo negro
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onPanUpdate: onPanUpdate,
                  child: Image.asset(
                    'assets/k.jpg',
                    width: touchX + 100,
                    height: touchY + 100,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.black, // Fondo negro de la ventana
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.white), // Contorno blanco
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/2.jpg',
                            width: 200,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'El sonido se encuentra entre estas figuras',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'X',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Fondo transparente
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'PISTA',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}