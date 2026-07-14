/// Vessel model representing comprehensive vessel information from Supabase
class Vessel {
  // Core Identification
  final String id;
  final String vesselName;
  final String imoNumber;
  final String? mmsi;
  final String? callSign;
  final String? officialNumber;
  
  // Classification & Registration
  final String flagState;
  final String? portOfRegistry;
  final String vesselType;
  final String? classificationSociety;
  final String? status; // Active, Inactive, Under Maintenance, Decommissioned
  
  // Physical Specifications
  final double? lengthOverall; // meters
  final double? beam; // meters
  final double? draft; // meters
  final double? grossTonnage; // GT
  final double? netTonnage; // NT
  final double? deadweightTonnage; // DWT
  final int? teuCapacity; // Twenty-foot Equivalent Unit
  
  // Build Information
  final int? buildYear;
  final String? builder;
  final String? buildCountry;
  
  // Operational Details
  final String? owner;
  final String? operator;
  final String? manager;
  final String? engineType;
  final double? serviceSpeed; // knots
  final double? maxSpeed; // knots
  final String? fuelType;
  final double? fuelCapacity; // metric tons
  
  // Additional Information
  final String? hullNumber;
  final String? previousNames;
  final String? notes;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vessel({
    required this.id,
    required this.vesselName,
    required this.imoNumber,
    this.mmsi,
    this.callSign,
    this.officialNumber,
    required this.flagState,
    this.portOfRegistry,
    required this.vesselType,
    this.classificationSociety,
    this.status,
    this.lengthOverall,
    this.beam,
    this.draft,
    this.grossTonnage,
    this.netTonnage,
    this.deadweightTonnage,
    this.teuCapacity,
    this.buildYear,
    this.builder,
    this.buildCountry,
    this.owner,
    this.operator,
    this.manager,
    this.engineType,
    this.serviceSpeed,
    this.maxSpeed,
    this.fuelType,
    this.fuelCapacity,
    this.hullNumber,
    this.previousNames,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Vessel from Supabase JSON
  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
      id: json['id'] as String,
      vesselName: json['vessel_name'] as String,
      imoNumber: json['imo_number'] as String,
      mmsi: json['mmsi'] as String?,
      callSign: json['call_sign'] as String?,
      officialNumber: json['official_number'] as String?,
      flagState: json['flag_state'] as String,
      portOfRegistry: json['port_of_registry'] as String?,
      vesselType: json['vessel_type'] as String,
      classificationSociety: json['classification_society'] as String?,
      status: json['status'] as String?,
      lengthOverall: json['length_overall'] != null 
          ? (json['length_overall'] as num).toDouble() 
          : null,
      beam: json['beam'] != null 
          ? (json['beam'] as num).toDouble() 
          : null,
      draft: json['draft'] != null 
          ? (json['draft'] as num).toDouble() 
          : null,
      grossTonnage: json['gross_tonnage'] != null 
          ? (json['gross_tonnage'] as num).toDouble() 
          : null,
      netTonnage: json['net_tonnage'] != null 
          ? (json['net_tonnage'] as num).toDouble() 
          : null,
      deadweightTonnage: json['deadweight_tonnage'] != null 
          ? (json['deadweight_tonnage'] as num).toDouble() 
          : null,
      teuCapacity: json['teu_capacity'] as int?,
      buildYear: json['build_year'] as int?,
      builder: json['builder'] as String?,
      buildCountry: json['build_country'] as String?,
      owner: json['owner'] as String?,
      operator: json['operator'] as String?,
      manager: json['manager'] as String?,
      engineType: json['engine_type'] as String?,
      serviceSpeed: json['service_speed'] != null 
          ? (json['service_speed'] as num).toDouble() 
          : null,
      maxSpeed: json['max_speed'] != null 
          ? (json['max_speed'] as num).toDouble() 
          : null,
      fuelType: json['fuel_type'] as String?,
      fuelCapacity: json['fuel_capacity'] != null 
          ? (json['fuel_capacity'] as num).toDouble() 
          : null,
      hullNumber: json['hull_number'] as String?,
      previousNames: json['previous_names'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Vessel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vessel_name': vesselName,
      'imo_number': imoNumber,
      'mmsi': mmsi,
      'call_sign': callSign,
      'official_number': officialNumber,
      'flag_state': flagState,
      'port_of_registry': portOfRegistry,
      'vessel_type': vesselType,
      'classification_society': classificationSociety,
      'status': status,
      'length_overall': lengthOverall,
      'beam': beam,
      'draft': draft,
      'gross_tonnage': grossTonnage,
      'net_tonnage': netTonnage,
      'deadweight_tonnage': deadweightTonnage,
      'teu_capacity': teuCapacity,
      'build_year': buildYear,
      'builder': builder,
      'build_country': buildCountry,
      'owner': owner,
      'operator': operator,
      'manager': manager,
      'engine_type': engineType,
      'service_speed': serviceSpeed,
      'max_speed': maxSpeed,
      'fuel_type': fuelType,
      'fuel_capacity': fuelCapacity,
      'hull_number': hullNumber,
      'previous_names': previousNames,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of this Vessel with updated fields
  Vessel copyWith({
    String? id,
    String? vesselName,
    String? imoNumber,
    String? mmsi,
    String? callSign,
    String? officialNumber,
    String? flagState,
    String? portOfRegistry,
    String? vesselType,
    String? classificationSociety,
    String? status,
    double? lengthOverall,
    double? beam,
    double? draft,
    double? grossTonnage,
    double? netTonnage,
    double? deadweightTonnage,
    int? teuCapacity,
    int? buildYear,
    String? builder,
    String? buildCountry,
    String? owner,
    String? operator,
    String? manager,
    String? engineType,
    double? serviceSpeed,
    double? maxSpeed,
    String? fuelType,
    double? fuelCapacity,
    String? hullNumber,
    String? previousNames,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vessel(
      id: id ?? this.id,
      vesselName: vesselName ?? this.vesselName,
      imoNumber: imoNumber ?? this.imoNumber,
      mmsi: mmsi ?? this.mmsi,
      callSign: callSign ?? this.callSign,
      officialNumber: officialNumber ?? this.officialNumber,
      flagState: flagState ?? this.flagState,
      portOfRegistry: portOfRegistry ?? this.portOfRegistry,
      vesselType: vesselType ?? this.vesselType,
      classificationSociety: classificationSociety ?? this.classificationSociety,
      status: status ?? this.status,
      lengthOverall: lengthOverall ?? this.lengthOverall,
      beam: beam ?? this.beam,
      draft: draft ?? this.draft,
      grossTonnage: grossTonnage ?? this.grossTonnage,
      netTonnage: netTonnage ?? this.netTonnage,
      deadweightTonnage: deadweightTonnage ?? this.deadweightTonnage,
      teuCapacity: teuCapacity ?? this.teuCapacity,
      buildYear: buildYear ?? this.buildYear,
      builder: builder ?? this.builder,
      buildCountry: buildCountry ?? this.buildCountry,
      owner: owner ?? this.owner,
      operator: operator ?? this.operator,
      manager: manager ?? this.manager,
      engineType: engineType ?? this.engineType,
      serviceSpeed: serviceSpeed ?? this.serviceSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      fuelType: fuelType ?? this.fuelType,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      hullNumber: hullNumber ?? this.hullNumber,
      previousNames: previousNames ?? this.previousNames,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
