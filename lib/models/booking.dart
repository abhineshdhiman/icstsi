import 'vessel.dart';
import 'port.dart';

/// Booking model representing booking information from Supabase
/// with references to Vessel and Port
class Booking {
  final String id;
  final String bookingReference;
  final String status;
  final DateTime bookingDate;
  final DateTime? dischargeDate;
  final DateTime? gateOutDate;
  final String vesselId;
  final String portId;
  final DateTime? createdAt;
  
  // Populated references
  final Vessel? vessel;
  final Port? port;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.status,
    required this.bookingDate,
    this.dischargeDate,
    this.gateOutDate,
    required this.vesselId,
    required this.portId,
    this.createdAt,
    this.vessel,
    this.port,
  });

  /// Create a Booking from Supabase JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      bookingReference: json['booking_reference'] as String,
      status: json['status'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      dischargeDate: json['discharge_date'] != null
          ? DateTime.parse(json['discharge_date'] as String)
          : null,
      gateOutDate: json['gate_out_date'] != null
          ? DateTime.parse(json['gate_out_date'] as String)
          : null,
      vesselId: json['vessel_id'] as String,
      portId: json['port_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      vessel: json['vessels'] != null
          ? Vessel.fromJson(json['vessels'] as Map<String, dynamic>)
          : null,
      port: json['ports'] != null
          ? Port.fromJson(json['ports'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert Booking to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'status': status,
      'booking_date': bookingDate.toIso8601String(),
      'discharge_date': dischargeDate?.toIso8601String(),
      'gate_out_date': gateOutDate?.toIso8601String(),
      'vessel_id': vesselId,
      'port_id': portId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get status color based on booking status
  int getStatusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 0xFF4CAF50; // Green
      case 'pending':
        return 0xFFFFA726; // Orange
      case 'cancelled':
        return 0xFFEF5350; // Red
      case 'completed':
        return 0xFF42A5F5; // Blue
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}
