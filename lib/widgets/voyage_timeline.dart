import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voyage.dart';

/// VoyageTimeline widget to visualize voyage progress with calendar and clock icons
/// Based on Figma design specifications
class VoyageTimeline extends StatelessWidget {
  final Voyage voyage;
  final bool showProgress;
  final VoidCallback? onTap;

  const VoyageTimeline({
    super.key,
    required this.voyage,
    this.showProgress = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with voyage number and status
            _buildHeader(),
            const SizedBox(height: 16),
            
            // Timeline visualization
            _buildTimeline(),
            
            // Progress bar (if enabled and voyage has dates)
            if (showProgress && voyage.departureDate != null && voyage.arrivalDate != null)
              ...[
                const SizedBox(height: 16),
                _buildProgressBar(),
              ],
            
            // Additional info
            if (voyage.notes != null && voyage.notes!.isNotEmpty)
              ...[
                const SizedBox(height: 12),
                _buildNotes(),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            voyage.voyageNumber,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1919),
            ),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    
    switch (voyage.status.toLowerCase()) {
      case 'in progress':
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
        textColor = const Color(0xFF4CAF50);
        break;
      case 'completed':
        backgroundColor = const Color(0xFF2196F3).withOpacity(0.1);
        textColor = const Color(0xFF2196F3);
        break;
      case 'delayed':
        backgroundColor = const Color(0xFFFF9800).withOpacity(0.1);
        textColor = const Color(0xFFFF9800);
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFF44336).withOpacity(0.1);
        textColor = const Color(0xFFF44336);
        break;
      default: // Scheduled
        backgroundColor = const Color(0xFF9E9E9E).withOpacity(0.1);
        textColor = const Color(0xFF9E9E9E);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        voyage.status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Row(
      children: [
        // Departure
        Expanded(
          child: _buildTimelinePoint(
            icon: Icons.calendar_today,
            label: 'Departure',
            date: voyage.departureDate,
            port: voyage.departurePort,
            isStart: true,
          ),
        ),
        
        // Connection line
        Expanded(
          child: _buildConnectionLine(),
        ),
        
        // Arrival
        Expanded(
          child: _buildTimelinePoint(
            icon: Icons.calendar_today,
            label: 'Arrival',
            date: voyage.arrivalDate,
            port: voyage.arrivalPort,
            isStart: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelinePoint({
    required IconData icon,
    required String label,
    required DateTime? date,
    required String? port,
    required bool isStart,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Column(
      crossAxisAlignment: isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6319).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFFF6319),
          ),
        ),
        const SizedBox(height: 8),
        
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1919),
          ),
        ),
        const SizedBox(height: 4),
        
        // Date
        if (date != null) ...[
          Text(
            dateFormat.format(date),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1919),
            ),
          ),
          const SizedBox(height: 2),
          
          // Time with clock icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: const Color(0xFF666666),
              ),
              const SizedBox(width: 4),
              Text(
                timeFormat.format(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            'Not set',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        // Port
        if (port != null && port.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            port,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionLine() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6319),
                const Color(0xFFFF6319).withOpacity(0.3),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (voyage.durationInDays != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${voyage.durationInDays} days',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = voyage.progressPercentage ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1919),
              ),
            ),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6319),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6319)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFF666666),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              voyage.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
