class VesselSchedule {
  final String id;
  final String vesselName;
  final String? voyage;
  final String? shippingLine;
  final String terminal;
  final String status;
  final DateTime? etaEtb;
  final DateTime? ataAtb;
  final DateTime? etd;
  final DateTime? atd;
  final DateTime? etc;
  final DateTime? initialBerthingLct;
  final DateTime? beginReceive;
  final DateTime? preAdviceCutoff;
  final DateTime? loadingCutoff;
  final String? remarks;

  const VesselSchedule({
    required this.id,
    required this.vesselName,
    this.voyage,
    this.shippingLine,
    required this.terminal,
    required this.status,
    this.etaEtb,
    this.ataAtb,
    this.etd,
    this.atd,
    this.etc,
    this.initialBerthingLct,
    this.beginReceive,
    this.preAdviceCutoff,
    this.loadingCutoff,
    this.remarks,
  });

  factory VesselSchedule.fromJson(Map<String, dynamic> json) {
    return VesselSchedule(
      id: json['id'] as String,
      vesselName: json['vessel_name'] as String,
      voyage: json['voyage'] as String?,
      shippingLine: json['shipping_line'] as String?,
      terminal: json['terminal'] as String,
      status: json['status'] as String? ?? 'scheduled',
      etaEtb: json['eta_etb'] != null ? DateTime.parse(json['eta_etb'] as String) : null,
      ataAtb: json['ata_atb'] != null ? DateTime.parse(json['ata_atb'] as String) : null,
      etd: json['etd'] != null ? DateTime.parse(json['etd'] as String) : null,
      atd: json['atd'] != null ? DateTime.parse(json['atd'] as String) : null,
      etc: json['etc'] != null ? DateTime.parse(json['etc'] as String) : null,
      initialBerthingLct: json['initial_berthing_lct'] != null
          ? DateTime.parse(json['initial_berthing_lct'] as String)
          : null,
      beginReceive: json['begin_receive'] != null
          ? DateTime.parse(json['begin_receive'] as String)
          : null,
      preAdviceCutoff: json['pre_advice_cutoff'] != null
          ? DateTime.parse(json['pre_advice_cutoff'] as String)
          : null,
      loadingCutoff: json['loading_cutoff'] != null
          ? DateTime.parse(json['loading_cutoff'] as String)
          : null,
      remarks: json['remarks'] as String?,
    );
  }

  String get displayName =>
      voyage != null ? '$vesselName ($voyage)' : vesselName;

  // 'at_pilot_station' | 'active_at_berth' | 'scheduled' | 'departed'
  String get statusLabel {
    switch (status) {
      case 'at_pilot_station': return 'At Pilot Station';
      case 'active_at_berth':  return 'Active at Berth';
      case 'scheduled':        return 'Scheduled Visits';
      case 'departed':         return 'Departed';
      default:                 return status;
    }
  }
}
