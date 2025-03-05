import 'package:flutter/material.dart';
import 'package:outdoor_navigation/models/route_model.dart';
import 'package:outdoor_navigation/config/app_config.dart';
import 'package:outdoor_navigation/screens/route_detail_screen.dart';
import 'package:outdoor_navigation/services/storage_service.dart';
import 'package:provider/provider.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;
  final bool showDetails;
  
  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storageService = Provider.of<StorageService>(context);
    
    // Verifica se il percorso è nei preferiti
    final isFavorite = storageService.getFavoriteRoutes().any((r) => r.id == route.id);
    
    // Ottieni il colore della difficoltà
    final difficultyColor = Color(AppConfig.difficultyLevels[route.difficulty]?['color'] ?? 0xFF4CAF50);
    
    // Ottieni l'etichetta dell'attività
    final activityLabel = AppConfig.activityLabels[route.activityType] ?? 
                         route.activityType.toUpperCase();
    
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
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {
          // Naviga alla schermata di dettaglio del percorso
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreen(route: route),
            ),
          );
          
          // Aggiungi ai percorsi recenti
          storageService.addRecentRoute(route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione con titolo e icona preferiti
            ListTile(
              title: Text(
                route.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  // Aggiungi/rimuovi dai preferiti
                  storageService.toggleFavoriteRoute(route);
                },
              ),
            ),
            
            // Informazioni principali
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Origine - Destinazione
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${route.startPoint} - ${route.endPoint}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tipo di attività
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(activityIcon, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          activityLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Livello difficoltà, distanza, durata
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Difficoltà
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: difficultyColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              route.difficulty.toUpperCase(),
                              style: TextStyle(
                                color: difficultyColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Difficoltà', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    
                    const VerticalDivider(),
                    
                    // Distanza
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${route.distance.toStringAsFixed(1)} km',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Distanza', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    
                    const VerticalDivider(),
                    
                    // Durata
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            route.estimatedDurationFormatted,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Durata', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Mostra dettagli aggiuntivi se richiesto
            if (showDetails) ...[
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Dislivello
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text('${route.elevationGain} m'),
                        ],
                      ),
                    ),
                    
                    // Informazioni batteria (solo per e-bike)
                    if (route.activityType == 'ebike' && route.batteryInfo != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.battery_charging_full,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text('${route.batteryInfo!.consumptionWh} Wh'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}