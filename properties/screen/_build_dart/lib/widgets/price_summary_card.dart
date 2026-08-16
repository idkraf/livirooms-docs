import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../config/theme.dart';
import '../utils/fmt.dart';
import 'detail_primitives.dart';

/// `Ringkasan` — the money breakdown above the promo row.
///
/// Rows are supplied as already-formatted [SummaryLine]s so the screen owns
/// the arithmetic (it is the only place that knows which add-ons are ticked
/// and which installment plan is selected). The closing row has a black label
/// and a red amount: `Total` on Harian/Bulanan (`tab_harian_2.jpg`) and
/// `Bayar Sekarang` on Tahunan, where the card summarises only the first
/// installment (`tab_tahunan_filter_2.jpg`).
///
/// Note the mockups leave ticked add-ons *out* of the visible rows while still
/// counting them in the closing amount — see README.
class PriceSummaryCard extends StatelessWidget {
  final List<SummaryLine> lines;
  final String totalLabel;
  final num totalAmount;

  const PriceSummaryCard({
    super.key,
    required this.lines,
    required this.totalAmount,
    this.totalLabel = 'Total',
  });

  @override
  Widget build(BuildContext context) {
    return TitledCard(
      title: 'Ringkasan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: DT.bodyMuted.copyWith(fontSize: 15.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    line.value,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: DT.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1, color: DT.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DT.textPrimary,
                  ),
                ),
              ),
              Text(
                Fmt.idr(totalAmount),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: DT.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




