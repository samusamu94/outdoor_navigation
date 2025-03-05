import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:outdoor_navigation/models/route_model.dart';
import 'package:outdoor_navigation/config/app_config.dart';
import 'package:outdoor_navigation/services/storage_service.dart';
import 'package:outdoor_navigation/widgets/weather_widget.dart';
import 'package:outdoor_navigation/widgets/battery_info_widget.dart';
import 'package:outdoor_navigation/widgets/poi_list_widget.dart';
import 'package:outdoor_navigation/screens/map_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Controlla se il percorso è nei preferiti
    final storageService = Provider.of<StorageService>(context, listen: false);
    _isFavorite = storageService.getFavoriteRoutes().any((r) => r.id == widget.route.id);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _toggleFavorite() {
    final storageService = Provider.of<StorageService>(context, listen: false);
    
    setState(() {
      _isFavorite = !_isFavorite;
      
      storageService.toggleFavoriteRoute(widget.route);
    });
  }
  
  void _shareRoute() {
    Share.share(
      'Dai un\'occhiata a questo percorso: ${widget.route.title}\n'
      'Da ${widget.route.startPoint} a ${widget.route.endPoint}\n'
      'Distanza: ${widget.route.distance} km, Durata: ${widget.route.estimatedDurationFormatted}\n\n'
      'Collegamento: ${widget.route.sharing.shareableLink}',
      subject: 'Condividi percorso: ${widget.route.title}',
    );
  }
  
void _copyShareLink() {
  Clipboard.setData(ClipboardData(text: widget.route.sharing.shareableLink)).then((_) {
    if (!mounted) return; // ✅ Verifica che il widget sia ancora montato prima di usare context

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiato negli appunti'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
} 
  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final theme = Theme.of(context);
    
    // Ottieni il colore della difficoltà
    final difficultyColor = Color(AppConfig.difficultyLevels[route.difficulty]?['color'] ?? 0xFF4CAF50);
    
    // Icona dell'attività
    IconData activityIcon;
    switch (route.activityType) {
      case 'trekking':
        activityIcon = Icons.hiking;
        break;
      case 'cycling':
        activityIcon = Icons.directions_bike;
        break;
      case 'ebike':
        activityIcon = Icons.electric_bike;
        break;
      case 'running':
        activityIcon = Icons.directions_run;
        break;
      default:
        activityIcon = Icons.route;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(route.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareRoute,
          ),
        ],
      ),
      body: Column(
        children: [
          // Intestazione con informazioni principali
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Da - A
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${route.startPoint} - ${route.endPoint}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Statistiche
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tipo di attività
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                          child: Icon(
                            activityIcon,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConfig.activityLabels[route.activityType] ?? 
                          route.activityType.toUpperCase(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    // Distanza
                    Column(
                      children: [
                        Text(
                          route.distance.toStringAsFixed(1),
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          'km',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    // Durata
                    Column(
                      children: [
                        Text(
                          route.estimatedDurationFormatted.split(' ')[0],
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          route.estimatedDurationFormatted.split(' ')[1],
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    // Dislivello
                    Column(
                      children: [
                        Text(
                          '${route.elevationGain}',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          'm',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    // Difficoltà
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            route.difficulty.toUpperCase(),
                            style: TextStyle(
                              color: difficultyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Difficoltà',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Meteo'),
              Tab(text: 'Tappe'),
              Tab(text: 'POI'),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Info
                _buildInfoTab(context),
                
                // Tab Meteo
                _buildWeatherTab(context),
                
                // Tab Tappe
                _buildStopsTab(context),
                
                // Tab POI
                _buildPoiTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapScreen(route: route),
            ),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Visualizza Mappa'),
      ),
    );
  }
  
  // Tab Info
  Widget _buildInfoTab(BuildContext context) {
    final route = widget.route;
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descrizione
          if (route.description != null && route.description!.isNotEmpty) ...[
            Text(
              'Descrizione',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(route.description!),
            const SizedBox(height: 24),
          ],
          
          // Difficoltà
          Text(
            'Difficoltà',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(route.difficultyInfo.message),
          const SizedBox(height: 24),
          
          // Calorie
          if (route.caloriesInfo != null) ...[
            Text(
              'Calorie',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  '${route.caloriesInfo!.caloriesBurned} kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(route.caloriesInfo!.message),
            const SizedBox(height: 24),
          ],
          
          // Informazioni batteria (solo per e-bike)
          if (route.activityType == 'ebike' && route.batteryInfo != null) ...[
            Text(
              'Informazioni Batteria',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            BatteryInfoWidget(batteryInfo: route.batteryInfo!),
            const SizedBox(height: 24),
            
            // Stazioni di ricarica
            if (route.chargingStations != null) ...[
              Text(
                'Stazioni di Ricarica',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(route.chargingStations!.message),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: route.chargingStations!.availableStations.length,
                itemBuilder: (context, index) {
                  final station = route.chargingStations!.availableStations[index];
                  return ListTile(
                    leading: const Icon(Icons.ev_station),
                    title: Text(station.name),
                    subtitle: Text('${station.address}, ${station.city}'),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ],
          
          // Condivisione
          Text(
            'Condivisione',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          route.sharing.shareableLink,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyShareLink,
                        tooltip: 'Copia link',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Codice di condivisione: ${route.sharing.shareCode}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _shareRoute,
                    icon: const Icon(Icons.share),
                    label: const Text('Condividi'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Tab Meteo
  Widget _buildWeatherTab(BuildContext context) {
    final route = widget.route;
    
    if (route.weatherForecast == null) {
      return const Center(
        child: Text('Nessuna previsione meteo disponibile'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: WeatherWidget(weatherForecast: route.weatherForecast!),
    );
  }
  
  // Tab Tappe
  Widget _buildStopsTab(BuildContext context) {
    final route = widget.route;
    final theme = Theme.of(context);
    
    if (route.optimizedStops == null) {
      return const Center(
        child: Text('Nessuna tappa suggerita disponibile'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tappe Suggerite',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(route.optimizedStops!.message),
          const SizedBox(height: 16),
          
          if (route.optimizedStops!.stopsNeeded == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Questo percorso è completabile in un giorno!'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: route.optimizedStops!.suggestedStops.length,
              itemBuilder: (context, index) {
                final stop = route.optimizedStops!.suggestedStops[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tappa ${stop.stopNumber}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stop.city,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Distanza dalla tappa precedente:'),
                            Text(
                              '${stop.distanceFromPrevious.toStringAsFixed(1)} km',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        
                        if (stop.distanceToDestination != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Distanza alla destinazione:'),
                              Text(
                                '${stop.distanceToDestination!.toStringAsFixed(1)} km',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        
                        // Punti di interesse nella tappa
                        if (stop.pointsOfInterest.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Punti di interesse',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: stop.pointsOfInterest.length,
                            itemBuilder: (context, poiIndex) {
                              final poi = stop.pointsOfInterest[poiIndex];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.place),
                                title: Text(poi.name),
                                subtitle: Text(poi.description),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text(poi.rating.toString()),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  // Tab POI (Punti di Interesse)
  Widget _buildPoiTab(BuildContext context) {
    final route = widget.route;
    
    if (route.pointsOfInterest == null || route.pointsOfInterest!.availablePoi.isEmpty) {
      return const Center(
        child: Text('Nessun punto di interesse disponibile'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: PoiListWidget(pointsOfInterest: route.pointsOfInterest!),
    );
  }
}