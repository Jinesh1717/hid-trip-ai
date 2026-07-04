class SpotImage {
  final int id;
  final String imageUrl;

  SpotImage({required this.id, required this.imageUrl});

  factory SpotImage.fromJson(Map<String, dynamic> json) {
    return SpotImage(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
    );
  }
}

class Spot {
  final int id;
  final String name;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final String? openingHours;
  final String? entryFee;
  final bool parkingAvailable;
  final String? bestTimeToVisit;
  final List<SpotImage> images;

  Spot({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.tags,
    this.openingHours,
    this.entryFee,
    this.parkingAvailable = false,
    this.bestTimeToVisit,
    this.images = const [],
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      tags: (json['tags'] as String?)?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [],
      openingHours: json['opening_hours'] as String?,
      entryFee: json['entry_fee'] as String?,
      parkingAvailable: json['parking_available'] as bool? ?? false,
      bestTimeToVisit: json['best_time_to_visit'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => SpotImage.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags.join(', '),
      'opening_hours': openingHours,
      'entry_fee': entryFee,
      'parking_available': parkingAvailable,
      'best_time_to_visit': bestTimeToVisit,
      // Images usually aren't sent back this way, but just in case
    };
  }
}
