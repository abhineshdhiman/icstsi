/// Vessel model representing vessel information from Supabase
class Vessel {
  final String id;
  final String vesselName;
  final String imoNumber;
  final String flagState;
  final String vesselType;
  final DateTime? createdAt;

  Vessel({
    required this.id,
    required this.vesselName,
    required this.imoNumber,
    required this.flagState,
    required this.vesselType,
    this.createdAt,
  });

  /// Create a Vessel from Supabase JSON
  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
      id: json['id'] as String,
      vesselName: json['vessel_name'] as String,
      imoNumber: json['imo_number'] as String,
      flagState: json['flag_state'] as String,
      vesselType: json['vessel_type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Vessel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vessel_name': vesselName,
      'imo_number': imoNumber,
      'flag_state': flagState,
      'vessel_type': vesselType,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
