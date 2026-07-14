import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/billing_estimate.dart';

class BillingEstimateResultsScreen extends StatefulWidget {
  final List<BillingEstimate> estimates;
  final String sessionId;
  final String terminal;

  const BillingEstimateResultsScreen({
    super.key,
    required this.estimates,
    required this.sessionId,
    required this.terminal,
  });

  @override
  State<BillingEstimateResultsScreen> createState() =>
      _BillingEstimateResultsScreenState();
}

class _BillingEstimateResultsScreenState
    extends State<BillingEstimateResultsScreen> {
  static const _brand = Color(0xFFFF6319);
  static final _currency = NumberFormat('#,##0.00');

  late List<BillingEstimate> _estimates;

  @override
  void initState() {
    super.initState();
    _estimates = List.of(widget.estimates);
  }

  double get _totalAmount =>
      _estimates.fold(0.0, (sum, e) => sum + (e.totalAmount ?? 0.0));

  void _deleteEstimate(int index) {
    setState(() => _estimates.removeAt(index));
  }

  void _deleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Estimates?'),
        content: const Text(
            'This will remove all estimates for this terminal.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _estimates.clear());
            },
            child: const Text('Delete All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLineItems(BillingEstimate estimate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _LineItemDrawer(estimate: estimate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: Text('Estimates — ${widget.terminal}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          if (_estimates.isNotEmpty)
            TextButton(
              onPressed: _deleteAll,
              child: const Text('Delete All',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: _estimates.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                _buildTotalBar(),
                Expanded(child: _buildList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.add),
        label: const Text('New Estimate'),
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('Total Amount',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A1919))),
          const Spacer(),
          Text(
            '₱ ${_currency.format(_totalAmount)}',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFFFF6319)),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _estimates.length,
      itemBuilder: (_, i) {
        final e = _estimates[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showLineItems(e),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryBadge(e.category),
                      const SizedBox(width: 8),
                      Text(
                        e.containerSplit,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                        onPressed: () => _deleteEstimate(i),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount (₱)',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        _currency.format(e.totalAmount ?? 0),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1919)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Container 20\' | 40\' | 45\'',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.expand_more,
                          size: 16, color: Colors.grey),
                      const Text('Details',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1565C0),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calculate_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No estimates yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _LineItemDrawer extends StatelessWidget {
  final BillingEstimate estimate;
  const _LineItemDrawer({required this.estimate});

  static final _currency = NumberFormat('#,##0.00');
  static final _dateFmt = DateFormat('MM/dd/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${estimate.category.toUpperCase()} — ${estimate.containerSplit}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1919)),
                ),
                Text(
                  '₱ ${_currency.format(estimate.totalAmount ?? 0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFFFF6319)),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...estimate.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.chargeItem,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF1A1919))),
                          item.dateValue != null
                              ? Text(
                                  _dateFmt.format(item.dateValue!),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              : Text(
                                  '₱ ${_currency.format(item.amount)}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1919)),
                                ),
                        ],
                      ),
                    )),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount (₱)',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1919))),
                      Text(
                        '₱ ${_currency.format(estimate.totalAmount ?? 0)}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6319)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
