import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VesselScheduleFilter {
  final String? vesselName;
  final String? status;
  final String? terminal;
  final DateTime? fromDate;
  final DateTime? toDate;

  const VesselScheduleFilter({
    this.vesselName,
    this.status,
    this.terminal,
    this.fromDate,
    this.toDate,
  });

  VesselScheduleFilter copyWith({
    String? vesselName,
    String? status,
    String? terminal,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return VesselScheduleFilter(
      vesselName: vesselName ?? this.vesselName,
      status: status ?? this.status,
      terminal: terminal ?? this.terminal,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class VesselScheduleFilterScreen extends StatefulWidget {
  final VesselScheduleFilter current;
  const VesselScheduleFilterScreen({super.key, required this.current});

  @override
  State<VesselScheduleFilterScreen> createState() =>
      _VesselScheduleFilterScreenState();
}

class _VesselScheduleFilterScreenState
    extends State<VesselScheduleFilterScreen> {
  static const _brand = Color(0xFFFF6319);
  static final _fmt = DateFormat('MM/dd/yyyy');

  late TextEditingController _vesselCtrl;
  String? _status;
  String? _terminal;
  DateTime? _fromDate;
  DateTime? _toDate;

  static const _statuses = [
    ('at_pilot_station', 'At Pilot Station'),
    ('active_at_berth', 'Active at Berth'),
    ('scheduled', 'Scheduled Visits'),
    ('departed', 'Departed'),
  ];

  static const _terminals = ['MICT', 'AGCT', 'MICTSI'];

  @override
  void initState() {
    super.initState();
    _vesselCtrl =
        TextEditingController(text: widget.current.vesselName ?? '');
    _status = widget.current.status;
    _terminal = widget.current.terminal;
    _fromDate = widget.current.fromDate;
    _toDate = widget.current.toDate;
  }

  @override
  void dispose() {
    _vesselCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: _brand, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _submit() {
    Navigator.pop(
      context,
      VesselScheduleFilter(
        vesselName:
            _vesselCtrl.text.isEmpty ? null : _vesselCtrl.text,
        status: _status,
        terminal: _terminal,
        fromDate: _fromDate,
        toDate: _toDate,
      ),
    );
  }

  void _reset() {
    setState(() {
      _vesselCtrl.clear();
      _status = null;
      _terminal = null;
      _fromDate = null;
      _toDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: const Text('Filter',
            style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Search Vessel Name'),
            _buildTextField(
              controller: _vesselCtrl,
              hint: 'Enter vessel name',
              prefix: const Icon(Icons.search, size: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildLabel('Terminal'),
            _buildDropdown<String>(
              value: _terminal,
              hint: 'Select one Terminal',
              items: _terminals,
              itemLabel: (t) => '$t - Manila International Container Terminal',
              onChanged: (v) => setState(() => _terminal = v),
            ),
            const SizedBox(height: 20),
            _buildLabel('Status'),
            _buildDropdown<String>(
              value: _status,
              hint: 'All statuses',
              items: _statuses.map((e) => e.$1).toList(),
              itemLabel: (s) =>
                  _statuses.firstWhere((e) => e.$1 == s).$2,
              onChanged: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 20),
            _buildLabel('Date Range'),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: _fromDate != null ? _fmt.format(_fromDate!) : 'From Date',
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: _toDate != null ? _fmt.format(_toDate!) : 'To Date',
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: _brand),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('RESET',
                        style: TextStyle(
                            color: _brand, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('SUBMIT',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1919))),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _brand),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint, style: const TextStyle(color: Colors.grey)),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _brand),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(itemLabel(e),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
