import 'package:flutter/material.dart';
// Import Home page widget
import './home.dart';

// Main function
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    const title = 'LEAF';
    return const MaterialApp(
      title: title,
      home: Home(title: title),
    );
  }
}
