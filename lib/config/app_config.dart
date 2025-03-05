class AppConfig {
  // URL base per l'API del backend
  static const String apiBaseUrl = 'https://api.outdoor-navigation.example.com';
  
  // Credenziali Supabase
  static const String supabaseUrl = 'https://onydqhcdeevlhrbxeuik.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ueWRxaGNkZWV2bGhyYnhldWlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2OTQ5MzEsImV4cCI6MjA1NTI3MDkzMX0.XV4cugZN2jH-UelvxJ6aRhDhaQmG_Z_r9X2CmI8-e_U';
  
  // Chiavi API per servizi esterni
  static const String mapboxApiKey = 'YOUR_MAPBOX_API_KEY';
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
  
  // Coordinate predefinite per la mappa (Italia)
  static const double defaultLatitude = 41.9028; // Roma
  static const double defaultLongitude = 12.4964; // Roma
  static const double defaultZoom = 6.0;
  
  // Configurazioni per i calcoli del percorso
  static const Map<String, double> avgSpeeds = {
    'trekking': 4.5,   // km/h
    'cycling': 18.0,   // km/h
    'ebike': 25.0,     // km/h
    'running': 9.0,    // km/h
  };
  
  // Etichette per le attività
  static const Map<String, String> activityLabels = {
    'trekking': 'Trekking',
    'cycling': 'Ciclismo',
    'ebike': 'E-Bike',
    'running': 'Corsa',
  };
  
  // Icone per le attività (codice stringa dell'icona)
  static const Map<String, String> activityIcons = {
    'trekking': 'hiking',
    'cycling': 'directions_bike',
    'ebike': 'electric_bike',
    'running': 'directions_run',
  };
  
  // Configurazioni per il calcolo delle calorie
  static const Map<String, double> calorieFactors = {
    'trekking': 7.0,   // kcal/(kg*h)
    'cycling': 8.0,    // kcal/(kg*h)
    'ebike': 4.0,      // kcal/(kg*h)
    'running': 13.0,   // kcal/(kg*h)
  };
  
  // Configurazioni per il consumo della batteria (e-bike)
  static const Map<String, dynamic> batteryConsumption = {
    'baseConsumption': 1.2,     // Wh/km in piano
    'uphillFactor': 0.05,       // Wh/km per ogni metro di dislivello positivo
    'downhillFactor': -0.02,    // Wh/km per ogni metro di dislivello negativo
    'weightFactor': 0.005,      // Wh/km per ogni kg di peso del ciclista oltre 70kg
    'speedFactor': 0.03,        // Wh/km per ogni km/h oltre i 20km/h
    'averageBatteryCapacity': 500, // Wh di una batteria media
  };
  
  // Livelli di difficoltà del percorso
  static const Map<String, Map<String, dynamic>> difficultyLevels = {
    'easy': {
      'color': 0xFF4CAF50,
      'maxSlope': 5.0,
      'maxDistance': {
        'trekking': 10.0,
        'cycling': 30.0,
        'ebike': 40.0,
        'running': 8.0,
      },
    },
    'medium': {
      'color': 0xFFFFC107,
      'maxSlope': 10.0,
      'maxDistance': {
        'trekking': 20.0,
        'cycling': 60.0,
        'ebike': 80.0,
        'running': 15.0,
      },
    },
    'hard': {
      'color': 0xFFFF5722,
      'maxSlope': 15.0,
      'maxDistance': {
        'trekking': 35.0,
        'cycling': 100.0,
        'ebike': 120.0,
        'running': 25.0,
      },
    },
    'expert': {
      'color': 0xFFF44336,
      'maxSlope': 999.0,
      'maxDistance': {
        'trekking': 999.0,
        'cycling': 999.0,
        'ebike': 999.0,
        'running': 999.0,
      },
    },
  };
  
  // Label per i livelli di difficoltà  
  static const Map<String, String> difficultyLabels = {
    'easy': 'Facile',
    'medium': 'Media',
    'hard': 'Difficile',
    'expert': 'Esperto',
  };
  
  // Colori per i livelli di difficoltà
  static const Map<String, int> difficultyColors = {
    'easy': 0xFF4CAF50,    // verde
    'medium': 0xFFFFC107,  // giallo
    'hard': 0xFFFF5722,    // arancione
    'expert': 0xFFF44336,  // rosso
  };
  
  // Regioni meteo stagionali
  static const Map<String, List<String>> seasonalWeather = {
    'summer': [
      'Molto caldo e soleggiato. Porta molta acqua e protezione solare.',
      'Probabili temporali pomeridiani. Controlla le previsioni.',
      'Temperatura elevata. Parti presto al mattino.',
    ],
    'autumn': [
      'Possibili nebbie mattutine. Parti dopo le 10.',
      'Temperature moderate. Porta abbigliamento a strati.',
      'Possibili piogge improvvise. Porta giacca impermeabile.',
    ],
    'winter': [
      'Temperature basse. Abbigliamento tecnico termico consigliato.',
      'Possibile neve o ghiaccio. Verifica le condizioni del percorso.',
      'Giornate corte. Parti presto per avere luce sufficiente.',
    ],
    'spring': [
      'Temperature in aumento. Abbigliamento a strati consigliato.',
      'Terreno potenzialmente fangoso. Scarpe adeguate.',
      'Possibili piogge. Porta giacca impermeabile.',
    ],
  };
}