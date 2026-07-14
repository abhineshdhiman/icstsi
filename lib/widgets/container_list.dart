import 'package:flutter/material.dart';
import '../models/container.dart' as models;
import '../services/container_service.dart';

/// ContainerList widget displays containers in a scrollable list with status indicators
class ContainerList extends StatefulWidget {
  final String? filterStatus;
  final String? filterBookingId;

  const ContainerList({
    super.key,
    this.filterStatus,
    this.filterBookingId,
  });

  @override
  State<ContainerList> createState() => _ContainerListState();
}

class _ContainerListState extends State<ContainerList> {
  final ContainerService _containerService = ContainerService();
  List<models.Container> _containers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  @override
  void didUpdateWidget(ContainerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterStatus != widget.filterStatus ||
        oldWidget.filterBookingId != widget.filterBookingId) {
      _loadContainers();
    }
  }

  Future<void> _loadContainers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<models.Container> containers;
      
      if (widget.filterBookingId != null) {
        containers = await _containerService.getContainersByBooking(widget.filterBookingId!);
      } else if (widget.filterStatus != null) {
        containers = await _containerService.getContainersByStatus(widget.filterStatus!);
      } else {
        containers = await _containerService.getContainers();
      }

      setState(() {
        _containers = containers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6319),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading containers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContainers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6319),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_containers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No containers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContainers,
      color: const Color(0xFFFF6319),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _containers.length,
        itemBuilder: (context, index) {
          final container = _containers[index];
          return _buildContainerCard(container);
        },
      ),
    );
  }

  Widget _buildContainerCard(models.Container container) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showContainerDetails(container),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        container.containerNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1919),
                        ),
                      ),
                    ),
                    _buildStatusBadge(container),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.category_outlined, 'Type', container.type),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.straighten_outlined, 'Size', container.size),
                if (container.booking != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.receipt_long_outlined,
                    'Booking',
                    container.booking!.bookingReference,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(models.Container container) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(container.getStatusColor()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        container.getStatusLabel(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(container.getStatusColor()),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1919),
            ),
          ),
        ),
      ],
    );
  }

  void _showContainerDetails(models.Container container) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Container Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1919),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildDetailRow('Container Number', container.containerNumber),
                _buildDetailRow('Type', container.type),
                _buildDetailRow('Size', container.size),
                _buildDetailRow('Status', container.getStatusLabel()),
                if (container.booking != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1919),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Booking Reference', container.booking!.bookingReference),
                  _buildDetailRow('Booking Status', container.booking!.status),
                  if (container.booking!.vessel != null)
                    _buildDetailRow('Vessel', container.booking!.vessel!.vesselName),
                  if (container.booking!.port != null)
                    _buildDetailRow('Port', container.booking!.port!.portName),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1919),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
