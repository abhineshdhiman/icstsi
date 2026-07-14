import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/billing_estimate.dart';

class BillingEstimateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BillingEstimate>> getEstimates(String sessionId) async {
    try {
      final response = await _supabase
          .from('billing_estimates')
          .select('*, billing_estimate_items(*)')
          .eq('session_id', sessionId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => BillingEstimate.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch estimates: $e');
    }
  }

  Future<BillingEstimate> saveEstimate(BillingEstimate estimate) async {
    try {
      final payload = estimate.toJson();
      final response = await _supabase
          .from('billing_estimates')
          .insert(payload)
          .select('*, billing_estimate_items(*)')
          .single();
      return BillingEstimate.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to save estimate: $e');
    }
  }

  Future<void> deleteEstimate(String id) async {
    try {
      await _supabase.from('billing_estimates').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete estimate: $e');
    }
  }

  Future<void> deleteAllEstimates(String sessionId, String terminal) async {
    try {
      await _supabase
          .from('billing_estimates')
          .delete()
          .eq('session_id', sessionId)
          .eq('terminal', terminal);
    } catch (e) {
      throw Exception('Failed to delete estimates: $e');
    }
  }

  // Local calculation until an Edge Function is wired up.
  // Replace with a Supabase Edge Function call when rate tables are ready.
  BillingEstimate calculateLocally(BillingEstimate input) {
    const arrRate = 1500.0;
    const wharfRate = 160.0;
    const weighRate = 200.0;
    const reeferRate = 3650.0;
    const storageRate = 2500.0;
    const hccaRate = 0.0;
    const deaRate = 0.0;

    final totalContainers = input.qty20 + input.qty40 + input.qty45;
    final arrastre = arrRate * totalContainers;
    final wharfage = wharfRate * totalContainers;
    final weighing = input.weighing ? weighRate * totalContainers : 0.0;
    final reefer = input.reefer ? reeferRate * totalContainers : 0.0;
    final storage = storageRate * totalContainers;
    final hcca = hccaRate * totalContainers;
    final dea = input.dea ? deaRate * totalContainers : 0.0;

    final total = arrastre + wharfage + weighing + reefer + storage + hcca + dea;

    final items = [
      BillingEstimateItem(chargeItem: 'Arrastre', amount: arrastre),
      BillingEstimateItem(chargeItem: 'Storage', amount: storage),
      if (input.reefer)
        BillingEstimateItem(chargeItem: 'Reefer', amount: reefer),
      if (input.weighing)
        BillingEstimateItem(chargeItem: 'Weighing', amount: weighing),
      BillingEstimateItem(chargeItem: 'Wharfage', amount: wharfage),
      BillingEstimateItem(chargeItem: 'DEA', amount: dea),
      BillingEstimateItem(chargeItem: 'HCCA', amount: hcca),
    ];

    return BillingEstimate(
      sessionId: input.sessionId,
      terminal: input.terminal,
      category: input.category,
      qty20: input.qty20,
      qty40: input.qty40,
      qty45: input.qty45,
      weighing: input.weighing,
      outOfGauge: input.outOfGauge,
      reefer: input.reefer,
      dea: input.dea,
      dgClass: input.dgClass,
      wCm: input.wCm,
      hCm: input.hCm,
      lCm: input.lCm,
      dischargeDate: input.dischargeDate,
      gateOutDate: input.gateOutDate,
      plugInDate: input.plugInDate,
      plugOutDate: input.plugOutDate,
      totalAmount: total,
      items: items,
    );
  }
}
