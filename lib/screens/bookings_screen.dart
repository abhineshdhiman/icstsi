import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../widgets/booking_card.dart';
import 'create_booking_screen.dart';

/// BookingsScreen displays a list of all bookings
/// with pull-to-refresh and navigation to create new bookings
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingService.getBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateBooking() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBookingScreen(),
      ),
    );

    // Reload bookings if a new booking was created
    if (result == true) {
      _loadBookings();
    }
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking.bookingReference),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', booking.status.toUpperCase()),
              const SizedBox(height: 8),
              _buildDetailRow('Booking Date', 
                '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}'),
              if (booking.dischargeDate != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Discharge Date',
                  '${booking.dischargeDate!.day}/${booking.dischargeDate!.month}/${booking.dischargeDate!.year}'),
              ],
              if (booking.gateOutDate != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Gate Out Date',
                  '${booking.gateOutDate!.day}/${booking.gateOutDate!.month}/${booking.gateOutDate!.year}'),
              ],
              if (booking.vessel != null) ...[
                const Divider(height: 24),
                const Text(
                  'Vessel Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6319),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Name', booking.vessel!.vesselName),
                const SizedBox(height: 8),
                _buildDetailRow('IMO', booking.vessel!.imoNumber),
                const SizedBox(height: 8),
                _buildDetailRow('Flag', booking.vessel!.flagState),
                const SizedBox(height: 8),
                _buildDetailRow('Type', booking.vessel!.vesselType),
              ],
              if (booking.port != null) ...[
                const Divider(height: 24),
                const Text(
                  'Port Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF6319),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Name', booking.port!.portName),
                const SizedBox(height: 8),
                _buildDetailRow('Code', booking.port!.portCode),
                const SizedBox(height: 8),
                _buildDetailRow('Location', booking.port!.location),
                const SizedBox(height: 8),
                _buildDetailRow('Country', booking.port!.country),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1919).withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1919),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: const Color(0xFFFF6319),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6319),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading bookings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1A1919),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadBookings,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6319),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.book_online,
                            size: 64,
                            color: Color(0xFFFF6319),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No bookings found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1919),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first booking to get started',
                            style: TextStyle(
                              color: Color(0xFF1A1919),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _navigateToCreateBooking,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Booking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6319),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookings,
                      color: const Color(0xFFFF6319),
                      child: ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return BookingCard(
                            booking: booking,
                            onTap: () => _showBookingDetails(booking),
                          );
                        },
                      ),
                    ),
      floatingActionButton: _bookings.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateBooking,
              backgroundColor: const Color(0xFFFF6319),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Booking'),
            )
          : null,
    );
  }
}
