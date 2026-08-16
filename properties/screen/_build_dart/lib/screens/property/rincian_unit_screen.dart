import 'package:flutter/material.dart';

import '../../models/unit_pricing.dart';
import 'sheets/payment_plan_sheet.dart';
import '../../config/theme.dart';
import '../../utils/fmt.dart';
import '../../widgets/add_on_selector.dart';
import '../../widgets/detail_primitives.dart';
import '../../widgets/inclusion_table.dart';
import '../../widgets/installment_schedule.dart';
import '../../widgets/price_summary_card.dart';
import '../../widgets/promo_row.dart';
import '../../widgets/unit_stay_card.dart';

/// What `PESAN` hands back to the host app — everything the booking endpoint
/// needs that this screen owns.
class BookingDraft {
  final RentalPeriod period;
  final int duration;
  final DateTime checkIn;
  final DateTime checkOut;
  final List<String> addOnIds;
  final String? planId;
  final String? promoCode;

  /// `Total` on Harian/Bulanan, `Bayar Sekarang` on an installment plan.
  final num payableAmount;

  const BookingDraft({
    required this.period,
    required this.duration,
    required this.checkIn,
    required this.checkOut,
    required this.addOnIds,
    required this.payableAmount,
    this.planId,
    this.promoCode,
  });
}

/// Rincian Unit — mockups `tab_harian_*`, `tab_bulanan_*`, `tab_tahunan_*`.
///
/// One screen, three segments. Each segment carries its own [UnitPricing]
/// because the periods price differently, so the caller supplies a map; in
/// production [onPeriodChanged] re-queries `property_prices` for the tapped
/// segment and the parent passes fresh data down.
///
/// Section order (identical across segments, with two yearly-only inserts):
/// period selector → unit card → *plan field + schedule* → inclusion table →
/// special prices → add-ons → `Ringkasan` → promo → sticky `PESAN`.
class RincianUnitScreen extends StatefulWidget {
  /// Pricing per segment. Segments absent from the map are not offered.
  final Map<RentalPeriod, UnitPricing> pricing;

  final RentalPeriod initialPeriod;

  /// Fired when a segment is tapped — hook up the API refetch here.
  final ValueChanged<RentalPeriod>? onPeriodChanged;

  /// Tapping `Check In - Check Out` — open the date-range picker.
  final VoidCallback? onEditDates;

  /// AppBar share icon (`share_plus` is not a dependency — see README).
  final VoidCallback? onShare;

  /// `Gunakan Kupon` / `Cek semua promo`. Return the chosen promo, or `null`
  /// if the user backed out.
  final Future<AppliedPromo?> Function(BuildContext context)? onBrowsePromos;

  /// `PESAN`.
  final ValueChanged<BookingDraft>? onSubmit;

  const RincianUnitScreen({
    super.key,
    required this.pricing,
    this.initialPeriod = RentalPeriod.daily,
    this.onPeriodChanged,
    this.onEditDates,
    this.onShare,
    this.onBrowsePromos,
    this.onSubmit,
  });

  @override
  State<RincianUnitScreen> createState() => _RincianUnitScreenState();
}

class _RincianUnitScreenState extends State<RincianUnitScreen> {
  /// Segment order of the mockups, narrowed to what the caller supplied.
  static const List<RentalPeriod> _order = [
    RentalPeriod.daily,
    RentalPeriod.monthly,
    RentalPeriod.yearly,
  ];

  late final Map<RentalPeriod, UnitPricing> _data =
      Map<RentalPeriod, UnitPricing>.of(widget.pricing);

  /// Ticked add-ons per segment, seeded from `AddOn.selectedByDefault`.
  late final Map<RentalPeriod, Set<String>> _addOnIds = {
    for (final entry in widget.pricing.entries)
      entry.key: entry.value.addOns
          .where((addOn) => addOn.selectedByDefault)
          .map((addOn) => addOn.id)
          .toSet(),
  };

  /// Selected payment plan per segment — `Bayar Penuh` first, as in
  /// `tab_tahunan_default.jpg`.
  late final Map<RentalPeriod, String> _planIds = {
    for (final entry in widget.pricing.entries)
      if (entry.value.plans.isNotEmpty) entry.key: entry.value.plans.first.id,
  };

  late RentalPeriod _period = widget.pricing.containsKey(widget.initialPeriod)
      ? widget.initialPeriod
      : (_periods.isEmpty ? RentalPeriod.daily : _periods.first);

  List<RentalPeriod> get _periods =>
      _order.where(widget.pricing.containsKey).toList();

  UnitPricing? get _pricing => _data[_period];

  Set<String> get _selectedAddOns => _addOnIds[_period] ??= <String>{};

  /// The active plan, or `null` when the segment has none (Harian / Bulanan).
  InstallmentPlan? get _plan {
    final plans = _pricing?.plans ?? const <InstallmentPlan>[];
    if (plans.isEmpty) return null;
    final id = _planIds[_period];
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return plans.first;
  }

  // ------------------------------------------------------------------- money

  /// Ticked add-ons that carry a price. Rows without one (`Dust Mite Cleaning
  /// Service`) are quote-on-request and add nothing.
  num get _addOnTotal {
    final pricing = _pricing;
    if (pricing == null) return 0;
    num sum = 0;
    for (final addOn in pricing.addOns) {
      if (_selectedAddOns.contains(addOn.id) && addOn.price != null) {
        sum += addOn.price!;
      }
    }
    return sum;
  }

  bool get _isInstallment => _plan != null && !_plan!.isFullPayment;

  /// The mockups list base price, service fee and the promo — and nothing
  /// else, even though ticked add-ons are folded into the closing amount.
  List<SummaryLine> get _summaryLines {
    final pricing = _pricing;
    if (pricing == null) return const [];
    final promo = pricing.promo;
    return [
      if (_isInstallment)
        SummaryLine(
          'Pembayaran Pertama',
          Fmt.idr(_plan!.firstDue - pricing.serviceFee),
        )
      else
        SummaryLine(
          'Total harga untuk ${pricing.durationText}',
          Fmt.idr(pricing.basePrice),
        ),
      SummaryLine('Service Fee', Fmt.idr(pricing.serviceFee)),
      if (promo != null)
        SummaryLine(
          'PROMO',
          Fmt.idrDeduction(promo.savings),
          isDeduction: true,
        ),
    ];
  }

  /// `IDR 1,234,100` = 1,020,000 + 260,000 − 50,000 + 4,100 (`tab_harian_2`).
  /// On an installment plan it is the first row of the schedule plus add-ons:
  /// 30,260,625 + 271,000 = 30,531,625 (`tab_tahunan_filter_2`).
  num get _payable {
    final pricing = _pricing;
    if (pricing == null) return 0;
    final discount = pricing.promo?.savings ?? 0;
    if (_isInstallment) return _plan!.firstDue - discount + _addOnTotal;
    final gross = _plan?.scheduleTotal ?? pricing.basePrice + pricing.serviceFee;
    return gross - discount + _addOnTotal;
  }

  // ----------------------------------------------------------------- actions

  void _selectPeriod(RentalPeriod period) {
    if (period == _period || !_data.containsKey(period)) return;
    setState(() => _period = period);
    widget.onPeriodChanged?.call(period);
  }

  void _changeDuration(int duration) {
    final pricing = _pricing;
    if (pricing == null) return;
    // Only the selection changes here — the amounts come from the API, so the
    // host is expected to refetch on `onPeriodChanged`-style events.
    setState(() => _data[_period] = pricing.copyWith(duration: duration));
  }

  void _toggleAddOn(String id) {
    setState(() {
      if (!_selectedAddOns.remove(id)) _selectedAddOns.add(id);
    });
  }

  Future<void> _pickPlan() async {
    final pricing = _pricing;
    final current = _plan;
    if (pricing == null || current == null) return;
    final picked = await PaymentPlanSheet.show(
      context,
      plans: pricing.plans,
      selectedId: current.id,
    );
    if (picked != null && mounted) {
      setState(() => _planIds[_period] = picked.id);
    }
  }

  Future<void> _browsePromos() async {
    final pricing = _pricing;
    final browse = widget.onBrowsePromos;
    if (pricing == null || browse == null) return;
    final picked = await browse(context);
    if (picked != null && mounted) {
      setState(() => _data[_period] = pricing.copyWith(promo: picked));
    }
  }

  void _removePromo() {
    final pricing = _pricing;
    if (pricing == null) return;
    setState(() => _data[_period] = pricing.copyWith(clearPromo: true));
  }

  void _submit() {
    final pricing = _pricing;
    if (pricing == null) return;
    widget.onSubmit?.call(
      BookingDraft(
        period: _period,
        duration: pricing.duration,
        checkIn: pricing.checkIn,
        checkOut: pricing.checkOut,
        addOnIds: _selectedAddOns.toList(),
        planId: _plan?.id,
        promoCode: pricing.promo?.code,
        payableAmount: _payable,
      ),
    );
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final pricing = _pricing;
    return Scaffold(
      backgroundColor: DT.surface,
      appBar: AppBar(
        backgroundColor: DT.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'RINCIAN UNIT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 24),
            onPressed: widget.onShare,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: pricing == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Harga untuk periode ini belum tersedia.',
                  textAlign: TextAlign.center,
                  style: DT.bodyMuted,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                PeriodSelector(
                  selected: _period,
                  periods: _periods,
                  onChanged: _selectPeriod,
                ),
                UnitStayCard(
                  pricing: pricing,
                  onEditDates: widget.onEditDates,
                  onDurationChanged: _changeDuration,
                ),
                if (pricing.supportsInstallments && _plan != null) ...[
                  const SizedBox(height: 18),
                  PaymentPlanField(plan: _plan!, onTap: _pickPlan),
                  const SizedBox(height: 14),
                  InstallmentSchedule(
                    key: ValueKey(_plan!.id),
                    plan: _plan!,
                    note: pricing.scheduleNote,
                  ),
                ],
                const SizedBox(height: 18),
                InclusionTable(inclusions: pricing.inclusions),
                if (pricing.specialPrices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SpecialPriceList(tiers: pricing.specialPrices),
                ],
                if (pricing.addOns.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  AddOnSelector(
                    addOns: pricing.addOns,
                    selectedIds: _selectedAddOns,
                    onToggle: _toggleAddOn,
                  ),
                ],
                const SizedBox(height: 14),
                PriceSummaryCard(
                  lines: _summaryLines,
                  totalLabel: _isInstallment ? 'Bayar Sekarang' : 'Total',
                  totalAmount: _payable,
                ),
                const SizedBox(height: 14),
                PromoRow(
                  promo: pricing.promo,
                  onBrowse: widget.onBrowsePromos == null ? null : _browsePromos,
                  onRemove: _removePromo,
                ),
              ],
            ),
      bottomNavigationBar: Container(
        color: DT.surface,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(DT.gutter, 8, DT.gutter, 12),
          child: SizedBox(
            width: double.infinity,
            child: BrandButton(label: 'PESAN', onPressed: _submit),
          ),
        ),
      ),
    );
  }
}



