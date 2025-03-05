import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outdoor_navigation/screens/route_list_screen.dart';
import 'package:outdoor_navigation/screens/route_create_screen.dart';
import 'package:outdoor_navigation/screens/map_screen.dart';
import 'package:outdoor_navigation/screens/profile_screen.dart';
import 'package:outdoor_navigation/services/auth_service.dart';
import 'package:outdoor_navigation/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeTab(),
    const RouteListScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Percorsi',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mappa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RouteCreateScreen()),
              );
            },
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }
  
  Future<void> _loadRoutes() async {
    Provider.of<StorageService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    // Carica i percorsi recenti e preferiti
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outdoor Navigation'),
        actions: [
          // Pulsante di logout con correzione per BuildContext attraverso gap asincroni
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Ottieni il navigator prima dell'operazione asincrona
              final navigator = Navigator.of(context);
              
              await authService.signOut();
              
              // Verifica che il widget sia ancora montato
              if (mounted) {
                navigator.pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRoutes,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenuto esistente...
                ],
              ),
            ),
      ),
    );
  }
}