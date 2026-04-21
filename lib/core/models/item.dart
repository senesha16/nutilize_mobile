/// Item model matching the 'items' table in Supabase
class Item {
  final int itemId;
  final int ownerId;
  final String itemName;
  final String category;
  final bool maintenanceStatus;
  final bool availabilityStatus;
  final DateTime? dateReserved;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Item({
    required this.itemId,
    required this.ownerId,
    required this.itemName,
    required this.category,
    required this.maintenanceStatus,
    required this.availabilityStatus,
    this.dateReserved,
    required this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final categoryData = json['item_categories'] as Map<String, dynamic>?;
    final displayName = categoryData?['display_name']?.toString();
    final categoryKey = categoryData?['category_key']?.toString();

    return Item(
      itemId: json['item_id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      category: displayName ?? (categoryKey ?? 'Uncategorized'),
      maintenanceStatus: json['maintenance_status'] ?? false,
      availabilityStatus: json['availability_status'] ?? true,
      dateReserved: json['date_reserved'] != null
          ? DateTime.parse(json['date_reserved'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'owner_id': ownerId,
      'item_name': itemName,
      'category': category,
      'maintenance_status': maintenanceStatus,
      'availability_status': availabilityStatus,
      'date_reserved': dateReserved?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Item copyWith({
    int? itemId,
    int? ownerId,
    String? itemName,
    String? category,
    bool? maintenanceStatus,
    bool? availabilityStatus,
    DateTime? dateReserved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      ownerId: ownerId ?? this.ownerId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      dateReserved: dateReserved ?? this.dateReserved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
