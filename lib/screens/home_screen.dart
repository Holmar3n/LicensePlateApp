import 'package:flutter/material.dart';
import 'package:licenseplateapp/screens/plates_screen.dart';
import '../services/api_service.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import "gate_screen.dart";
import "../widgets/menu_card.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApi();
  }

  /// Initiera API och WebSocket-anslutning
  void _initializeApi() {
    ApiService().init();
  }

  @override
  void dispose() {
    ApiService().closeConnection(); // Stäng WebSocket när skärmen försvinner
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hem')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            MenuCard.home(title: 'Bilar', icon: Icons.car_repair, screen: PlatesScreen()),
            MenuCard.home(title: 'Notiser & Logg', icon: Icons.notifications, screen: NotificationsScreen()),
            MenuCard.home(title: 'Inställningar', icon: Icons.settings, screen: SettingsScreen()),
            MenuCard.home(title: "Hantera Grind", icon: Icons.fence, screen: GateScreen()),
          ],
        ),
      ),
    );
  }
}
