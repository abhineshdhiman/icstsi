import 'package:flutter/material.dart';
import '../widgets/container_list.dart';

/// ContainersScreen displays the container inventory with filtering options
class ContainersScreen extends StatefulWidget {
  const ContainersScreen({super.key});

  @override
  State<ContainersScreen> createState() => _ContainersScreenState();
}

class _ContainersScreenState extends State<ContainersScreen> {
  String? _selectedStatus;
  final List<String> _statusOptions = [
    'All',
    'available',
    'in_use',
    'maintenance',
    'damaged',
    'reserved',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Containers',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1919),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE0E0E0),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ContainerList(
              filterStatus: _selectedStatus == 'All' ? null : _selectedStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusOptions.map((status) {
            final isSelected = _selectedStatus == status ||
                (_selectedStatus == null && status == 'All');
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getStatusLabel(status)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = status == 'All' ? null : status;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFFF6319).withOpacity(0.1),
                checkmarkColor: const Color(0xFFFF6319),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFFF6319) : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF6319) : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'All':
        return 'All';
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
