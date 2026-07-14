import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/billing_estimate.dart';
import '../services/billing_estimate_service.dart';
import 'billing_estimate_results_screen.dart';

class BillingEstimateScreen extends StatefulWidget {
  const BillingEstimateScreen({super.key});

  @override
  State<BillingEstimateScreen> createState() => _BillingEstimateScreenState();
}

class _BillingEstimateScreenState extends State<BillingEstimateScreen> {
  static const _brand = Color(0xFFFF6319);
  static final _dateFmt = DateFormat('MM/dd/yyyy');
  static final _timeFmt = DateFormat('HH:mm');

  final _service = BillingEstimateService();

  String _category = 'Import';
  String _terminal = 'MICT';
  String? _dgClass;
  int _qty20 = 0, _qty40 = 0, _qty45 = 0;
  bool _weighing = false, _outOfGauge = false, _reefer = false, _dea = false;
  DateTime? _dischargeDate, _gateOutDate, _dischargeTime, _gateOutTime;
  DateTime? _plugInDate, _plugInTime, _plugOutDate, _plugOutTime;
  double? _wCm, _hCm, _lCm;

  bool _loading = false;
  String? _sessionId;

  static const _categories = ['Import', 'Export'];
  static const _terminals = ['MICT', 'AGCT', 'MICTSI'];
  static const _dgClasses = ['Not Applicable', 'Class 1', 'Class 2', 'Class 3'];

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sessionId = prefs.getString('billing_session_id') ??
          const Uuid().v4().also((id) {
            prefs.setString('billing_session_id', id);
          });
    });
  }

  Future<void> _pickDate(bool isDischarge) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        if (isDischarge) _dischargeDate = picked;
        else _gateOutDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isDischarge) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: _brand, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final dt = DateTime(2000, 1, 1, picked.hour, picked.minute);
      setState(() {
        if (isDischarge) _dischargeTime = dt;
        else _gateOutTime = dt;
      });
    }
  }

  Future<void> _pickReeferDate(bool isPlugIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isPlugIn) _plugInDate = picked;
        else _plugOutDate = picked;
      });
    }
  }

  Future<void> _pickReeferTime(bool isPlugIn) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final dt = DateTime(2000, 1, 1, picked.hour, picked.minute);
      setState(() {
        if (isPlugIn) _plugInTime = dt;
        else _plugOutTime = dt;
      });
    }
  }

  bool get _hasContainers => _qty20 > 0 || _qty40 > 0 || _qty45 > 0;

  void _addToEstimate() {
    if (!_hasContainers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one container.')),
      );
      return;
    }

    setState(() => _loading = true);

    final input = BillingEstimate(
      sessionId: _sessionId,
      terminal: _terminal,
      category: _category,
      qty20: _qty20,
      qty40: _qty40,
      qty45: _qty45,
      weighing: _weighing,
      outOfGauge: _outOfGauge,
      reefer: _reefer,
      dea: _dea,
      dgClass: _dgClass,
      dischargeDate: _dischargeDate,
      gateOutDate: _gateOutDate,
      plugInDate: _plugInDate,
      plugOutDate: _plugOutDate,
    );

    final result = _service.calculateLocally(input);
    setState(() => _loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillingEstimateResultsScreen(
          estimates: [result],
          sessionId: _sessionId ?? '',
          terminal: _terminal,
        ),
      ),
    );
  }

  void _clear() {
    setState(() {
      _qty20 = _qty40 = _qty45 = 0;
      _weighing = _outOfGauge = _reefer = _dea = false;
      _dischargeDate = _gateOutDate = _dischargeTime = _gateOutTime = null;
      _plugInDate = _plugInTime = _plugOutDate = _plugOutTime = null;
      _dgClass = null;
      _wCm = _hCm = _lCm = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: const Text('Billing Estimates',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReminderBanner(),
                const SizedBox(height: 16),
                _buildCard('Container Details', _buildContainerDetails()),
                const SizedBox(height: 12),
                _buildCard('Options', _buildOptions()),
                const SizedBox(height: 12),
                _buildCard('Cargo & Terminal', _buildCargoTerminal()),
                if (_reefer) ...[
                  const SizedBox(height: 12),
                  _buildCard('Reefer Details', _buildReeferSection()),
                ],
                if (_outOfGauge) ...[
                  const SizedBox(height: 12),
                  _buildCard('Out-of-Gauge Dimensions', _buildOOGSection()),
                ],
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildReminderBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6319).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: _brand, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Reminder: Date/time are per the specific terminal time zone. '
              'All amounts shown are exclusive of tax.',
              style: TextStyle(fontSize: 12, color: Color(0xFF7B4F00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1919))),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildContainerDetails() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDatePicker('Discharge Date*', _dischargeDate, () => _pickDate(true))),
            const SizedBox(width: 12),
            Expanded(child: _buildDatePicker('Gate Out Date*', _gateOutDate, () => _pickDate(false))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTimePicker('Discharge Time*', _dischargeTime, () => _pickTime(true))),
            const SizedBox(width: 12),
            Expanded(child: _buildTimePicker('Gate Out Time*', _gateOutTime, () => _pickTime(false))),
          ],
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Container Quantity',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStepper("20'", _qty20, (v) => setState(() => _qty20 = v))),
            const SizedBox(width: 8),
            Expanded(child: _buildStepper("40'", _qty40, (v) => setState(() => _qty40 = v))),
            const SizedBox(width: 8),
            Expanded(child: _buildStepper("45'", _qty45, (v) => setState(() => _qty45 = v))),
          ],
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: [
        _buildToggle('Weighing', _weighing, (v) => setState(() => _weighing = v)),
        _buildToggle('Out-of-Gauge', _outOfGauge, (v) => setState(() => _outOfGauge = v)),
        _buildToggle('Reefer', _reefer, (v) => setState(() => _reefer = v)),
        _buildToggle('DEA', _dea, (v) => setState(() => _dea = v)),
      ],
    );
  }

  Widget _buildCargoTerminal() {
    return Column(
      children: [
        _buildDropdownField<String>(
          label: 'Category*',
          value: _category,
          items: _categories,
          itemLabel: (c) => c,
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: 12),
        _buildDropdownField<String>(
          label: 'Terminal*',
          value: _terminal,
          items: _terminals,
          itemLabel: (t) => '$t - Manila International Container Terminal',
          onChanged: (v) => setState(() => _terminal = v ?? _terminal),
        ),
        const SizedBox(height: 12),
        _buildDropdownField<String>(
          label: 'DG Class',
          value: _dgClass,
          items: _dgClasses,
          itemLabel: (d) => d,
          onChanged: (v) => setState(() => _dgClass = v),
        ),
      ],
    );
  }

  Widget _buildReeferSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDatePicker('Plug-Out Date*', _plugOutDate, () => _pickReeferDate(false))),
            const SizedBox(width: 12),
            Expanded(child: _buildTimePicker('Plug-Out Time*', _plugOutTime, () => _pickReeferTime(false))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDatePicker('Plug-In Date*', _plugInDate, () => _pickReeferDate(true))),
            const SizedBox(width: 12),
            Expanded(child: _buildTimePicker('Plug-In Time*', _plugInTime, () => _pickReeferTime(true))),
          ],
        ),
      ],
    );
  }

  Widget _buildOOGSection() {
    return Row(
      children: [
        Expanded(child: _buildNumberField('W (cm)', (v) => _wCm = v)),
        const SizedBox(width: 8),
        Expanded(child: _buildNumberField('H (cm)', (v) => _hCm = v)),
        const SizedBox(width: 8),
        Expanded(child: _buildNumberField('L (cm)', (v) => _lCm = v)),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value != null ? _dateFmt.format(value) : '—',
                    style: TextStyle(
                        fontSize: 13,
                        color: value != null
                            ? const Color(0xFF1A1919)
                            : Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, DateTime? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value != null ? _timeFmt.format(value) : '—',
                    style: TextStyle(
                        fontSize: 13,
                        color: value != null
                            ? const Color(0xFF1A1919)
                            : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(String label, int value, void Function(int) onChanged) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1919))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: value > 0
                    ? () => onChanged(value - 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => onChanged(value + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(
      String label, bool value, void Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1919))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _brand,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _brand),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, void Function(double?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (v) =>
              onChanged(double.tryParse(v)),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _brand),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('CLEAR',
                    style: TextStyle(
                        color: _brand, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _loading ? null : _addToEstimate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('ADD TO ESTIMATE',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _Also<T> on T {
  T also(void Function(T) block) {
    block(this);
    return this;
  }
}
