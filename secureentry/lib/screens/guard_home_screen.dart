import 'package:flutter/material.dart';

class GuardHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guard Home')),
      body: Center(child: Text('Welcome, Guard!')),
    );
  }
}