/// Voyage model representing vessel voyage information from Supabase
class Voyage {
  // Core Identification
  final String id;
  final String voyageNumber;
  final String vesselId;
  
  // Voyage Details
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final String? departurePort;
  final String? arrivalPort;
  
  // Status
  final String status; // Scheduled, In Progress, Completed, Delayed, Cancelled
  
  // Additional Information
  final String? notes;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Voyage({
    required this.id,
    required this.voyageNumber,
    required this.vesselId,
    this.departureDate,
    this.arrivalDate,
    this.departurePort,
    this.arrivalPort,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Voyage from Supabase JSON
  factory Voyage.fromJson(Map<String, dynamic> json) {
    return Voyage(
      id: json['id'] as String,
      voyageNumber: json['voyage_number'] as String,
      vesselId: json['vessel_id'] as String,
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'] as String)
          : null,
      arrivalDate: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'] as String)
          : null,
      departurePort: json['departure_port'] as String?,
      arrivalPort: json['arrival_port'] as String?,
      status: json['status'] as String? ?? 'Scheduled',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Voyage to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voyage_number': voyageNumber,
      'vessel_id': vesselId,
      'departure_date': departureDate?.toIso8601String(),
      'arrival_date': arrivalDate?.toIso8601String(),
      'departure_port': departurePort,
      'arrival_port': arrivalPort,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of this Voyage with updated fields
  Voyage copyWith({
    String? id,
    String? voyageNumber,
    String? vesselId,
    DateTime? departureDate,
    DateTime? arrivalDate,
    String? departurePort,
    String? arrivalPort,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Voyage(
      id: id ?? this.id,
      voyageNumber: voyageNumber ?? this.voyageNumber,
      vesselId: vesselId ?? this.vesselId,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departurePort: departurePort ?? this.departurePort,
      arrivalPort: arrivalPort ?? this.arrivalPort,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate voyage duration in days
  int? get durationInDays {
    if (departureDate != null && arrivalDate != null) {
      return arrivalDate!.difference(departureDate!).inDays;
    }
    return null;
  }

  /// Check if voyage is currently active
  bool get isActive {
    if (status == 'In Progress') return true;
    if (departureDate == null || arrivalDate == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(departureDate!) && now.isBefore(arrivalDate!);
  }

  /// Get progress percentage (0-100)
  double? get progressPercentage {
    if (departureDate == null || arrivalDate == null) return null;
    
    final now = DateTime.now();
    if (now.isBefore(departureDate!)) return 0.0;
    if (now.isAfter(arrivalDate!)) return 100.0;
    
    final totalDuration = arrivalDate!.difference(departureDate!).inMilliseconds;
    final elapsed = now.difference(departureDate!).inMilliseconds;
    
    return (elapsed / totalDuration * 100).clamp(0.0, 100.0);
  }
}
