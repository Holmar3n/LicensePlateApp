import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> _notifications = [
    {"title": "Ny bil upptäckt!", "message": "En okänd bil har registrerats vid grinden.", "time": DateFormat('HH:mm').format(DateTime.now())},
    {"title": "Grinden öppnad", "message": "Grinden öppnades manuellt via appen.", "time": DateFormat('HH:mm').format(DateTime.now())},
    {"title": "Tillåten bil passerade", "message": "Bil med registreringsnummer ABC123 har passerat.", "time": DateFormat('HH:mm').format(DateTime.now())},
  ];

  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikationer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Senaste notiser",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // Mellanrum mellan text och lista
            Flexible( // 🔥 Fix för overflow
              child: _notifications.isEmpty
                  ? const Center(
                child: Text(
                  "Inga notiser hittades",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true, // 🔥 Fixar scroll-problem i Column
                physics: const AlwaysScrollableScrollPhysics(), // Tillåter scroll även vid få notiser
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.blue),
                      title: Text(
                        notification['title'] ?? "Notis",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(notification['message'] ?? "Ingen beskrivning"),
                      trailing: Text(
                        notification['time'] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
