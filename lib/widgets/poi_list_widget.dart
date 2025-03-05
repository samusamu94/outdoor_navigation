import 'package:flutter/material.dart';
import 'package:outdoor_navigation/models/poi_model.dart';

class PoiListWidget extends StatefulWidget {
  final PointsOfInterestInfo pointsOfInterest;

  const PoiListWidget({super.key, required this.pointsOfInterest});

  @override
  State<PoiListWidget> createState() => _PoiListWidgetState();
}

class _PoiListWidgetState extends State<PoiListWidget> {
  String _selectedFilter = 'Tutti';
  final TextEditingController _searchController = TextEditingController();
  List<PointOfInterest> _filteredPoi = [];
  
  @override
  void initState() {
    super.initState();
    _filteredPoi = widget.pointsOfInterest.availablePoi;
    
    _searchController.addListener(() {
      _filterPoi();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterPoi() {
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredPoi = widget.pointsOfInterest.availablePoi.where((poi) {
        // Applica filtro di tipo
        if (_selectedFilter != 'Tutti' && 
            _getPoiTypeLabel(poi.type).toLowerCase() != _selectedFilter.toLowerCase()) {
          return false;
        }
        
        // Applica filtro di ricerca testuale
        if (searchText.isNotEmpty) {
          return poi.name.toLowerCase().contains(searchText) || 
                 poi.description.toLowerCase().contains(searchText) ||
                 poi.city.toLowerCase().contains(searchText);
        }
        
        return true;
      }).toList();
    });
  }
  
  List<String> _getUniquePoiTypes() {
    final types = widget.pointsOfInterest.availablePoi
        .map((poi) => _getPoiTypeLabel(poi.type))
        .toSet()
        .toList();
    
    // Aggiungi l'opzione 'Tutti' all'inizio
    return ['Tutti', ...types];
  }
  
  String _getPoiTypeLabel(String type) {
    switch (type) {
      case 'monument':
        return 'Monumento';
      case 'museum':
        return 'Museo';
      case 'religious':
        return 'Religioso';
      case 'district':
        return 'Quartiere';
      case 'culture':
        return 'Culturale';
      case 'square':
        return 'Piazza';
      case 'attraction':
        return 'Attrazione';
      case 'market':
        return 'Mercato';
      case 'shopping':
        return 'Shopping';
      default:
        return type.substring(0, 1).toUpperCase() + type.substring(1);
    }
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
  
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) {
      return Colors.green;
    } else if (rating >= 4.0) {
      return Colors.lightGreen;
    } else if (rating >= 3.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uniqueTypes = _getUniquePoiTypes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intestazione con informazioni generali
        Text(
          'Punti di Interesse',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(widget.pointsOfInterest.message),
        const SizedBox(height: 16),
        
        // Campo di ricerca
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cerca punti di interesse...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filtri per tipo
        Text(
          'Filtra per tipo',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: uniqueTypes.length,
            itemBuilder: (context, index) {
              final type = uniqueTypes[index];
              final isSelected = _selectedFilter == type;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? type : 'Tutti';
                      _filterPoi();
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Lista dei punti di interesse
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredPoi.length,
          itemBuilder: (context, index) {
            final poi = _filteredPoi[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_getPoiTypeIcon(poi.type)),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(poi.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRatingColor(poi.rating).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            poi.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(poi.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          poi.city.substring(0, 1).toUpperCase() + poi.city.substring(1),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPoiTypeLabel(poi.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  // Azione quando si tocca un punto di interesse, es. mostra dettagli
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(poi.name),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  poi.city.substring(0, 1).toUpperCase() + poi.city.substring(1),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(_getPoiTypeIcon(poi.type), size: 16),
                                const SizedBox(width: 4),
                                Text(_getPoiTypeLabel(poi.type)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  poi.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(poi.description),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Chiudi'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}