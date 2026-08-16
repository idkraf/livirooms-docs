import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../theme/detail_tokens.dart';
import '../utils/fmt.dart';
import 'detail_primitives.dart';

/// `Jadwal Pembayaran` — the installment table of the Tahunan tab
/// (`tab_tahunan_filter_1.jpg`).
///
/// A grey header with a collapse chevron, a bordered two-column table
/// (date · amount), a bold `Total` row and the red italic footnote.
///
/// The `Total` comes from `InstallmentPlan.total` when the backend supplies
/// one — in the mockup it does not equal the sum of the visible rows, and the
/// screenshot is reproduced as printed (see README).
class InstallmentSchedule extends StatefulWidget {
  final InstallmentPlan plan;
  final String note;
  final bool initiallyExpanded;

  const InstallmentSchedule({
    super.key,
    required this.plan,
    this.note = '',
    this.initiallyExpanded = true,
  });

  @override
  State<InstallmentSchedule> createState() => _InstallmentScheduleState();
}

class _InstallmentScheduleState extends State<InstallmentSchedule> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    if (plan.entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: DT.fill,
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(8))
                    : BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Jadwal Pembayaran', style: DT.bodyStrong),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: DT.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: DT.border),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Column(
                children: [
                  for (final entry in plan.entries)
                    _Row(
                      left: Fmt.date(entry.date),
                      right: Fmt.idr(entry.amount),
                    ),
                  _Row(
                    left: 'Total',
                    right: Fmt.idr(plan.scheduleTotal),
                    bold: true,
                    showDivider: false,
                  ),
                ],
              ),
            ),
          if (widget.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              widget.note,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: DT.brand,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;
  final bool showDivider;

  const _Row({
    required this.left,
    required this.right,
    this.bold = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14.5,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: DT.textPrimary,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text(left, style: style)),
              Text(right, style: style),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: DT.divider),
      ],
    );
  }
}

/// The `Cicilan / Rencana pembayaran` field above the schedule. Tapping opens
/// `sheets/payment_plan_sheet.dart`.
class PaymentPlanField extends StatelessWidget {
  final InstallmentPlan plan;
  final VoidCallback? onTap;

  const PaymentPlanField({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
      child: SizedBox(
        width: double.infinity,
        child: DropdownField(
          caption: 'Cicilan / Rencana pembayaran',
          value: plan.fieldLabel,
          width: double.infinity,
          onTap: onTap,
        ),
      ),
    );
  }
}
