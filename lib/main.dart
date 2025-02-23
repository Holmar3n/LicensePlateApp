import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Se till att importen finns!
import '/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().init(); // Startar API och WebSocket
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'License Plate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Starta appen i HomeScreen
    );
  }
}
