import 'package:flutter/material.dart';

import '../theme/detail_tokens.dart';
import '../utils/fmt.dart';
import 'detail_primitives.dart';

/// The pinned bottom bar of the detail screen.
///
/// `property_detail_screen_1.jpg` (monthly): caption on the left, an amber
/// `Flash Sale ⚡` tag above `IDR 14,100,000` on the right, then
/// `HUBUNGI HOST` (outline) + `PILIH UNIT` (solid).
/// The yearly variant drops the Flash Sale tag and reads
/// `per tahun mulai dari`.
class StickyPriceBar extends StatelessWidget {
  final String caption;
  final num amount;
  final bool isFlashSale;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const StickyPriceBar({
    super.key,
    required this.caption,
    required this.amount,
    this.isFlashSale = false,
    this.primaryLabel = 'PILIH UNIT',
    this.secondaryLabel = 'HUBUNGI HOST',
    this.onPrimary,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DT.surface,
        border: const Border(top: BorderSide(color: DT.divider)),
        boxShadow: [
          BoxShadow(
            color: DT.fade(Colors.black, .06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(DT.gutter, 12, DT.gutter, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    caption,
                    style: DT.label.copyWith(fontSize: 14.5),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isFlashSale) ...[
                      const _FlashSaleTag(),
                      const SizedBox(height: 4),
                    ],
                    Text(Fmt.idr(amount), style: DT.price),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BrandOutlineButton(
                    label: secondaryLabel,
                    onPressed: onSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BrandButton(
                    label: primaryLabel,
                    onPressed: onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashSaleTag extends StatelessWidget {
  const _FlashSaleTag();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Flash Sale',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: DT.accent,
            ),
          ),
          SizedBox(width: 3),
          Icon(Icons.bolt_rounded, size: 17, color: DT.accent),
        ],
      );
}
