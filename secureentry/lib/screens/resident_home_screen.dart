import 'package:flutter/material.dart';

class ResidentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resident Home')),
      body: Center(child: Text('Welcome, Resident!')),
    );
  }
}