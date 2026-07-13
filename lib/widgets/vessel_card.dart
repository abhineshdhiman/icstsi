import 'package:flutter/material.dart';
import '../models/vessel.dart';

/// VesselCard displays vessel information in a card layout
/// with vessel icon and key details (name, IMO, flag state, type)
class VesselCard extends StatelessWidget {
  final Vessel vessel;
  final VoidCallback? onTap;

  const VesselCard({
    super.key,
    required this.vessel,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vessel icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6319).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_boat,
                  size: 32,
                  color: Color(0xFFFF6319),
                ),
              ),
              const SizedBox(width: 16),
              // Vessel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vessel name
                    Text(
                      vessel.vesselName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1919),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // IMO Number
                    _buildInfoRow(
                      icon: Icons.tag,
                      label: 'IMO',
                      value: vessel.imoNumber,
                    ),
                    const SizedBox(height: 4),
                    // Flag State
                    _buildInfoRow(
                      icon: Icons.flag,
                      label: 'Flag',
                      value: vessel.flagState,
                    ),
                    const SizedBox(height: 4),
                    // Vessel Type
                    _buildInfoRow(
                      icon: Icons.category,
                      label: 'Type',
                      value: vessel.vesselType,
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF1A1919),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF1A1919).withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF1A1919).withOpacity(0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1919),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
