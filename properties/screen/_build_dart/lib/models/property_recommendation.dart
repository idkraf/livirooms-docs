class PropertyRecommendation {
  final int? id;
  final int propertyId;
  final String type;
  final String? poiCategory;
  final int priority;

  const PropertyRecommendation({
    this.id,
    required this.propertyId,
    required this.type,
    this.poiCategory,
    required this.priority,
  });

  factory PropertyRecommendation.fromJson(Map<String, dynamic> json) =>
      PropertyRecommendation(
        id: json['id'] as int?,
        propertyId: json['property_id'] as int,
        type: json['type'] as String,
        poiCategory: json['poi_category'] as String?,
        priority: json['priority'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'type': type,
        'poi_category': poiCategory,
        'priority': priority,
      };
}
