import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

/// BookingCard displays booking information in a card layout
/// with booking reference, status, vessel and port details, and dates
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Booking reference and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Booking reference
                  Expanded(
                    child: Text(
                      booking.bookingReference,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1919),
                      ),
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(booking.getStatusColor()).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(booking.getStatusColor()),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Divider
              Container(
                height: 1,
                color: const Color(0xFF1A1919).withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              
              // Vessel information
              if (booking.vessel != null) ...[
                _buildSectionHeader('Vessel Details'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.directions_boat,
                  label: 'Vessel',
                  value: booking.vessel!.vesselName,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  icon: Icons.tag,
                  label: 'IMO',
                  value: booking.vessel!.imoNumber,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  icon: Icons.flag,
                  label: 'Flag',
                  value: booking.vessel!.flagState,
                ),
                const SizedBox(height: 12),
              ],
              
              // Port information
              if (booking.port != null) ...[
                _buildSectionHeader('Port Details'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.anchor,
                  label: 'Port',
                  value: booking.port!.portName,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: '${booking.port!.location}, ${booking.port!.country}',
                ),
                const SizedBox(height: 12),
              ],
              
              // Date information
              _buildSectionHeader('Important Dates'),
              const SizedBox(height: 8),
              _buildDateRow(
                icon: Icons.calendar_today,
                label: 'Booking Date',
                date: booking.bookingDate,
              ),
              if (booking.dischargeDate != null) ...[
                const SizedBox(height: 6),
                _buildDateRow(
                  icon: Icons.calendar_month,
                  label: 'Discharge Date',
                  date: booking.dischargeDate!,
                ),
              ],
              if (booking.gateOutDate != null) ...[
                const SizedBox(height: 6),
                _buildDateRow(
                  icon: Icons.exit_to_app,
                  label: 'Gate Out Date',
                  date: booking.gateOutDate!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFF6319),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF1A1919).withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1919).withOpacity(0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1919),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required DateTime date,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF1A1919).withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1919).withOpacity(0.6),
          ),
        ),
        Expanded(
          child: Text(
            '${dateFormat.format(date)} at ${timeFormat.format(date)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1919),
            ),
          ),
        ),
      ],
    );
  }
}
