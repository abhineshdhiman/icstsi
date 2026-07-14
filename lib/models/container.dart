import 'booking.dart';

/// Container model representing container inventory from Supabase
/// with reference to Booking
class Container {
  final String id;
  final String containerNumber;
  final String type;
  final String size;
  final String status;
  final String? bookingId;
  final DateTime? createdAt;
  
  // Populated reference
  final Booking? booking;

  Container({
    required this.id,
    required this.containerNumber,
    required this.type,
    required this.size,
    required this.status,
    this.bookingId,
    this.createdAt,
    this.booking,
  });

  /// Create a Container from Supabase JSON
  factory Container.fromJson(Map<String, dynamic> json) {
    return Container(
      id: json['id'] as String,
      containerNumber: json['container_number'] as String,
      type: json['type'] as String,
      size: json['size'] as String,
      status: json['status'] as String,
      bookingId: json['booking_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      booking: json['bookings'] != null
          ? Booking.fromJson(json['bookings'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert Container to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'container_number': containerNumber,
      'type': type,
      'size': size,
      'status': status,
      'booking_id': bookingId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get status color based on container status
  int getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return 0xFF4CAF50; // Green
      case 'in_use':
        return 0xFF2196F3; // Blue
      case 'maintenance':
        return 0xFFFFA726; // Orange
      case 'damaged':
        return 0xFFEF5350; // Red
      case 'reserved':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Get human-readable status label
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'in_use':
        return 'In Use';
      case 'maintenance':
        return 'Maintenance';
      case 'damaged':
        return 'Damaged';
      case 'reserved':
        return 'Reserved';
      default:
        return status;
    }
  }
}
