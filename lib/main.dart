import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Artık HomeScreen yerine LoginScreen'i çağırıyoruz

void main() {
  runApp(const EtkinlikApp());
}

class EtkinlikApp extends StatelessWidget {
  const EtkinlikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoginScreen(), 
    );
  }
}