import 'package:flutter/material.dart';

class ResidentScreen extends StatefulWidget {
  const ResidentScreen({super.key});

  @override
  State<ResidentScreen> createState() => _ResidentScreenState();
}

class _ResidentScreenState extends State<ResidentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Home'),
      ),
      body: const Center(
        child: Text('Resident Home'),
      ),
    );
  }
}
