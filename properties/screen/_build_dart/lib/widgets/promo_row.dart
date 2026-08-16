import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../config/theme.dart';
import 'detail_primitives.dart';

/// The promo block between `Ringkasan` and `PESAN`.
///
/// Applied (`tab_harian_2.jpg`, `tab_bulanan_2.jpg`): a white card with a pink
/// ticket badge, the code in bold, the green `Anda menghemat - IDR 50,000`
/// line and a soft-pink `Hapus` pill — followed by the full-width outlined
/// `Cek semua promo` button.
/// Empty (`tab_tahunan_filter_2.jpg`): one bordered row with a grey badge and
/// grey `Gunakan Kupon` label, and no button underneath.
class PromoRow extends StatelessWidget {
  final AppliedPromo? promo;
  final VoidCallback? onBrowse;
  final VoidCallback? onRemove;

  const PromoRow({super.key, this.promo, this.onBrowse, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final applied = promo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
      child: applied == null ? _empty() : _applied(applied),
    );
  }

  Widget _empty() {
    return GestureDetector(
      onTap: onBrowse,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: DT.surface,
          borderRadius: BorderRadius.circular(DT.cardRadius),
          border: Border.all(color: DT.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _TicketBadge(fill: DT.fill, glyph: DT.textTertiary),
            const SizedBox(width: 12),
            Text(
              'Gunakan Kupon',
              style: DT.body.copyWith(fontSize: 17, color: DT.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _applied(AppliedPromo applied) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: DT.surface,
            borderRadius: BorderRadius.circular(DT.cardRadius),
          ),
          child: Row(
            children: [
              const _TicketBadge(fill: DT.brandSoft, glyph: DT.brandMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applied.code, style: DT.bodyStrong),
                    const SizedBox(height: 3),
                    Text(
                      applied.savingsLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: DT.success,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: DT.brandSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: DT.brand,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BrandOutlineButton(
          label: 'Cek semua promo',
          onPressed: onBrowse,
          trailing: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: DT.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.percent_rounded,
                size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// The rounded ticket square left of the code — pink when a promo is applied,
/// grey when the row is still empty.
class _TicketBadge extends StatelessWidget {
  final Color fill;
  final Color glyph;

  const _TicketBadge({required this.fill, required this.glyph});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 32,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.percent_rounded, size: 18, color: glyph),
      );
}




