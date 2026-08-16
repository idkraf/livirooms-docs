import 'package:flutter/material.dart';

import '../models/unit_pricing.dart';
import '../config/theme.dart';
import '../utils/fmt.dart';
import 'detail_primitives.dart';

/// `Pilih Add On` — red checkboxes, an ⓘ tooltip and a right-aligned price
/// (`tab_harian_2.jpg`, `tab_bulanan_2.jpg`).
///
/// The header carries a collapse chevron, and a row with `price == null` shows
/// no amount — matching the mockup's unchecked `Dust Mite Cleaning Service`.
class AddOnSelector extends StatefulWidget {
  final List<AddOn> addOns;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const AddOnSelector({
    super.key,
    required this.addOns,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  State<AddOnSelector> createState() => _AddOnSelectorState();
}

class _AddOnSelectorState extends State<AddOnSelector> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final addOns = widget.addOns;
    if (addOns.isEmpty) return const SizedBox.shrink();
    return TitledCard(
      title: 'Pilih Add On',
      trailing: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        behavior: HitTestBehavior.opaque,
        child: Icon(
          _expanded
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_up_rounded,
          size: 26,
          color: DT.textPrimary,
        ),
      ),
      child: _expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < addOns.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                    child: _AddOnRow(
                      addOn: addOns[i],
                      selected: widget.selectedIds.contains(addOns[i].id),
                      onToggle: () => widget.onToggle(addOns[i].id),
                    ),
                  ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class _AddOnRow extends StatelessWidget {
  final AddOn addOn;
  final bool selected;
  final VoidCallback onToggle;

  const _AddOnRow({
    required this.addOn,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? DT.brand : DT.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected ? DT.brand : DT.textTertiary,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Text(
              addOn.displayName,
              style: DT.body.copyWith(fontSize: 14.5),
            ),
          ),
        ),
        if (addOn.info.isNotEmpty) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _showInfo(context),
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.info_outline,
                size: 19, color: DT.textTertiary),
          ),
        ],
        if (addOn.price != null) ...[
          const SizedBox(width: 10),
          Text(
            Fmt.idr(addOn.price),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: DT.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DT.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(addOn.name, style: DT.cardTitle),
              const SizedBox(height: 10),
              Text(addOn.info, style: DT.bodyMuted),
            ],
          ),
        ),
      ),
    );
  }
}




