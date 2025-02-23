import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _plateController = TextEditingController();
  List<Map<String, String>> _plates = [];
  bool _isLoading = false;

  // Möjliga statusar
  final List<String> _statusOptions = ['Godkänd', 'Ej Godkänd'];

  // Standardvärde för dropdown-menyn
  String _selectedStatus = 'Ej Godkänd';

  void _fetchPlates() async {
    setState(() => _isLoading = true);
    try {
      final List<Map<String, String>> plates = await _apiService.getLicensePlates();

      setState(() {
        _plates = plates; // Nu ska typen matcha
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fel: ${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
  }


  void _addPlate() async {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.addLicensePlate(plate, _selectedStatus);
      _plateController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fel vid tillägg: ${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
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

            // 🔽 DROPDOWN FÖR ATT VÄLJA STATUS 🔽
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Välj status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _addPlate,
              child: const Text('Lägg till registreringsskylt'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchPlates,
              child: const Text('Hämta skyltar'),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _plates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_plates[index]["plate_number"] ?? "Okänd skylt"),
                    subtitle: Text("Status: ${_plates[index]["status"] ?? "Okänd"}"),
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
