import 'package:flutter/material.dart';

class EspanaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mexico'),
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
