import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/port.dart';

/// DashboardHeader displays port information, current date, and time
/// 
/// This is a pure layout component that:
/// - Shows the selected port name and code
/// - Displays current date with calendar icon
/// - Shows current time with clock icon
/// - Updates time every second
class DashboardHeader extends StatefulWidget {
  final Port? selectedPort;
  final VoidCallback? onPortTap;

  const DashboardHeader({
    super.key,
    this.selectedPort,
    this.onPortTap,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  late DateTime _currentTime;
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Create a stream that emits current time every second
    _timeStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Port Selection Section
          _buildPortSection(),
          const SizedBox(height: 16),
          // Date and Time Section
          Row(
            children: [
              Expanded(child: _buildDateSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildTimeSection()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortSection() {
    return InkWell(
      onTap: widget.onPortTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.anchor,
              color: Color(0xFFFF6319),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Port',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.selectedPort != null
                        ? '${widget.selectedPort!.portName} (${widget.selectedPort!.portCode})'
                        : 'Select Port',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1919),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.selectedPort != null)
                    Text(
                      widget.selectedPort!.country,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: widget.onPortTap != null
                  ? const Color(0xFF1A1919)
                  : const Color(0xFFBDBDBD),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dayFormat = DateFormat('EEEE');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6319),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(now),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1919),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dayFormat.format(now),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return StreamBuilder<DateTime>(
      stream: _timeStream,
      initialData: _currentTime,
      builder: (context, snapshot) {
        final time = snapshot.data ?? _currentTime;
        final timeFormat = DateFormat('HH:mm:ss');
        final timezoneFormat = DateFormat('z');

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6319),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeFormat.format(time),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1919),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timezoneFormat.format(time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
