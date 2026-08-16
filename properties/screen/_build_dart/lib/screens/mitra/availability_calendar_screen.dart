import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/property.dart';

/// Local demo state for a calendar day.
enum _DayState { available, booked, blocked, special }

/// Screen 32 — Availability & pricing calendar (hand-built monthly grid,
/// purely local/demo state).
class AvailabilityCalendarScreen extends StatefulWidget {
  final Property? property;
  const AvailabilityCalendarScreen({super.key, this.property});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  late DateTime _month;

  // date (y,m,d key) -> demo state override.
  final Map<String, _DayState> _states = {};

  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  void _onDayTap(DateTime day) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${day.day} ${_monthNames[day.month - 1]} ${day.year}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.danger),
              title: const Text('Blokir Tanggal'),
              onTap: () {
                setState(() => _states[_key(day)] = _DayState.blocked);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.attach_money, color: AppColors.goldDark),
              title: const Text('Atur Harga Khusus'),
              onTap: () {
                setState(() => _states[_key(day)] = _DayState.special);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.check_circle_outline, color: AppColors.success),
              title: const Text('Tandai Tersedia'),
              onTap: () {
                setState(() => _states.remove(_key(day)));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _colorFor(_DayState state) {
    switch (state) {
      case _DayState.available:
        return AppColors.success;
      case _DayState.booked:
        return AppColors.danger;
      case _DayState.blocked:
        return AppColors.textSecondary;
      case _DayState.special:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property?.name ?? 'Kalender Ketersediaan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _monthNav(),
          const SizedBox(height: 16),
          _weekdayRow(),
          const SizedBox(height: 8),
          _grid(),
          const SizedBox(height: 24),
          _legend(),
        ],
      ),
    );
  }

  Widget _monthNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${_monthNames[_month.month - 1]} ${_month.year}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _weekdayRow() {
    return Row(
      children: _weekdays
          .map((d) => Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ))
          .toList(),
    );
  }

  Widget _grid() {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // Monday-first offset (Dart weekday: Mon=1..Sun=7).
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final leadingBlanks = firstWeekday - 1;
    final cells = leadingBlanks + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        if (i < leadingBlanks) return const SizedBox.shrink();
        final dayNum = i - leadingBlanks + 1;
        final day = DateTime(_month.year, _month.month, dayNum);
        final state = _states[_key(day)];
        final bg = state == null
            ? AppColors.surface
            : _colorFor(state).withValues(alpha: 0.18);
        final fg = state == null ? AppColors.textPrimary : _colorFor(state);
        return InkWell(
          onTap: () => _onDayTap(day),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: state == null
                    ? AppColors.border
                    : _colorFor(state).withValues(alpha: 0.6),
              ),
            ),
            child: Center(
              child: Text(
                '$dayNum',
                style: TextStyle(fontWeight: FontWeight.w600, color: fg),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem('Tersedia', AppColors.success),
        _legendItem('Terisi', AppColors.danger),
        _legendItem('Diblokir', AppColors.textSecondary),
        _legendItem('Harga Khusus', AppColors.gold),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}
