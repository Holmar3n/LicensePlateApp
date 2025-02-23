import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import '../services/api_service.dart';

class GateScreen extends StatelessWidget {
  GateScreen({super.key});

  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hantera Grind'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  MenuCard.gate(
                    title: "Öppna Grind",
                    icon: Icons.lock_open,
                    onTap: _apiService.openGate,
                  ),
                  MenuCard.gate(
                    title: "Stäng Grind",
                    icon: Icons.lock,
                    onTap: _apiService.closeGate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              "Här kommer kameran visas live",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
