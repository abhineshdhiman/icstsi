import 'package:flutter/material.dart';
import '../models/port.dart';
import '../widgets/port_selector.dart';

/// Demo screen showcasing the PortSelector widget
class PortsScreen extends StatefulWidget {
  const PortsScreen({super.key});

  @override
  State<PortsScreen> createState() => _PortsScreenState();
}

class _PortsScreenState extends State<PortsScreen> {
  Port? _selectedDropdownPort;
  Port? _selectedModalPort;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Port Selection'),
        backgroundColor: const Color(0xFFFF6319),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Port Selector Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select ports using dropdown or modal interface',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 32),

            // Dropdown variant
            const Text(
              'Dropdown Selector',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1919),
              ),
            ),
            const SizedBox(height: 16),
            PortSelector(
              label: 'Departure Port',
              isRequired: true,
              hintText: 'Select departure port',
              selectedPort: _selectedDropdownPort,
              onPortSelected: (port) {
                setState(() => _selectedDropdownPort = port);
              },
            ),
            const SizedBox(height: 16),
            if (_selectedDropdownPort != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Port Details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1919),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Port Name', _selectedDropdownPort!.portName),
                    _buildDetailRow('Port Code', _selectedDropdownPort!.portCode),
                    _buildDetailRow('Location', _selectedDropdownPort!.location),
                    _buildDetailRow('Country', _selectedDropdownPort!.country),
                  ],
                ),
              ),

            const SizedBox(height: 48),

            // Modal variant
            const Text(
              'Modal Selector',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1919),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Opens a searchable modal with better UX for large port lists',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arrival Port*',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1919),
                  ),
                ),
                const SizedBox(height: 8),
                PortSelector(
                  showModal: true,
                  hintText: 'Select arrival port',
                  selectedPort: _selectedModalPort,
                  onPortSelected: (port) {
                    setState(() => _selectedModalPort = port);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedModalPort != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Port Details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1919),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Port Name', _selectedModalPort!.portName),
                    _buildDetailRow('Port Code', _selectedModalPort!.portCode),
                    _buildDetailRow('Location', _selectedModalPort!.location),
                    _buildDetailRow('Country', _selectedModalPort!.country),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Clear button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDropdownPort = null;
                    _selectedModalPort = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6319),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Clear Selections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1919),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
