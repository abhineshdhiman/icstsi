import 'package:flutter/material.dart';
import '../models/port.dart';
import '../services/port_service.dart';

/// PortSelector widget - A dropdown/modal component for selecting ports
/// Matches ICSTSI design system with #FF6319 primary color and #1A1919 text
class PortSelector extends StatefulWidget {
  final Port? selectedPort;
  final Function(Port?) onPortSelected;
  final String? label;
  final bool isRequired;
  final String? hintText;
  final bool showModal;

  const PortSelector({
    super.key,
    this.selectedPort,
    required this.onPortSelected,
    this.label,
    this.isRequired = false,
    this.hintText,
    this.showModal = false,
  });

  @override
  State<PortSelector> createState() => _PortSelectorState();
}

class _PortSelectorState extends State<PortSelector> {
  final PortService _portService = PortService();
  List<Port> _ports = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPorts();
  }

  Future<void> _loadPorts() async {
    setState(() => _isLoading = true);
    try {
      final ports = await _portService.getAllPorts();
      setState(() {
        _ports = ports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load ports: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchPorts(String query) async {
    if (query.isEmpty) {
      _loadPorts();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ports = await _portService.searchPorts(query);
      setState(() {
        _ports = ports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showPortModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(),
    );
  }

  Widget _buildModalContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Modal header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6319),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Port',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, code, or country...',
                hintStyle: const TextStyle(color: Color(0xFF999999)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6319)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFF6319), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _searchPorts(value);
              },
            ),
          ),
          // Port list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6319),
                    ),
                  )
                : _ports.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No ports available'
                              : 'No ports found for "$_searchQuery"',
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _ports.length,
                        itemBuilder: (context, index) {
                          final port = _ports[index];
                          final isSelected = widget.selectedPort?.id == port.id;
                          return ListTile(
                            title: Text(
                              port.portName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: const Color(0xFF1A1919),
                              ),
                            ),
                            subtitle: Text(
                              '${port.portCode} • ${port.location}, ${port.country}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFFFF6319),
                                  )
                                : null,
                            onTap: () {
                              widget.onPortSelected(port);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showModal) {
      // Modal trigger button
      return InkWell(
        onTap: _showPortModal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.selectedPort?.displayName ??
                      widget.hintText ??
                      'Select a port',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.selectedPort != null
                        ? const Color(0xFF1A1919)
                        : const Color(0xFF999999),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF1A1919),
              ),
            ],
          ),
        ),
      );
    }

    // Standard dropdown
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF1A1919),
                ),
                children: [
                  if (widget.isRequired)
                    const TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Color(0xFFFF6319),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF6319),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Port>(
                    value: widget.selectedPort,
                    hint: Text(
                      widget.hintText ?? 'Select a port',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF1A1919),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1919),
                    ),
                    items: _ports.map((Port port) {
                      return DropdownMenuItem<Port>(
                        value: port,
                        child: Text(
                          port.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (Port? newPort) {
                      widget.onPortSelected(newPort);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
