class PointsOfInterestInfo {
  final List<PointOfInterest> availablePoi;
  final int totalCount;
  final String message;

  PointsOfInterestInfo({
    required this.availablePoi,
    required this.totalCount,
    required this.message,
  });

  factory PointsOfInterestInfo.fromJson(Map<String, dynamic> json) {
    return PointsOfInterestInfo(
      availablePoi: (json['available_poi'] as List)
          .map((e) => PointOfInterest.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_poi': availablePoi.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'message': message,
    };
  }
}

class PointOfInterest {
  final String city;
  final String name;
  final String type;
  final String description;
  final double rating;

  PointOfInterest({
    required this.city,
    required this.name,
    required this.type,
    required this.description,
    required this.rating,
  });

  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      city: json['city'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      rating: json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : json['rating'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'name': name,
      'type': type,
      'description': description,
      'rating': rating,
    };
  }
}