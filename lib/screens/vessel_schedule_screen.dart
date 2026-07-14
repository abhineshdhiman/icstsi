import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vessel_schedule.dart';
import '../services/vessel_schedule_service.dart';
import 'vessel_schedule_filter_screen.dart';

class VesselScheduleScreen extends StatefulWidget {
  const VesselScheduleScreen({super.key});

  @override
  State<VesselScheduleScreen> createState() => _VesselScheduleScreenState();
}

class _VesselScheduleScreenState extends State<VesselScheduleScreen> {
  static const _brand = Color(0xFFFF6319);
  final _service = VesselScheduleService();

  List<VesselSchedule> _schedules = [];
  bool _loading = true;
  String? _error;
  String _selectedTerminal = 'All';
  VesselScheduleFilter _filter = const VesselScheduleFilter();

  static const _terminals = ['All', 'MICT', 'AGCT', 'MICTSI'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await _service.getVesselSchedules(
        terminal: _selectedTerminal == 'All' ? null : _selectedTerminal,
        status: _filter.status,
        vesselName: _filter.vesselName,
        fromDate: _filter.fromDate,
        toDate: _filter.toDate,
      );
      setState(() { _schedules = results; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<VesselScheduleFilter>(
      context,
      MaterialPageRoute(
        builder: (_) => VesselScheduleFilterScreen(current: _filter),
      ),
    );
    if (result != null) {
      _filter = result;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: const Text('Vessel Schedule',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter',
            onPressed: _openFilter,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTerminalTabs(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTerminalTabs() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _terminals.length,
        itemBuilder: (_, i) {
          final t = _terminals[i];
          final selected = t == _selectedTerminal;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTerminal = t);
                _load();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? _brand : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _brand));
    }
    if (_error != null) {
      return _buildError();
    }
    if (_schedules.isEmpty) {
      return _buildEmpty();
    }
    return RefreshIndicator(
      color: _brand,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _schedules.length,
        itemBuilder: (_, i) => _VesselScheduleCard(vessel: _schedules[i]),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Failed to load vessel schedule'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_boat_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No vessels found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _VesselScheduleCard extends StatefulWidget {
  final VesselSchedule vessel;
  const _VesselScheduleCard({required this.vessel});

  @override
  State<_VesselScheduleCard> createState() => _VesselScheduleCardState();
}

class _VesselScheduleCardState extends State<_VesselScheduleCard> {
  bool _expanded = false;
  static const _brand = Color(0xFFFF6319);
  static final _fmt = DateFormat('MM/dd/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final v = widget.vessel;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(v),
              const SizedBox(height: 8),
              _buildDateRow(v),
              if (_expanded) ...[
                const Divider(height: 20),
                _buildDetailPanel(v),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(VesselSchedule v) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _brand.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.directions_boat, color: _brand, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                v.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A1919),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (v.shippingLine != null)
                Text(v.shippingLine!,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(v.status),
      ],
    );
  }

  Widget _buildDateRow(VesselSchedule v) {
    final primaryDate = v.etaEtb ?? v.ataAtb ?? v.etd;
    final label = v.etaEtb != null
        ? 'ETA/ETB'
        : v.ataAtb != null
            ? 'ATA/ATB'
            : 'ETD';
    return Row(
      children: [
        _buildTerminalBadge(v.terminal),
        const Spacer(),
        if (primaryDate != null)
          Text(
            '$label: ${_fmt.format(primaryDate)}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        const SizedBox(width: 4),
        Icon(
          _expanded ? Icons.expand_less : Icons.expand_more,
          size: 18,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDetailPanel(VesselSchedule v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schedule Details',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF1A1919))),
        const SizedBox(height: 8),
        _buildDetailRow('ETA / ETB', v.etaEtb),
        _buildDetailRow('Initial Time of Berthing (LCT)', v.initialBerthingLct),
        _buildDetailRow('ATA / ATB', v.ataAtb),
        _buildDetailRow('Begin Receive', v.beginReceive),
        _buildDetailRow('Pre-Advice Cutoff', v.preAdviceCutoff),
        _buildDetailRow('Loading Cutoff', v.loadingCutoff),
        _buildDetailRow('ETD', v.etd),
        _buildDetailRow('ATD', v.atd),
        _buildDetailRow('ETC', v.etc),
        if (v.remarks != null && v.remarks!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Text('Remarks: ',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                Expanded(
                  child: Text(v.remarks!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF1A1919))),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, DateTime? dt) {
    if (dt == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          Expanded(
            child: Text(_fmt.format(dt),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1919))),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'at_pilot_station':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case 'active_at_berth':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'scheduled':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        break;
      case 'departed':
        bg = const Color(0xFFF3E5F5);
        fg = const Color(0xFF6A1B9A);
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        VesselSchedule(
                id: '', vesselName: '', terminal: '', status: status)
            .statusLabel,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTerminalBadge(String terminal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6319).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        terminal,
        style: const TextStyle(
          color: Color(0xFFFF6319),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
