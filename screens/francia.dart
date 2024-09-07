import 'package:flutter/material.dart';

class FranciaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Francia'),
      ),
      body: Center(
        child: Text(
          '¡Hola!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
