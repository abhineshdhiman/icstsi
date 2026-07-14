import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/vessel.dart';
import '../models/port.dart';
import '../services/booking_service.dart';
import '../services/vessel_service.dart';
import '../services/port_service.dart';

/// CreateBookingScreen provides a form to create a new booking
/// with vessel selection, port selection, status, and date inputs
class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final VesselService _vesselService = VesselService();
  final PortService _portService = PortService();

  // Form fields
  final TextEditingController _bookingReferenceController =
      TextEditingController();
  String _selectedStatus = 'pending';
  DateTime _bookingDate = DateTime.now();
  DateTime? _dischargeDate;
  DateTime? _gateOutDate;
  Vessel? _selectedVessel;
  Port? _selectedPort;

  // Data lists
  List<Vessel> _vessels = [];
  List<Port> _ports = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final List<String> _statusOptions = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    // Generate a default booking reference
    _bookingReferenceController.text = 'BKG-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _bookingReferenceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final vessels = await _vesselService.getVessels();
      final ports = await _portService.getAllPorts();

      setState(() {
        _vessels = vessels;
        _ports = ports;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: field == 'booking'
          ? _bookingDate
          : field == 'discharge'
              ? _dischargeDate ?? DateTime.now()
              : _gateOutDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6319),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (field == 'booking') {
          _bookingDate = picked;
        } else if (field == 'discharge') {
          _dischargeDate = picked;
        } else if (field == 'gateOut') {
          _gateOutDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVessel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vessel'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPort == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a port'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final booking = Booking(
        id: const Uuid().v4(),
        bookingReference: _bookingReferenceController.text,
        status: _selectedStatus,
        bookingDate: _bookingDate,
        dischargeDate: _dischargeDate,
        gateOutDate: _gateOutDate,
        vesselId: _selectedVessel!.id,
        portId: _selectedPort!.id,
      );

      await _bookingService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        backgroundColor: const Color(0xFFFF6319),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6319),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Booking Reference
                    TextFormField(
                      controller: _bookingReferenceController,
                      decoration: InputDecoration(
                        labelText: 'Booking Reference *',
                        prefixIcon: const Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6319),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a booking reference';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status *',
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6319),
                            width: 2,
                          ),
                        ),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Vessel Selection
                    DropdownButtonFormField<Vessel>(
                      value: _selectedVessel,
                      decoration: InputDecoration(
                        labelText: 'Vessel *',
                        prefixIcon: const Icon(Icons.directions_boat),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6319),
                            width: 2,
                          ),
                        ),
                      ),
                      hint: const Text('Select a vessel'),
                      items: _vessels.map((vessel) {
                        return DropdownMenuItem(
                          value: vessel,
                          child: Text(vessel.vesselName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVessel = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a vessel';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Port Selection
                    DropdownButtonFormField<Port>(
                      value: _selectedPort,
                      decoration: InputDecoration(
                        labelText: 'Port *',
                        prefixIcon: const Icon(Icons.anchor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6319),
                            width: 2,
                          ),
                        ),
                      ),
                      hint: const Text('Select a port'),
                      items: _ports.map((port) {
                        return DropdownMenuItem(
                          value: port,
                          child: Text('${port.portName} (${port.portCode})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPort = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a port';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Dates Section Header
                    const Text(
                      'Important Dates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6319),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Booking Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFFF6319),
                      ),
                      title: const Text('Booking Date *'),
                      subtitle: Text(
                        '${_bookingDate.day}/${_bookingDate.month}/${_bookingDate.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _selectDate(context, 'booking'),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: const Color(0xFF1A1919).withOpacity(0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Discharge Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Color(0xFFFF6319),
                      ),
                      title: const Text('Discharge Date (Optional)'),
                      subtitle: Text(
                        _dischargeDate != null
                            ? '${_dischargeDate!.day}/${_dischargeDate!.month}/${_dischargeDate!.year}'
                            : 'Not set',
                        style: TextStyle(
                          fontWeight: _dischargeDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: _dischargeDate != null
                              ? const Color(0xFF1A1919)
                              : const Color(0xFF1A1919).withOpacity(0.5),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _dischargeDate != null ? Icons.edit : Icons.add,
                        ),
                        onPressed: () => _selectDate(context, 'discharge'),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: const Color(0xFF1A1919).withOpacity(0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Gate Out Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.exit_to_app,
                        color: Color(0xFFFF6319),
                      ),
                      title: const Text('Gate Out Date (Optional)'),
                      subtitle: Text(
                        _gateOutDate != null
                            ? '${_gateOutDate!.day}/${_gateOutDate!.month}/${_gateOutDate!.year}'
                            : 'Not set',
                        style: TextStyle(
                          fontWeight: _gateOutDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: _gateOutDate != null
                              ? const Color(0xFF1A1919)
                              : const Color(0xFF1A1919).withOpacity(0.5),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _gateOutDate != null ? Icons.edit : Icons.add,
                        ),
                        onPressed: () => _selectDate(context, 'gateOut'),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: const Color(0xFF1A1919).withOpacity(0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6319),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor:
                            const Color(0xFFFF6319).withOpacity(0.5),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
