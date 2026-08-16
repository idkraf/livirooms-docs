import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../theme/detail_tokens.dart';
import '../widgets/detail_primitives.dart';

/// `PILIH RENCANA PEMBAYARAN`
/// (`tab_tahunan_filter_show_select_screen_cicilan.jpg`).
///
/// One card per plan; the selected card turns solid red with a white ✓.
/// Returns the chosen plan through `Navigator.pop`.
class PaymentPlanSheet extends StatelessWidget {
  final List<InstallmentPlan> plans;
  final String selectedId;

  const PaymentPlanSheet({
    super.key,
    required this.plans,
    required this.selectedId,
  });

  static Future<InstallmentPlan?> show(
    BuildContext context, {
    required List<InstallmentPlan> plans,
    required String selectedId,
  }) {
    return Navigator.of(context).push<InstallmentPlan>(
      MaterialPageRoute<InstallmentPlan>(
        builder: (_) => PaymentPlanSheet(plans: plans, selectedId: selectedId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'PILIH RENCANA PEMBAYARAN',
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(DT.gutter, DT.gutter, DT.gutter, 28),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _PlanCard(
          plan: plans[i],
          selected: plans[i].id == selectedId,
          onTap: () => Navigator.of(context).pop(plans[i]),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final InstallmentPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.white : DT.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? DT.brand : DT.surface,
          borderRadius: BorderRadius.circular(DT.tileRadius),
          border: Border.all(color: selected ? DT.brand : DT.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                plan.pickerLabel,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check, size: 22, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
