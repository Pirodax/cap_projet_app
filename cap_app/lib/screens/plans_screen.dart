import 'package:flutter/material.dart';

class PlansScreen extends StatelessWidget {
  final String mutuelleName;

  const PlansScreen({super.key, required this.mutuelleName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans pour $mutuelleName'),
      ),
      body: Center(
        child: Text('Recherche des plans pour $mutuelleName...'),
      ),
    );
  }
}
