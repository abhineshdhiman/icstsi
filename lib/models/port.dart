/// Port model representing port information from Supabase
class Port {
  final String id;
  final String portCode;
  final String portName;
  final String location;
  final String country;
  final DateTime? createdAt;

  Port({
    required this.id,
    required this.portCode,
    required this.portName,
    required this.location,
    required this.country,
    this.createdAt,
  });

  /// Create a Port from Supabase JSON
  factory Port.fromJson(Map<String, dynamic> json) {
    return Port(
      id: json['id'] as String,
      portCode: json['port_code'] as String,
      portName: json['port_name'] as String,
      location: json['location'] as String,
      country: json['country'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert Port to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'port_code': portCode,
      'port_name': portName,
      'location': location,
      'country': country,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Display string for the port (used in dropdowns)
  String get displayName => '$portName ($portCode) - $country';

  @override
  String toString() => displayName;
}
