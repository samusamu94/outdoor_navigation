import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outdoor_navigation/services/api_service.dart';
import 'package:outdoor_navigation/models/route_model.dart';
import 'package:outdoor_navigation/widgets/route_card.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  List<RouteModel> _routes = [];
  bool _isLoading = true;
  String? _error;
  String _filterActivity = 'all';

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final routes = await apiService.getRoutes();
      
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore durante il caricamento dei percorsi: $e';
        _isLoading = false;
      });
    }
  }

  List<RouteModel> get _filteredRoutes {
    if (_filterActivity == 'all') {
      return _routes;
    }
    return _routes.where((route) => route.activityType == _filterActivity).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei percorsi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro per attività
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tutti', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Trekking', 'trekking'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ciclismo', 'cycling'),
                  const SizedBox(width: 8),
                  _buildFilterChip('E-Bike', 'ebike'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Corsa', 'running'),
                ],
              ),
            ),
          ),

          // Lista percorsi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRoutes,
                              child: const Text('Riprova'),
                            ),
                          ],
                        ),
                      )
                    : _filteredRoutes.isEmpty
                        ? const Center(
                            child: Text('Nessun percorso trovato'),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRoutes,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _filteredRoutes.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: RouteCard(
                                    route: _filteredRoutes[index],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterActivity == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      onSelected: (selected) {
        setState(() {
          _filterActivity = value;
        });
      },
    );
  }
}