class BillingEstimateItem {
  final String chargeItem;
  final double amount;
  final DateTime? dateValue;

  const BillingEstimateItem({
    required this.chargeItem,
    required this.amount,
    this.dateValue,
  });

  factory BillingEstimateItem.fromJson(Map<String, dynamic> json) {
    return BillingEstimateItem(
      chargeItem: json['charge_item'] as String,
      amount: (json['amount'] as num).toDouble(),
      dateValue: json['date_value'] != null
          ? DateTime.parse(json['date_value'] as String)
          : null,
    );
  }
}

class BillingEstimate {
  final String? id;
  final String? sessionId;
  final String terminal;
  final String category;
  final int qty20;
  final int qty40;
  final int qty45;
  final bool weighing;
  final bool outOfGauge;
  final bool reefer;
  final bool dea;
  final String? dgClass;
  final double? wCm;
  final double? hCm;
  final double? lCm;
  final DateTime? dischargeDate;
  final DateTime? gateOutDate;
  final DateTime? plugInDate;
  final DateTime? plugOutDate;
  final double? totalAmount;
  final List<BillingEstimateItem> items;

  const BillingEstimate({
    this.id,
    this.sessionId,
    required this.terminal,
    required this.category,
    this.qty20 = 0,
    this.qty40 = 0,
    this.qty45 = 0,
    this.weighing = false,
    this.outOfGauge = false,
    this.reefer = false,
    this.dea = false,
    this.dgClass,
    this.wCm,
    this.hCm,
    this.lCm,
    this.dischargeDate,
    this.gateOutDate,
    this.plugInDate,
    this.plugOutDate,
    this.totalAmount,
    this.items = const [],
  });

  factory BillingEstimate.fromJson(Map<String, dynamic> json) {
    final rawItems = json['billing_estimate_items'] as List<dynamic>? ?? [];
    return BillingEstimate(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String?,
      terminal: json['terminal'] as String,
      category: json['category'] as String,
      qty20: (json['qty_20'] as int?) ?? 0,
      qty40: (json['qty_40'] as int?) ?? 0,
      qty45: (json['qty_45'] as int?) ?? 0,
      weighing: (json['weighing'] as bool?) ?? false,
      outOfGauge: (json['out_of_gauge'] as bool?) ?? false,
      reefer: (json['reefer'] as bool?) ?? false,
      dea: (json['dea'] as bool?) ?? false,
      dgClass: json['dg_class'] as String?,
      wCm: (json['w_cm'] as num?)?.toDouble(),
      hCm: (json['h_cm'] as num?)?.toDouble(),
      lCm: (json['l_cm'] as num?)?.toDouble(),
      dischargeDate: json['discharge_date'] != null
          ? DateTime.parse(json['discharge_date'] as String)
          : null,
      gateOutDate: json['gate_out_date'] != null
          ? DateTime.parse(json['gate_out_date'] as String)
          : null,
      plugInDate: json['plug_in_date'] != null
          ? DateTime.parse(json['plug_in_date'] as String)
          : null,
      plugOutDate: json['plug_out_date'] != null
          ? DateTime.parse(json['plug_out_date'] as String)
          : null,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      items: rawItems
          .map((e) => BillingEstimateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (sessionId != null) 'session_id': sessionId,
        'terminal': terminal,
        'category': category,
        'qty_20': qty20,
        'qty_40': qty40,
        'qty_45': qty45,
        'weighing': weighing,
        'out_of_gauge': outOfGauge,
        'reefer': reefer,
        'dea': dea,
        if (dgClass != null) 'dg_class': dgClass,
        if (wCm != null) 'w_cm': wCm,
        if (hCm != null) 'h_cm': hCm,
        if (lCm != null) 'l_cm': lCm,
        if (dischargeDate != null) 'discharge_date': dischargeDate!.toIso8601String(),
        if (gateOutDate != null) 'gate_out_date': gateOutDate!.toIso8601String(),
        if (plugInDate != null) 'plug_in_date': plugInDate!.toIso8601String(),
        if (plugOutDate != null) 'plug_out_date': plugOutDate!.toIso8601String(),
        if (totalAmount != null) 'total_amount': totalAmount,
      };

  String get containerSplit => '${qty20.toString().padLeft(2, '0')} | '
      '${qty40.toString().padLeft(2, '0')} | '
      '${qty45.toString().padLeft(2, '0')}';
}
