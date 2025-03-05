import 'package:flutter/material.dart';
import 'package:outdoor_navigation/models/weather_model.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherForecast weatherForecast;

  const WeatherWidget({super.key, required this.weatherForecast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Raccomandazione generale per il percorso
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raccomandazione',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _getWeatherIcon(weatherForecast.season),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(weatherForecast.routeRecommendation),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text('Stagione: ${_getSeasonName(weatherForecast.season)}'),
                  backgroundColor: _getSeasonColor(weatherForecast.season),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Meteo città di partenza
        Text(
          'Meteo ${weatherForecast.startCity.city}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildCityWeatherCard(context, weatherForecast.startCity),
        
        const SizedBox(height: 24),
        
        // Meteo città di arrivo
        Text(
          'Meteo ${weatherForecast.endCity.city}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildCityWeatherCard(context, weatherForecast.endCity),
      ],
    );
  }
  
  Widget _buildCityWeatherCard(BuildContext context, CityWeather cityWeather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getWeatherProfileIcon(cityWeather.weatherProfile),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(cityWeather.condition),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Profilo: ${_capitalize(cityWeather.weatherProfile)}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherInfoItem(
                  context: context,
                  icon: Icons.thermostat,
                  value: cityWeather.tempRange,
                  label: 'Temperatura',
                  iconColor: Colors.red,
                ),
                _weatherInfoItem(
                  context: context,
                  icon: Icons.water_drop,
                  value: '${cityWeather.rainProbability}%',
                  label: 'Pioggia',
                  iconColor: Colors.blue,
                ),
                _weatherInfoItem(
                  context: context,
                  icon: Icons.air,
                  value: _capitalize(cityWeather.wind),
                  label: 'Vento',
                  iconColor: Colors.blueGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _weatherInfoItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  // Helpers per le icone e i colori
  Icon _getWeatherProfileIcon(String profile) {
    switch (profile) {
      case 'sunny':
        return const Icon(Icons.wb_sunny, color: Colors.amber, size: 32);
      case 'mixed':
        return const Icon(Icons.wb_cloudy, color: Colors.grey, size: 32);
      case 'foggy':
        return const Icon(Icons.cloud, color: Colors.blueGrey, size: 32);
      case 'rainy':
        return const Icon(Icons.water_drop, color: Colors.blue, size: 32);
      case 'humid':
        return const Icon(Icons.water, color: Colors.lightBlue, size: 32);
      case 'alpine':
        return const Icon(Icons.landscape, color: Colors.green, size: 32);
      default:
        return const Icon(Icons.help_outline, size: 32);
    }
  }
  
  Icon _getWeatherIcon(String season) {
    switch (season) {
      case 'spring':
        return const Icon(Icons.local_florist, color: Colors.pink);
      case 'summer':
        return const Icon(Icons.wb_sunny, color: Colors.orange);
      case 'autumn':
        return const Icon(Icons.eco, color: Colors.amber);
      case 'winter':
        return const Icon(Icons.ac_unit, color: Colors.lightBlue);
      default:
        return const Icon(Icons.help_outline);
    }
  }
  
  Color _getSeasonColor(String season) {
    switch (season) {
      case 'spring':
        return Colors.pink.withValues(alpha: 0.2);
      case 'summer':
        return Colors.orange.withValues(alpha: 0.2);
      case 'autumn':
        return Colors.amber.withValues(alpha: 0.2);
      case 'winter':
        return Colors.lightBlue.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }
  
  String _getSeasonName(String season) {
    switch (season) {
      case 'spring':
        return 'Primavera';
      case 'summer':
        return 'Estate';
      case 'autumn':
        return 'Autunno';
      case 'winter':
        return 'Inverno';
      default:
        return season;
    }
  }
  
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}