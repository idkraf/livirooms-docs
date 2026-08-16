import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../utils/detail_icons.dart';
import '../utils/fmt.dart';
import 'detail_primitives.dart';

/// `Informasi Tambahan` — the second anchored section.
///
/// Mockups: `..._3_tab_info_tab_check_in_info.jpg`, `..._3_tab_info_tab_deposit
/// .jpeg`, `..._3_tab_info_tab_unit_detail.jpeg`. One heading, three chips,
/// three panels; switching chips does not scroll the page.
class InfoSection extends StatefulWidget {
  final PropertyDetail detail;

  const InfoSection({super.key, required this.detail});

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  int _tab = 0;

  static const List<String> _labels = ['Check In Info', 'Deposit', 'Unit Detail'];

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Informasi Tambahan',
            padding: EdgeInsets.fromLTRB(DT.gutter, 20, DT.gutter, 14),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
            child: Row(
              children: [
                for (var i = 0; i < _labels.length; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i == _labels.length - 1 ? 0 : 10),
                    child: _Chip(
                      label: _labels[i],
                      selected: _tab == i,
                      onTap: () => setState(() => _tab = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
            child: _panel(detail),
          ),
        ],
      ),
    );
  }

  Widget _panel(PropertyDetail detail) {
    switch (_tab) {
      case 1:
        return DepositPanel(
          amount: detail.depositAmount,
          notes: detail.depositNotes,
        );
      case 2:
        return UnitDetailPanel(rows: detail.unitDetailRows);
      default:
        return InfoNotePanel(notes: detail.checkInNotes);
    }
  }
}

/// Segmented chip — brand-tinted with a brand border when selected.
class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? DT.brandSoft : DT.fill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? DT.brand : DT.fill,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: selected ? DT.brand : DT.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Card of `InfoNote` rows — the Check In Info panel.
class InfoNotePanel extends StatelessWidget {
  final List<InfoNote> notes;

  const InfoNotePanel({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < notes.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: DT.gutter),
                child: Divider(height: 1, thickness: 1, color: DT.divider),
              ),
            InfoNoteRow(note: notes[i]),
          ],
        ],
      ),
    );
  }
}

/// Tinted circular glyph, grey caption title, darker body paragraphs.
class InfoNoteRow extends StatelessWidget {
  final InfoNote note;

  const InfoNoteRow({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIconBadge(
            icon: DetailIcons.of(note.iconKey),
            fill: _toneFill(note.tone),
            glyph: _toneGlyph(note.tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.title.isNotEmpty) ...[
                  Text(note.title, style: DT.caption),
                  const SizedBox(height: 5),
                ],
                for (var i = 0; i < note.paragraphs.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                    child: Text(
                      note.paragraphs[i],
                      style: DT.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _toneFill(InfoTone tone) {
    switch (tone) {
      case InfoTone.warning:
        return DT.accentSoft;
      case InfoTone.brand:
        return DT.brandSoft;
      case InfoTone.success:
        return DT.successSoft;
      case InfoTone.info:
        return DT.infoSoft;
    }
  }

  static Color _toneGlyph(InfoTone tone) {
    switch (tone) {
      case InfoTone.warning:
        return DT.accent;
      case InfoTone.brand:
        return DT.brand;
      case InfoTone.success:
        return DT.success;
      case InfoTone.info:
        return DT.info;
    }
  }
}

/// Deposit panel — the amount on a green tinted row, then the notes.
class DepositPanel extends StatelessWidget {
  final num? amount;
  final List<InfoNote> notes;

  const DepositPanel({super.key, this.amount, this.notes = const []});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          if (amount != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: DT.gutter, vertical: 16),
              child: Row(
                children: [
                  const SoftIconBadge(
                    icon: Icons.savings_outlined,
                    fill: DT.depositSoft,
                    glyph: DT.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deposit', style: DT.caption),
                        const SizedBox(height: 3),
                        Text(
                          Fmt.idr(amount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: DT.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          for (final note in notes) ...[
            if (amount != null || note != notes.first)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: DT.gutter),
                child: Divider(height: 1, thickness: 1, color: DT.divider),
              ),
            InfoNoteRow(note: note),
          ],
        ],
      ),
    );
  }
}

/// Unit Detail panel — Gedung / Tower / Lantai / Property Tayang Sejak /
/// Parkir, the last one carrying `Mobil` + `Motor` money groups.
class UnitDetailPanel extends StatelessWidget {
  final List<UnitDetailRow> rows;

  const UnitDetailPanel({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: DT.gutter),
                child: Divider(height: 1, thickness: 1, color: DT.divider),
              ),
            _Row(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final UnitDetailRow row;

  const _Row({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DT.gutter, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIconBadge(
            icon: DetailIcons.of(row.iconKey),
            fill: DT.fill,
            glyph: DT.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label, style: DT.caption),
                if (row.value != null && row.value!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(row.value!, style: DT.bodyStrong),
                ],
                for (final group in row.groups)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.title, style: DT.bodyStrong),
                        for (final line in group.lines)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(line.display, style: DT.bodyMuted),
                          ),
                      ],
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
