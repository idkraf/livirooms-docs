import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../config/theme.dart';
import 'detail_primitives.dart';

/// `Harian | Bulanan | Tahunan` — the grey pill segmented control at the top
/// of the Rincian Unit screen. The selected segment is a white chip with bold
/// red text (`tab_harian_1.jpg`).
class PeriodSelector extends StatelessWidget {
  final RentalPeriod selected;
  final List<RentalPeriod> periods;
  final ValueChanged<RentalPeriod> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.periods = const [
      RentalPeriod.daily,
      RentalPeriod.monthly,
      RentalPeriod.yearly,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(DT.gutter, 14, DT.gutter, 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DT.fill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final period in periods)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(period),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: period == selected ? DT.surface : DT.fill,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: period == selected
                        ? [
                            BoxShadow(
                              color: DT.fade(Colors.black, .07),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    period.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          period == selected ? FontWeight.w700 : FontWeight.w500,
                      color: period == selected ? DT.brand : DT.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The unit card: thumbnail, name, red bed/bath glyphs, then one stacked field
/// per row — `Check In - Check Out` always, plus `Bulan` / `Tahun` with a
/// chevron for the two long-stay tabs
/// (`tab_harian_1.jpg`, `tab_bulanan_1.jpg`, `tab_tahunan_default.jpg`).
///
/// The fields are plain rows closed by a hairline, not bordered inputs — the
/// mockups keep the whole card flat.
class UnitStayCard extends StatelessWidget {
  final UnitPricing pricing;
  final VoidCallback? onEditDates;
  final ValueChanged<int>? onDurationChanged;

  const UnitStayCard({
    super.key,
    required this.pricing,
    this.onEditDates,
    this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final durationLabel = pricing.period.durationLabel;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(DT.gutter, DT.gutter, DT.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetImage(
                url: pricing.thumbnailUrl,
                width: 84,
                height: 84,
                radius: BorderRadius.circular(DT.tileRadius),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pricing.propertyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DT.cardTitle,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Spec(
                          icon: Icons.bed_rounded,
                          value: '${pricing.bedrooms}',
                        ),
                        const SizedBox(width: 16),
                        _Spec(
                          icon: Icons.bathtub_rounded,
                          value: '${pricing.bathrooms}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _FieldRow(
            caption: 'Check In - Check Out',
            value: pricing.stayRange,
            onTap: onEditDates,
          ),
          if (durationLabel != null)
            _FieldRow(
              caption: durationLabel,
              value: pricing.durationText,
              showChevron: true,
              onTap: () => _pickDuration(context),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDuration(BuildContext context) async {
    if (onDurationChanged == null) return;
    final options = pricing.durationOptions.isEmpty
        ? <int>[pricing.duration]
        : pricing.durationOptions;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: DT.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: DT.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            for (final option in options)
              ListTile(
                title: Text(
                  pricing.durationOptionText(option),
                  style: option == pricing.duration ? DT.bodyStrong : DT.body,
                ),
                trailing: option == pricing.duration
                    ? const Icon(Icons.check, color: DT.brand)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) onDurationChanged!(picked);
  }
}

/// `Check In - Check Out` / `16 Agt 2026 - 17 Agt 2026` — a bold caption over
/// a muted value, closed by a hairline.
class _FieldRow extends StatelessWidget {
  final String caption;
  final String value;
  final bool showChevron;
  final VoidCallback? onTap;

  const _FieldRow({
    required this.caption,
    required this.value,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caption, style: DT.bodyStrong),
                    const SizedBox(height: 6),
                    Text(value, style: DT.bodyMuted),
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 26,
                  color: DT.textPrimary,
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: DT.divider),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Spec({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 20, color: DT.brand),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DT.textPrimary,
            ),
          ),
        ],
      );
}




