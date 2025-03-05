import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outdoor_navigation/models/route_model.dart';
import 'dart:convert';

class StorageService extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<RouteModel> _recentRoutes = [];
  List<RouteModel> _favoriteRoutes = [];
  Map<String, dynamic> _userSettings = {};

  // Inizializzazione del servizio
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  // Carica tutti i dati dalle SharedPreferences
  Future<void> _loadData() async {
    await _loadRecentRoutes();
    await _loadFavoriteRoutes();
    await _loadUserSettings();
    notifyListeners();
  }

  // Carica i percorsi recenti
  Future<void> _loadRecentRoutes() async {
    if (_prefs == null) return;
    
    final recentRoutesJson = _prefs!.getStringList('recentRoutes') ?? [];
    _recentRoutes = recentRoutesJson
        .map((json) => RouteModel.fromJson(jsonDecode(json)))
        .toList();
  }

  // Carica i percorsi preferiti
  Future<void> _loadFavoriteRoutes() async {
    if (_prefs == null) return;
    
    final favoriteRoutesJson = _prefs!.getStringList('favoriteRoutes') ?? [];
    _favoriteRoutes = favoriteRoutesJson
        .map((json) => RouteModel.fromJson(jsonDecode(json)))
        .toList();
  }

  // Carica le impostazioni utente
  Future<void> _loadUserSettings() async {
    if (_prefs == null) return;
    
    final settingsJson = _prefs!.getString('userSettings');
    if (settingsJson != null) {
      _userSettings = jsonDecode(settingsJson);
    }
  }

  // Ottiene i percorsi recenti
  List<RouteModel> getRecentRoutes() {
    return List.unmodifiable(_recentRoutes);
  }

  // Ottiene i percorsi preferiti
  List<RouteModel> getFavoriteRoutes() {
    return List.unmodifiable(_favoriteRoutes);
  }

  // Ottiene le impostazioni utente
  Map<String, dynamic> getUserSettings() {
    return Map.unmodifiable(_userSettings);
  }

  // Aggiunge un percorso ai recenti
  Future<void> addRecentRoute(RouteModel route) async {
    if (_prefs == null) await init();
    
    // Rimuovi il percorso se già presente
    _recentRoutes.removeWhere((r) => r.id == route.id);
    
    // Aggiungi il percorso all'inizio della lista
    _recentRoutes.insert(0, route);
    
    // Limita a 10 percorsi recenti
    if (_recentRoutes.length > 10) {
      _recentRoutes = _recentRoutes.sublist(0, 10);
    }
    
    // Salva nelle SharedPreferences
    await _saveRecentRoutes();
    
    notifyListeners();
  }

  // Salva i percorsi recenti nelle SharedPreferences
  Future<void> _saveRecentRoutes() async {
    if (_prefs == null) return;
    
    final recentRoutesJson = _recentRoutes
        .map((route) => jsonEncode(route.toJson()))
        .toList();
    
    await _prefs!.setStringList('recentRoutes', recentRoutesJson);
  }

  // Aggiunge o rimuove un percorso dai preferiti
  Future<void> toggleFavoriteRoute(RouteModel route) async {
    if (_prefs == null) await init();
    
    final isAlreadyFavorite = _favoriteRoutes.any((r) => r.id == route.id);
    
    if (isAlreadyFavorite) {
      _favoriteRoutes.removeWhere((r) => r.id == route.id);
    } else {
      _favoriteRoutes.add(route);
    }
    
    await _saveFavoriteRoutes();
    
    notifyListeners();
  }

  // Salva i percorsi preferiti nelle SharedPreferences
  Future<void> _saveFavoriteRoutes() async {
    if (_prefs == null) return;
    
    final favoriteRoutesJson = _favoriteRoutes
        .map((route) => jsonEncode(route.toJson()))
        .toList();
    
    await _prefs!.setStringList('favoriteRoutes', favoriteRoutesJson);
  }

  // Aggiorna le impostazioni utente
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (_prefs == null) await init();
    
    _userSettings = {..._userSettings, ...settings};
    
    final settingsJson = jsonEncode(_userSettings);
    await _prefs!.setString('userSettings', settingsJson);
    
    notifyListeners();
  }

  // Rimuove tutti i dati
  Future<void> clearAll() async {
    if (_prefs == null) return;
    
    await _prefs!.clear();
    
    _recentRoutes = [];
    _favoriteRoutes = [];
    _userSettings = {};
    
    notifyListeners();
  }

  // Metodo per salvare una stringa nelle preferenze
  Future<void> saveString(String key, String value) async {
    if (_prefs == null) await init();
    await _prefs!.setString(key, value);
  }

  // Metodo per recuperare una stringa dalle preferenze
  Future<String?> getString(String key) async {
    if (_prefs == null) await init();
    return _prefs!.getString(key);
  }
}