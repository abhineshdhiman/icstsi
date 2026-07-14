import 'package:flutter/material.dart';
import '../models/voyage.dart';
import '../services/voyage_service.dart';
import '../widgets/voyage_timeline.dart';

/// Screen to display and manage voyages with timeline visualization
class VoyagesScreen extends StatefulWidget {
  const VoyagesScreen({super.key});

  @override
  State<VoyagesScreen> createState() => _VoyagesScreenState();
}

class _VoyagesScreenState extends State<VoyagesScreen> {
  final VoyageService _voyageService = VoyageService();
  List<Voyage> _voyages = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadVoyages();
  }

  Future<void> _loadVoyages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Voyage> voyages;
      
      switch (_filterStatus) {
        case 'Active':
          voyages = await _voyageService.getActiveVoyages();
          break;
        case 'Upcoming':
          voyages = await _voyageService.getUpcomingVoyages();
          break;
        default:
          voyages = await _voyageService.getVoyages();
      }

      setState(() {
        _voyages = voyages;
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
        title: const Text('Voyages'),
        backgroundColor: const Color(0xFFFF6319),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVoyages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Content
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add voyage screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add voyage feature coming soon')),
          );
        },
        backgroundColor: const Color(0xFFFF6319),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Upcoming'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filterStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterStatus = filter;
                });
                _loadVoyages();
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFFF6319).withOpacity(0.1),
              checkmarkColor: const Color(0xFFFF6319),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFFF6319) : const Color(0xFF666666),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFFFF6319) : const Color(0xFFE0E0E0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6319)),
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
              color: Color(0xFFFF6319),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading voyages',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1919),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadVoyages,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6319),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_voyages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sailing,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No voyages found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStatus == 'All' 
                  ? 'Add your first voyage to get started'
                  : 'No $_filterStatus voyages at the moment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVoyages,
      color: const Color(0xFFFF6319),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _voyages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final voyage = _voyages[index];
          return VoyageTimeline(
            voyage: voyage,
            showProgress: true,
            onTap: () => _showVoyageDetails(voyage),
          );
        },
      ),
    );
  }

  void _showVoyageDetails(Voyage voyage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voyage Details',
                    style: const TextStyle(
                      fontSize: 20,
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
            ),
            
            const Divider(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VoyageTimeline(
                      voyage: voyage,
                      showProgress: true,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildDetailRow('Voyage Number', voyage.voyageNumber),
                    _buildDetailRow('Vessel ID', voyage.vesselId),
                    _buildDetailRow('Status', voyage.status),
                    
                    if (voyage.durationInDays != null)
                      _buildDetailRow('Duration', '${voyage.durationInDays} days'),
                    
                    if (voyage.progressPercentage != null)
                      _buildDetailRow('Progress', '${voyage.progressPercentage!.toStringAsFixed(1)}%'),
                    
                    if (voyage.notes != null && voyage.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        voyage.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1919),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
