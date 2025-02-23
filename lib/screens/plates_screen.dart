import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlatesScreen extends StatefulWidget {
  @override
  _PlatesScreenState createState() => _PlatesScreenState();
}

class _PlatesScreenState extends State<PlatesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _plateController = TextEditingController();
  List<Map<String, String>> _plates = [];
  bool _isLoading = false;

  // Möjliga statusar
  final List<String> _statusOptions = ['Godkänd', 'Ej Godkänd'];

  // Standardvärde för dropdown-menyn
  String _selectedStatus = 'Ej Godkänd';

  @override
  void initState() {
    super.initState();
    _fetchPlates(); // Hämta skyltar vid start
  }

  void _fetchPlates() async {
    setState(() => _isLoading = true);
    try {
      final List<Map<String, String>> plates = await _apiService.getLicensePlates();
      setState(() => _plates = plates);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel vid hämtning: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  void _addPlate() async {
    final plate = _plateController.text.trim().toUpperCase();
    print("📡 Skickar registreringsnummer: $plate"); // 🔍 Debug
    if (plate.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.addLicensePlate(plate, _selectedStatus);
      _plateController.clear();
      _fetchPlates(); // Uppdatera listan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel vid tillägg: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  void _deletePlate(String plate) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteLicensePlate(plate);
      _fetchPlates(); // Uppdatera listan efter borttagning
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel vid radering: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  void _editPlateStatus(Map<String, String> plate) {
    String newStatus = plate["status"] ?? "Ej Godkänd"; // Standardvärde

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Redigera status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Registreringsnummer: ${plate["plate_number"]}"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: newStatus,
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  newStatus = value!;
                },
                decoration: const InputDecoration(
                  labelText: "Välj ny status",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Avbryt"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Spara", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                Navigator.of(context).pop(); // Stäng popupen
                setState(() => _isLoading = true);
                await _apiService.updatePlateStatus(plate["plate_number"]!, newStatus);
                _fetchPlates(); // 🔥 Uppdatera listan

                setState(() => _isLoading = false);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registreringsskyltar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Ange registreringsnummer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPlate,
              child: const Text('Lägg till registreringsskylt'),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _plates.length,
                itemBuilder: (context, index) {
                  final plate = _plates[index]['plate_number'] ?? "Okänd skylt";
                  final plateStatus = _plates[index]['status'] ?? "Ej angiven";
                  return Card(
                    child: ListTile(
                      title: Text(plate),
                      subtitle: Text("Status: $plateStatus"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePlate(plate),
                      ),
                      onTap: () => _editPlateStatus({
                        "plate_number": plate,
                        "status": plateStatus, // 🔥 Skicka status till edit-funktionen
                      }),
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
