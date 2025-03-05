import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:outdoor_navigation/config/app_config.dart';
import 'package:outdoor_navigation/models/route_model.dart';
import 'package:outdoor_navigation/models/poi_model.dart';
import 'package:outdoor_navigation/models/weather_model.dart';

class ApiService extends ChangeNotifier {
  final String baseUrl = AppConfig.apiBaseUrl;
  String? _authToken;
  
  // Setter per il token di autenticazione
  set authToken(String? token) {
    _authToken = token;
    notifyListeners();
  }
  
  // Getter per verificare se l'utente è autenticato
  bool get isAuthenticated => _authToken != null;
  
  // Headers per le richieste HTTP
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // Metodo per creare un nuovo percorso
  Future<RouteModel> createRoute({
    required String title,
    String? description,
    required String activityType,
    required String startPoint,
    required String endPoint,
    int? weight,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'activityType': activityType,
        'startPoint': startPoint,
        'endPoint': endPoint,
        'weight': weight ?? 70, // Default peso ciclista 70kg
      }),
    );
    
    if (response.statusCode == 201) {
      return RouteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore durante la creazione del percorso: ${response.body}');
    }
  }
  
  // Metodo per ottenere tutti i percorsi
  Future<List<RouteModel>> getRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> routesJson = jsonDecode(response.body);
      return routesJson.map((json) => RouteModel.fromJson(json)).toList();
    } else {
      throw Exception('Errore durante il recupero dei percorsi: ${response.body}');
    }
  }
  
  // Metodo per ottenere un percorso specifico
  Future<RouteModel> getRoute(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$id'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore durante il recupero del percorso: ${response.body}');
    }
  }
  
  // Metodo per ottenere i punti di interesse vicino a un percorso
  Future<List<PointOfInterest>> getPointsOfInterest(String routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId/pois'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> poisJson = jsonDecode(response.body);
      return poisJson.map((json) => PointOfInterest.fromJson(json)).toList();
    } else {
      throw Exception('Errore durante il recupero dei punti di interesse: ${response.body}');
    }
  }
  
  // Metodo per ottenere previsioni meteo per un percorso
  Future<WeatherForecast> getWeatherForecast(String routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId/weather'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore durante il recupero delle previsioni meteo: ${response.body}');
    }
  }
  
  // Metodo per condividere un percorso
  Future<String> shareRoute(String routeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/share'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['shareCode'] as String;
    } else {
      throw Exception('Errore durante la condivisione del percorso: ${response.body}');
    }
  }
  
  // Metodo per accedere a un percorso condiviso
  Future<RouteModel> accessSharedRoute(String shareCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/shared/$shareCode'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Errore durante l\'accesso al percorso condiviso: ${response.body}');
    }
  }
  
  // Metodo per trovare stazioni di ricarica per e-bike
  Future<List<Map<String, dynamic>>> findChargingStations(
    double latitude, 
    double longitude, 
    double radius
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stations?lat=$latitude&lon=$longitude&radius=$radius'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> stationsJson = jsonDecode(response.body);
      return stationsJson.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Errore durante la ricerca delle stazioni di ricarica: ${response.body}');
    }
  }
  
  // Metodo per calcolare il consumo di batteria per e-bike
  Future<Map<String, dynamic>> calculateBatteryConsumption(
    String routeId, {
    required int weight,
    required int batteryCapacity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ebike/battery-consumption'),
      headers: _headers,
      body: jsonEncode({
        'routeId': routeId,
        'weight': weight,
        'batteryCapacity': batteryCapacity,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Errore nel calcolo del consumo della batteria: ${response.body}');
    }
  }
}