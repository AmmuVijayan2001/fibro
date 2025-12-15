import 'dart:convert';

class PathPoint {
  final double latitude;
  final double longitude;
  final String description;

  PathPoint({
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory PathPoint.fromJson(Map<String, dynamic> json) => PathPoint(
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    description: json['description'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
  };
}

class RouteData {
  final int? id;
  final String? name;
  final List<PathPoint>? path;
  final double? lengthKm;
  final DateTime? createdAt;
  final int? office;
  final int? createdBy;
  final double? totalkm;
  RouteData({
    this.id,
    this.name,
    this.path,
    this.lengthKm,
    this.createdAt,
    this.office,
    this.createdBy,
    this.totalkm,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    final pathJson = json['path'];
    List<PathPoint> pathPoints = [];

    if (pathJson is String) {
      try {
        final decoded = jsonDecode(pathJson);
        if (decoded is List) {
          pathPoints =
              decoded
                  .whereType<Map<String, dynamic>>()
                  .map(PathPoint.fromJson)
                  .toList();
        }
      } catch (e) {
        print('Failed to decode path JSON: $e');
      }
    } else if (pathJson is List) {
      pathPoints =
          pathJson
              .whereType<Map<String, dynamic>>()
              .map(PathPoint.fromJson)
              .toList();
    }

    return RouteData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      path: pathPoints,
      lengthKm: double.tryParse(json['length_km'].toString()),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      office: json['office'] as int?,
      createdBy: json['created_by'] as int?,
      totalkm: json["total_km"] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path?.map((p) => p.toJson()).toList() ?? [],
      'length_km': lengthKm,
      'office': office,
    };
  }
}
