import 'package:dio/dio.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080', // För emulator
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  late HubConnection _hubConnection;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initiera API-tjänsten (WebSocket + Notiser)
  Future<void> init() async {
    await _initNotifications();
    await _initWebSocket();
  }

  /// Initiera lokala push-notiser
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  /// Initiera WebSocket-anslutning (SignalR)
  Future<void> _initWebSocket() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl("http://10.0.2.2:8080/notificationHub") // Byt ut mot din serveradress
        .build();

    _hubConnection.on("ReceiveNotification", (message) {
      _showNotification(message![0] as String);
    });

    await _hubConnection.start();
  }

  /// Visa lokal push-notis
  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails("channelId", "Notiser",
        importance: Importance.high, priority: Priority.high);

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, "Notis", message, details);
  }

  /// Stäng WebSocket-anslutning
  Future<void> closeConnection() async {
    await _hubConnection.stop();
  }

  /// Hämta alla registreringsskyltar
  Future<List<Map<String, String>>> getLicensePlates() async {
    try {
      final response = await _dio.get('/ListPlates');
      if (response.data is Map<String, dynamic> && response.data["plates"] is List) {
        return (response.data["plates"] as List)
            .map((plate) => {
          "plate_number": plate["plate_number"].toString(),
          "status": plate["status"].toString(),
        })
            .toList();
      } else {
        throw Exception("Felaktigt svar från servern");
      }
    } catch (e) {
      throw Exception('Misslyckades att hämta registreringsskyltar: $e');
    }
  }

  /// Lägg till en ny registreringsskylt
  Future<void> addLicensePlate(String plate, String status) async {
    try {
      await _dio.post('/AddPlate', data: {
        'plate_number': plate,
        'status': status,
      });
    } catch (e) {
      throw Exception('Misslyckades att lägga till registreringsskylten: $e');
    }
  }

  /// Radera en registreringsskylt
  Future<void> deleteLicensePlate(String plate) async {
    try {
      await _dio.delete("/DeletePlate/$plate");
    } catch (e) {
      throw Exception('Misslyckades att radera registreringsskylten: $e');
    }
  }

  /// Uppdatera status på en registreringsskylt
  Future<void> updatePlateStatus(String plate, String newStatus) async {
    try {
      await _dio.put("/UpdatePlate", data: {
        "plate_number": plate,
        "status": newStatus,
      });
    } catch (e) {
      throw Exception('Misslyckades att uppdatera status: $e');
    }
  }

  /// Öppna grinden
  Future<void> openGate() async {
    try {
      await _dio.post('/OpenGate');
    } catch (e) {
      throw Exception('Misslyckades att öppna grinden: $e');
    }
  }

  /// Stäng grinden
  Future<void> closeGate() async {
    try {
      await _dio.post('/CloseGate');
    } catch (e) {
      throw Exception('Misslyckades att stänga grinden: $e');
    }
  }

  /// Skicka notis vid känd bil
  Future<void> sendNotificationKnown(String plate) async {
    try {
      await _dio.post('/SendNotificationKnown', data: {
        'plate_number': plate,
      });
    } catch (e) {
      throw Exception('Misslyckades att skicka notis för känd bil: $e');
    }
  }

  /// Skicka notis vid okänd bil
  Future<void> sendNotificationUnknown(String plate) async {
    try {
      await _dio.post('/SendNotificationUnknown', data: {
        'plate_number': plate,
      });
    } catch (e) {
      throw Exception('Misslyckades att skicka notis för okänd bil: $e');
    }
  }

  /// Styra grinden manuellt
  Future<void> controlGate(String action) async {
    try {
      await _dio.post('/ControlGate', data: {
        'action': action,
      });
    } catch (e) {
      throw Exception('Misslyckades att styra grinden: $e');
    }
  }

  /// Hämta de senaste registreringsskyltarna
  Future<List<String>> getRecentPlates() async {
    try {
      final response = await _dio.get('/GetRecentPlates');
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Misslyckades att hämta senaste registreringsskyltarna: $e');
    }
  }

  /// Hämta aktuell systemstatus
  Future<String> getSystemStatus() async {
    try {
      final response = await _dio.get('/GetSystemStatus');
      return response.data.toString();
    } catch (e) {
      throw Exception('Misslyckades att hämta systemstatus: $e');
    }
  }

  /// Skicka en bild från webbkameran till servern
  Future<void> sendWebcamPicture() async {
    try {
      await _dio.post('/WebcamPicture');
    } catch (e) {
      throw Exception('Misslyckades att skicka webbkamera-bild: $e');
    }
  }
}
