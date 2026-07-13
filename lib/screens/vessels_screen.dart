import 'package:flutter/material.dart';
import '../models/vessel.dart';
import '../services/vessel_service.dart';
import '../widgets/vessel_card.dart';

/// Screen displaying a list of vessels using VesselCard components
class VesselsScreen extends StatefulWidget {
  const VesselsScreen({super.key});

  @override
  State<VesselsScreen> createState() => _VesselsScreenState();
}

class _VesselsScreenState extends State<VesselsScreen> {
  final VesselService _vesselService = VesselService();
  List<Vessel> _vessels = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVessels();
  }

  Future<void> _loadVessels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vessels = await _vesselService.getVessels();
      setState(() {
        _vessels = vessels;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vessels'),
        backgroundColor: const Color(0xFFFF6319),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadVessels,
        backgroundColor: const Color(0xFFFF6319),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading vessels',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVessels,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6319),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_vessels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_boat_outlined,
              size: 64,
              color: Color(0xFF1A1919),
            ),
            const SizedBox(height: 16),
            Text(
              'No vessels found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add vessels to your Supabase database to see them here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVessels,
      color: const Color(0xFFFF6319),
      child: ListView.builder(
        itemCount: _vessels.length,
        itemBuilder: (context, index) {
          final vessel = _vessels[index];
          return VesselCard(
            vessel: vessel,
            onTap: () {
              // Navigate to vessel details or show details dialog
              _showVesselDetails(vessel);
            },
          );
        },
      ),
    );
  }

  void _showVesselDetails(Vessel vessel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vessel.vesselName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('IMO Number', vessel.imoNumber),
            const SizedBox(height: 8),
            _buildDetailRow('Flag State', vessel.flagState),
            const SizedBox(height: 8),
            _buildDetailRow('Vessel Type', vessel.vesselType),
            if (vessel.createdAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Created',
                '${vessel.createdAt!.day}/${vessel.createdAt!.month}/${vessel.createdAt!.year}',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFFFF6319)),
            ),
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
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1919),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF1A1919)),
          ),
        ),
      ],
    );
  }
}
