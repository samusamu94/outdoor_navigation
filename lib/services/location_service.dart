import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  // Ottieni la posizione corrente dell'utente
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Controlla se la localizzazione è abilitata
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Controlla i permessi della localizzazione
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Ottieni la posizione
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high, // ✅ Usa "desiredAccuracy"
);


      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }
  
  // Calcola la distanza tra due punti in km
  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    final double km = distance.as(LengthUnit.Kilometer, point1, point2);
    return km;
  }
  
  // Calcola la direzione tra due punti (in gradi, 0-360)
  double calculateBearing(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.bearing(start, end);
  }
  
  // Controlla se un punto è all'interno di un raggio specificato (in km)
  bool isWithinRadius(LatLng center, LatLng point, double radius) {
    final double distanceInKm = calculateDistance(center, point);
    return distanceInKm <= radius;
  }
  
  // Verifica se possiamo accedere alla localizzazione
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }
  
  // Richiedi esplicitamente i permessi della localizzazione
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }
  
  // Avvia l'ascolto della posizione in tempo reale
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Aggiorna ogni 10 metri
      ),
    );
  }
  
  // Converti coordinate Geolocator in LatLng per flutter_map
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}