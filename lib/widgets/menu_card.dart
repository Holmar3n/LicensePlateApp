import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? screen;
  final VoidCallback? onTap;

  const MenuCard.home({
    super.key,
    required this.title,
    required this.icon,
    required this.screen,
  }) : onTap = null;

  const MenuCard.gate({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  }): screen = null;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (
                _) => screen!), // Säkerställer att screen aldrig är null här
          );
        } else if (onTap != null) {
          onTap!(); // Kör den angivna funktionen
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
