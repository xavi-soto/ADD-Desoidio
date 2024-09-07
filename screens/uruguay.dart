import 'package:flutter/material.dart';

class UruguayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('uruguay'),
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
