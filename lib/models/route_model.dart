import 'package:outdoor_navigation/models/poi_model.dart';
import 'package:outdoor_navigation/models/weather_model.dart';

class RouteModel {
  final String id;
  final String title;
  final String? description;
  final String activityType;
  final String startPoint;
  final String endPoint;
  final double distance;
  final int elevationGain;
  final int estimatedDuration;
  final String difficulty;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? batteryConsumption;
  final String shareCode;
  final String estimatedDurationFormatted;
  final String elevationInfo;
  final DifficultyInfo difficultyInfo;
  final CaloriesInfo? caloriesInfo;
  final WeatherForecast? weatherForecast;
  final PointsOfInterestInfo? pointsOfInterest;
  final OptimizedStops? optimizedStops;
  final SharingInfo sharing;
  final BatteryInfo? batteryInfo;
  final ChargingStationsInfo? chargingStations;

  RouteModel({
    required this.id,
    required this.title,
    this.description,
    required this.activityType,
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.elevationGain,
    required this.estimatedDuration,
    required this.difficulty,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.batteryConsumption,
    required this.shareCode,
    required this.estimatedDurationFormatted,
    required this.elevationInfo,
    required this.difficultyInfo,
    this.caloriesInfo,
    this.weatherForecast,
    this.pointsOfInterest,
    this.optimizedStops,
    required this.sharing,
    this.batteryInfo,
    this.chargingStations,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      activityType: json['activity_type'] as String,
      startPoint: json['start_point'] as String,
      endPoint: json['end_point'] as String,
      distance: json['distance'] is int ? (json['distance'] as int).toDouble() : json['distance'] as double,
      elevationGain: json['elevation_gain'] as int,
      estimatedDuration: json['estimated_duration'] as int,
      difficulty: json['difficulty'] as String,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      batteryConsumption: json['battery_consumption'] as int?,
      shareCode: json['share_code'] as String,
      estimatedDurationFormatted: json['estimated_duration_formatted'] as String,
      elevationInfo: json['elevation_info'] as String,
      difficultyInfo: DifficultyInfo.fromJson(json['difficulty_info'] as Map<String, dynamic>),
      caloriesInfo: json['calories_info'] != null
          ? CaloriesInfo.fromJson(json['calories_info'] as Map<String, dynamic>)
          : null,
      weatherForecast: json['weather_forecast'] != null
          ? WeatherForecast.fromJson(json['weather_forecast'] as Map<String, dynamic>)
          : null,
      pointsOfInterest: json['points_of_interest'] != null
          ? PointsOfInterestInfo.fromJson(json['points_of_interest'] as Map<String, dynamic>)
          : null,
      optimizedStops: json['optimized_stops'] != null
          ? OptimizedStops.fromJson(json['optimized_stops'] as Map<String, dynamic>)
          : null,
      sharing: SharingInfo.fromJson(json['sharing'] as Map<String, dynamic>),
      batteryInfo: json['battery_info'] != null
          ? BatteryInfo.fromJson(json['battery_info'] as Map<String, dynamic>)
          : null,
      chargingStations: json['charging_stations'] != null
          ? ChargingStationsInfo.fromJson(json['charging_stations'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'activity_type': activityType,
      'start_point': startPoint,
      'end_point': endPoint,
      'distance': distance,
      'elevation_gain': elevationGain,
      'estimated_duration': estimatedDuration,
      'difficulty': difficulty,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'battery_consumption': batteryConsumption,
      'share_code': shareCode,
      'estimated_duration_formatted': estimatedDurationFormatted,
      'elevation_info': elevationInfo,
      'difficulty_info': difficultyInfo.toJson(),
      'calories_info': caloriesInfo?.toJson(),
      'weather_forecast': weatherForecast?.toJson(),
      'points_of_interest': pointsOfInterest?.toJson(),
      'optimized_stops': optimizedStops?.toJson(),
      'sharing': sharing.toJson(),
      'battery_info': batteryInfo?.toJson(),
      'charging_stations': chargingStations?.toJson(),
    };
  }
}

class DifficultyInfo {
  final String level;
  final String message;

  DifficultyInfo({
    required this.level,
    required this.message,
  });

  factory DifficultyInfo.fromJson(Map<String, dynamic> json) {
    return DifficultyInfo(
      level: json['level'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'message': message,
    };
  }
}

class CaloriesInfo {
  final int caloriesBurned;
  final String message;

  CaloriesInfo({
    required this.caloriesBurned,
    required this.message,
  });

  factory CaloriesInfo.fromJson(Map<String, dynamic> json) {
    return CaloriesInfo(
      caloriesBurned: json['calories_burned'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories_burned': caloriesBurned,
      'message': message,
    };
  }
}

class SharingInfo {
  final String shareCode;
  final String shareableLink;
  final String message;

  SharingInfo({
    required this.shareCode,
    required this.shareableLink,
    required this.message,
  });

  factory SharingInfo.fromJson(Map<String, dynamic> json) {
    return SharingInfo(
      shareCode: json['share_code'] as String,
      shareableLink: json['shareable_link'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'share_code': shareCode,
      'shareable_link': shareableLink,
      'message': message,
    };
  }
}

class BatteryInfo {
  final int consumptionWh;
  final int rechargesNeeded;
  final int estimatedRangePerCharge;
  final String message;

  BatteryInfo({
    required this.consumptionWh,
    required this.rechargesNeeded,
    required this.estimatedRangePerCharge,
    required this.message,
  });

  factory BatteryInfo.fromJson(Map<String, dynamic> json) {
    return BatteryInfo(
      consumptionWh: json['consumption_wh'] as int,
      rechargesNeeded: json['recharges_needed'] as int,
      estimatedRangePerCharge: json['estimated_range_per_charge'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumption_wh': consumptionWh,
      'recharges_needed': rechargesNeeded,
      'estimated_range_per_charge': estimatedRangePerCharge,
      'message': message,
    };
  }
}

class ChargingStationsInfo {
  final List<ChargingStation> availableStations;
  final String message;

  ChargingStationsInfo({
    required this.availableStations,
    required this.message,
  });

  factory ChargingStationsInfo.fromJson(Map<String, dynamic> json) {
    return ChargingStationsInfo(
      availableStations: (json['available_stations'] as List)
          .map((e) => ChargingStation.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_stations': availableStations.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class ChargingStation {
  final String city;
  final String name;
  final String address;
  final Coordinates coordinates;

  ChargingStation({
    required this.city,
    required this.name,
    required this.address,
    required this.coordinates,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      city: json['city'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      coordinates: Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'name': name,
      'address': address,
      'coordinates': coordinates.toJson(),
    };
  }
}

class Coordinates {
  final double lat;
  final double lon;

  Coordinates({
    required this.lat,
    required this.lon,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: json['lat'] is int ? (json['lat'] as int).toDouble() : json['lat'] as double,
      lon: json['lon'] is int ? (json['lon'] as int).toDouble() : json['lon'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}

class OptimizedStops {
  final int stopsNeeded;
  final String message;
  final List<SuggestedStop> suggestedStops;

  OptimizedStops({
    required this.stopsNeeded,
    required this.message,
    required this.suggestedStops,
  });

  factory OptimizedStops.fromJson(Map<String, dynamic> json) {
    return OptimizedStops(
      stopsNeeded: json['stops_needed'] as int,
      message: json['message'] as String,
      suggestedStops: (json['suggested_stops'] as List)
          .map((e) => SuggestedStop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stops_needed': stopsNeeded,
      'message': message,
      'suggested_stops': suggestedStops.map((e) => e.toJson()).toList(),
    };
  }
}

class SuggestedStop {
  final int stopNumber;
  final String city;
  final double distanceFromPrevious;
  final List<PointOfInterest> pointsOfInterest;
  final double? distanceToDestination;

  SuggestedStop({
    required this.stopNumber,
    required this.city,
    required this.distanceFromPrevious,
    required this.pointsOfInterest,
    this.distanceToDestination,
  });

  factory SuggestedStop.fromJson(Map<String, dynamic> json) {
    return SuggestedStop(
      stopNumber: json['stop_number'] as int,
      city: json['city'] as String,
      distanceFromPrevious: json['distance_from_previous'] is int
          ? (json['distance_from_previous'] as int).toDouble()
          : json['distance_from_previous'] as double,
      pointsOfInterest: (json['points_of_interest'] as List)
          .map((e) => PointOfInterest.fromJson(e as Map<String, dynamic>))
          .toList(),
      distanceToDestination: json['distance_to_destination'] != null
          ? (json['distance_to_destination'] is int
              ? (json['distance_to_destination'] as int).toDouble()
              : json['distance_to_destination'] as double)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stop_number': stopNumber,
      'city': city,
      'distance_from_previous': distanceFromPrevious,
      'points_of_interest': pointsOfInterest.map((e) => e.toJson()).toList(),
      'distance_to_destination': distanceToDestination,
    };
  }
}