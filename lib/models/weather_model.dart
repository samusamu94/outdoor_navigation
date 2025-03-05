class WeatherForecast {
  final CityWeather startCity;
  final CityWeather endCity;
  final String season;
  final String routeRecommendation;

  WeatherForecast({
    required this.startCity,
    required this.endCity,
    required this.season,
    required this.routeRecommendation,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      startCity: CityWeather.fromJson(json['start_city'] as Map<String, dynamic>),
      endCity: CityWeather.fromJson(json['end_city'] as Map<String, dynamic>),
      season: json['season'] as String,
      routeRecommendation: json['route_recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_city': startCity.toJson(),
      'end_city': endCity.toJson(),
      'season': season,
      'route_recommendation': routeRecommendation,
    };
  }
}

class CityWeather {
  final String city;
  final String weatherProfile;
  final String condition;
  final String tempRange;
  final int rainProbability;
  final String wind;

  CityWeather({
    required this.city,
    required this.weatherProfile,
    required this.condition,
    required this.tempRange,
    required this.rainProbability,
    required this.wind,
  });

  factory CityWeather.fromJson(Map<String, dynamic> json) {
    return CityWeather(
      city: json['city'] as String,
      weatherProfile: json['weather_profile'] as String,
      condition: json['condition'] as String,
      tempRange: json['temp_range'] as String,
      rainProbability: json['rain_probability'] as int,
      wind: json['wind'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'weather_profile': weatherProfile,
      'condition': condition,
      'temp_range': tempRange,
      'rain_probability': rainProbability,
      'wind': wind,
    };
  }
}