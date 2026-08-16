import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../config/theme.dart';
import 'detail_primitives.dart';

/// The `Termasuk` / `Tidak Termasuk` table (`tab_harian_1.jpg`).
///
/// Two bordered columns with grey headers and bulleted rows, collapsed to
/// `InclusionList.collapsedRows` with a centred `tampilkan selengkapnya`
/// toggle. The yearly tab supplies only `excluded`, which renders as one
/// full-width column (`tab_tahunan_default.jpg`).
class InclusionTable extends StatefulWidget {
  final InclusionList inclusions;

  const InclusionTable({super.key, required this.inclusions});

  @override
  State<InclusionTable> createState() => _InclusionTableState();
}

class _InclusionTableState extends State<InclusionTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.inclusions;
    if (data.included.isEmpty && data.excluded.isEmpty) {
      return const SizedBox.shrink();
    }

    final limit = _expanded ? null : data.collapsedRows;
    return Column(
      children: [
        SectionCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DT.cardRadius),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data.included.isNotEmpty)
                  Expanded(
                    child: _Column(
                      title: 'Termasuk',
                      items: data.included,
                      limit: limit,
                    ),
                  ),
                if (data.isTwoColumn)
                  const SizedBox(
                    width: 1,
                    child: ColoredBox(color: DT.divider),
                  ),
                if (data.excluded.isNotEmpty)
                  Expanded(
                    child: _Column(
                      title: 'Tidak Termasuk',
                      items: data.excluded,
                      limit: limit,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // The toggle sits on the canvas *below* the card, not inside it
        // (`tab_tahunan_filter_2.jpg`).
        if (data.isExpandable)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(
                _expanded ? 'tampilkan lebih sedikit' : 'tampilkan selengkapnya',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: DT.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  final String title;
  final List<String> items;
  final int? limit;

  const _Column({required this.title, required this.items, this.limit});

  @override
  Widget build(BuildContext context) {
    final visible =
        limit == null || items.length <= limit! ? items : items.sublist(0, limit!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: DT.fill,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DT.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text('•', style: DT.bodyMuted),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: DT.bodyMuted.copyWith(fontSize: 16, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// `Harga Spesial (Diskon):` — `4+ day(s)` … `5%` (`tab_harian_2.jpg`).
class SpecialPriceList extends StatelessWidget {
  final List<SpecialPriceTier> tiers;

  const SpecialPriceList({super.key, required this.tiers});

  @override
  Widget build(BuildContext context) {
    if (tiers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Harga Spesial (Diskon):', style: DT.body),
          const SizedBox(height: 10),
          for (final tier in tiers)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(tier.label, style: DT.bodyMuted)),
                  Text(
                    tier.discountLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      color: DT.textPrimary,
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




