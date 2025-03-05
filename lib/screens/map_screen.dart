import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:outdoor_navigation/models/route_model.dart';

class MapScreen extends StatefulWidget {
  final RouteModel? route;

  const MapScreen({super.key, this.route});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Dati salvati delle principali città per la mappa
  final Map<String, LatLng> _cityCoordinates = {
    'napoli': const LatLng(40.8518, 14.2681),
    'torino': const LatLng(45.0703, 7.6869),
    'milano': const LatLng(45.4642, 9.1900),
    'roma': const LatLng(41.9028, 12.4964),
    'firenze': const LatLng(43.7696, 11.2558),
    'bologna': const LatLng(44.4949, 11.3426),
    'venezia': const LatLng(45.4408, 12.3155),
    'genova': const LatLng(44.4056, 8.9463),
    'palermo': const LatLng(38.1157, 13.3615),
    'trento': const LatLng(46.0748, 11.1217),
  };
  
  bool _showChargingStations = true;
  bool _showPointsOfInterest = true;
  bool _showIntermediateStops = true;
  
  @override
  Widget build(BuildContext context) {
    // Se non c'è un percorso specifico, mostra la mappa dell'Italia
    LatLng center;
    double zoom;
    
    if (widget.route != null) {
      // Usa le coordinate del punto di partenza come centro
      final startCity = widget.route!.startPoint.toLowerCase();
      final endCity = widget.route!.endPoint.toLowerCase();
      
      if (_cityCoordinates.containsKey(startCity) && _cityCoordinates.containsKey(endCity)) {
        // Calcola il centro tra i due punti
        center = LatLng(
          (_cityCoordinates[startCity]!.latitude + _cityCoordinates[endCity]!.latitude) / 2,
          (_cityCoordinates[startCity]!.longitude + _cityCoordinates[endCity]!.longitude) / 2,
        );
        
        // Imposta lo zoom in base alla distanza
        zoom = 8.0;
      } else {
        // Usa valori predefiniti
        center = const LatLng(41.9028, 12.4964); // Roma
        zoom = 6.0;
      }
    } else {
      // Usa valori predefiniti
      center = const LatLng(41.9028, 12.4964); // Roma
      zoom = 6.0;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.route != null ? widget.route!.title : 'Mappa',
        ),
      ),
      body: Stack(
        children: [
          // Mappa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
            ),
            children: [
              // Livello base della mappa (tile layer)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.outdoor_navigation',
              ),
              
              // Percorso (se disponibile)
              if (widget.route != null)
                _buildRoutePolyline(),
              
              // Marker per le città di partenza e arrivo
              if (widget.route != null)
                _buildCityMarkers(),
              
              // Marker per le stazioni di ricarica (solo per e-bike)
              if (widget.route?.chargingStations != null && 
                  widget.route!.activityType == 'ebike' && 
                  _showChargingStations)
                _buildChargingStationMarkers(),
              
              // Marker per i punti di interesse
              if (widget.route?.pointsOfInterest != null && _showPointsOfInterest)
                _buildPoiMarkers(),
              
              // Marker per le tappe intermedie
              if (widget.route?.optimizedStops != null && _showIntermediateStops)
                _buildIntermediateStopMarkers(),
            ],
          ),
          
          // Controlli della mappa
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                // Zoom In
                _buildMapButton(
                  icon: Icons.add,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                // Zoom Out
                _buildMapButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                // Centra mappa
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    _mapController.move(center, zoom);
                  },
                ),
              ],
            ),
          ),
          
          // Opzioni di visualizzazione
          if (widget.route != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle per le stazioni di ricarica
                      if (widget.route!.activityType == 'ebike' && 
                          widget.route!.chargingStations != null)
                        _buildToggleOption(
                          icon: Icons.ev_station,
                          label: 'Stazioni di ricarica',
                          value: _showChargingStations,
                          onChanged: (value) {
                            setState(() {
                              _showChargingStations = value;
                            });
                          },
                        ),
                      
                      // Toggle per i punti di interesse
                      if (widget.route!.pointsOfInterest != null)
                        _buildToggleOption(
                          icon: Icons.place,
                          label: 'Punti di interesse',
                          value: _showPointsOfInterest,
                          onChanged: (value) {
                            setState(() {
                              _showPointsOfInterest = value;
                            });
                          },
                        ),
                      
                      // Toggle per le tappe intermedie
                      if (widget.route!.optimizedStops != null)
                        _buildToggleOption(
                          icon: Icons.hotel,
                          label: 'Tappe intermedie',
                          value: _showIntermediateStops,
                          onChanged: (value) {
                            setState(() {
                              _showIntermediateStops = value;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).primaryColor,
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
  
  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
  
  Widget _buildRoutePolyline() {
    final startCity = widget.route!.startPoint.toLowerCase();
    final endCity = widget.route!.endPoint.toLowerCase();
    
    if (!_cityCoordinates.containsKey(startCity) || !_cityCoordinates.containsKey(endCity)) {
      return const SizedBox.shrink();
    }
    
    final points = <LatLng>[
      _cityCoordinates[startCity]!,
      _cityCoordinates[endCity]!,
    ];
    
    // Aggiungi eventuali tappe intermedie come punti della polyline
    if (widget.route!.optimizedStops != null && _showIntermediateStops) {
      for (final stop in widget.route!.optimizedStops!.suggestedStops) {
        final cityName = stop.city.toLowerCase();
        if (_cityCoordinates.containsKey(cityName)) {
          // Inserisci le tappe nel punto corretto della polyline
          points.insert(points.length - 1, _cityCoordinates[cityName]!);
        }
      }
    }
    
    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          color: Theme.of(context).primaryColor,
          strokeWidth: 4.0,
        ),
      ],
    );
  }
  
  Widget _buildCityMarkers() {
    final startCity = widget.route!.startPoint.toLowerCase();
    final endCity = widget.route!.endPoint.toLowerCase();
    
    if (!_cityCoordinates.containsKey(startCity) || !_cityCoordinates.containsKey(endCity)) {
      return const SizedBox.shrink();
    }
    
    return MarkerLayer(
      markers: [
        // Marker città di partenza
        Marker(
          point: _cityCoordinates[startCity]!,
          width: 40,
          height: 40,
          child: _buildMarkerIcon(
            icon: Icons.trip_origin,
            color: Colors.green,
            label: widget.route!.startPoint,
          ),
        ),
        
        // Marker città di arrivo
        Marker(
          point: _cityCoordinates[endCity]!,
          width: 40,
          height: 40,
          child: _buildMarkerIcon(
            icon: Icons.location_on,
            color: Colors.red,
            label: widget.route!.endPoint,
          ),
        ),
      ],
    );
  }
  
  Widget _buildChargingStationMarkers() {
    final stations = widget.route!.chargingStations!.availableStations;
    
    return MarkerLayer(
      markers: stations.map((station) {
        return Marker(
          point: LatLng(station.coordinates.lat, station.coordinates.lon),
          width: 40,
          height: 40,
          child: _buildMarkerIcon(
            icon: Icons.ev_station,
            color: Colors.blue,
            label: station.name,
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildPoiMarkers() {
    final pois = widget.route!.pointsOfInterest!.availablePoi;
    
    return MarkerLayer(
      markers: pois.map((poi) {
        // Ottieni le coordinate della città del POI
        final cityName = poi.city.toLowerCase();
        if (!_cityCoordinates.containsKey(cityName)) {
          return null; // Salta se la città non è supportata
        }
        
        // Aggiungi un piccolo offset casuale per evitare che tutti i POI siano sovrapposti
        final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
        final latOffset = (random - 0.5) * 0.01;
        final lonOffset = (random - 0.5) * 0.01;
        
        final point = LatLng(
          _cityCoordinates[cityName]!.latitude + latOffset,
          _cityCoordinates[cityName]!.longitude + lonOffset,
        );
        
        return Marker(
          point: point,
          width: 40,
          height: 40,
          child: _buildMarkerIcon(
            icon: _getPoiTypeIcon(poi.type),
            color: Colors.purple,
            label: poi.name,
          ),
        );
      }).whereType<Marker>().toList(), // Filtra i null
    );
  }
  
  Widget _buildIntermediateStopMarkers() {
    if (widget.route!.optimizedStops == null || 
        widget.route!.optimizedStops!.suggestedStops.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return MarkerLayer(
      markers: widget.route!.optimizedStops!.suggestedStops.map((stop) {
        final cityName = stop.city.toLowerCase();
        if (!_cityCoordinates.containsKey(cityName)) {
          return null; // Salta se la città non è supportata
        }
        
        return Marker(
          point: _cityCoordinates[cityName]!,
          width: 40,
          height: 40,
          child: _buildMarkerIcon(
            icon: Icons.hotel,
            color: Colors.orange,
            label: 'Tappa ${stop.stopNumber}',
          ),
        );
      }).whereType<Marker>().toList(), // Filtra i null
    );
  }
  
  Widget _buildMarkerIcon({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        // Tooltip con il nome
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        // Icona del marker
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }
  
  IconData _getPoiTypeIcon(String type) {
    switch (type) {
      case 'monument':
        return Icons.location_city;
      case 'museum':
        return Icons.museum;
      case 'religious':
        return Icons.church;
      case 'district':
        return Icons.domain;
      case 'culture':
        return Icons.theater_comedy;
      case 'square':
        return Icons.crop_square;
      case 'attraction':
        return Icons.attractions;
      case 'market':
        return Icons.shopping_basket;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.place;
    }
  }
}