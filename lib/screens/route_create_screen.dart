import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outdoor_navigation/services/api_service.dart';
import 'package:outdoor_navigation/services/storage_service.dart';
import 'package:outdoor_navigation/screens/route_detail_screen.dart';

class RouteCreateScreen extends StatefulWidget {
  final String? initialActivityType;
  
  const RouteCreateScreen({super.key, this.initialActivityType});

  @override
  State<RouteCreateScreen> createState() => _RouteCreateScreenState();
}

class _RouteCreateScreenState extends State<RouteCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _title = '';
  String? _description;
  String _activityType = 'trekking';
  String _startPoint = '';
  String _endPoint = '';
  int? _weight;
  
  bool _isLoading = false;
  String? _error;
  
  final List<String> _supportedCities = [
    'Bologna', 'Firenze', 'Genova', 'Milano', 'Napoli', 
    'Palermo', 'Roma', 'Torino', 'Trento', 'Venezia'
  ];
  
  @override
  void initState() {
    super.initState();
    
    if (widget.initialActivityType != null) {
      _activityType = widget.initialActivityType!;
    }
    
    // Carica le impostazioni utente per ottenere il peso
    _loadUserSettings();
  }
  
  Future<void> _loadUserSettings() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final settings = storageService.getUserSettings();
    
    if (settings.containsKey('weight')) {
      setState(() {
        _weight = settings['weight'] as int;
      });
    }
  }
  
  Future<void> _createRoute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      
      final route = await apiService.createRoute(
        title: _title,
        description: _description,
        activityType: _activityType,
        startPoint: _startPoint,
        endPoint: _endPoint,
        weight: _weight,
      );
      
      // Aggiungi il percorso ai recenti
      await storageService.addRecentRoute(route);
      
      if (mounted) {
        // Naviga alla schermata di dettaglio del percorso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailScreen(route: route),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      
      // Mostra l'errore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Percorso'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo del percorso
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Titolo del percorso',
                        hintText: 'Es. Weekend in montagna',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Il titolo è obbligatorio';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Descrizione (opzionale)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descrizione (opzionale)',
                        hintText: 'Descrivi il tuo percorso...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo di attività
                    Text(
                      'Tipo di attività',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'trekking',
                          label: Text('Trekking'),
                          icon: Icon(Icons.hiking),
                        ),
                        ButtonSegment(
                          value: 'cycling',
                          label: Text('Ciclismo'),
                          icon: Icon(Icons.directions_bike),
                        ),
                        ButtonSegment(
                          value: 'ebike',
                          label: Text('E-bike'),
                          icon: Icon(Icons.electric_bike),
                        ),
                        ButtonSegment(
                          value: 'running',
                          label: Text('Corsa'),
                          icon: Icon(Icons.directions_run),
                        ),
                      ],
                      selected: {_activityType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _activityType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Punto di partenza
                    Text(
                      'Punto di partenza',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _supportedCities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _startPoint = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleziona il punto di partenza';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Punto di arrivo
                    Text(
                      'Punto di arrivo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _supportedCities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _endPoint = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleziona il punto di arrivo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Peso (solo per calcolo calorie)
                    Text(
                      'Peso (per calcolo calorie)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        hintText: 'Es. 70',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _weight != null ? _weight.toString() : '',
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _weight = int.parse(value);
                        }
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final weight = int.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return 'Inserisci un peso valido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Pulsante di creazione
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createRoute,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Crea Percorso'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}