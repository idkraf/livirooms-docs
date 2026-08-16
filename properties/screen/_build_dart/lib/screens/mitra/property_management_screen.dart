import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/property.dart';
import '../../router.dart';
import '../../services/host_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/property_card.dart';
import '../../widgets/state_views.dart';

/// Screen 30 — Manajemen Properti: searchable, filterable, paginated list of
/// the host's properties with per-item actions.
class PropertyManagementScreen extends StatefulWidget {
  const PropertyManagementScreen({super.key});

  @override
  State<PropertyManagementScreen> createState() =>
      _PropertyManagementScreenState();
}

class _PropertyManagementScreenState extends State<PropertyManagementScreen> {
  final _service = HostService();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // (label, backend status value)
  static const _filters = <MapEntry<String, String?>>[
    MapEntry('Semua', null),
    MapEntry('Aktif', 'active'),
    MapEntry('Nonaktif', 'inactive'),
    MapEntry('Maintenance', 'maintenance'),
  ];

  String? _status;
  String _query = '';

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _lastPage = 1;
  final List<Property> _items = [];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _page < _lastPage) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
    });
    try {
      final res = await _service.properties(page: 1, status: _status);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(res.data);
        _page = res.currentPage;
        _lastPage = res.lastPage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat properti';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final res = await _service.properties(page: _page + 1, status: _status);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.data);
        _page = res.currentPage;
        _lastPage = res.lastPage;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  List<Property> get _filtered {
    if (_query.isEmpty) return _items;
    final q = _query.toLowerCase();
    return _items
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openForm([Property? property]) async {
    if (property?.bookingMode == 'room') {
      final saved = await Navigator.pushNamed(
        context,
        Routes.mitraHotelForm,
        arguments: property,
      );
      if (saved == true) _load();
      return;
    }

    final saved = await Navigator.pushNamed(
      context,
      Routes.mitraPropertyForm,
      arguments: property,
    );
    if (saved == true) _load();
  }

  void _showAddOptionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Listing Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment, color: AppColors.navy),
                ),
                title: const Text('Unit Apartemen / Kos / Villa',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Sewa seluruh unit harian/bulanan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openForm();
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hotel, color: AppColors.gold),
                ),
                title: const Text('Hotel OTA (Trip.com Style)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Daftarkan hotel & kelola multi-kamar harian'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    Routes.mitraHotelForm,
                    arguments: _items.isNotEmpty ? _items.first.id : 1,
                  ).then((v) {
                    if (v == true) _load();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        onPressed: _showAddOptionSheet,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Properti',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Cari properti...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _status == f.value;
                return ChoiceChip(
                  label: Text(f.key),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _status = f.value);
                    _load();
                  },
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: AppColors.navy,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : RefreshIndicator(
                        color: AppColors.gold,
                        onRefresh: _load,
                        child: list.isEmpty
                            ? ListView(
                                children: [
                                  const SizedBox(height: 80),
                                  EmptyView(
                                    message: 'Belum ada properti',
                                    icon: Icons.apartment_outlined,
                                    actionLabel: 'Tambah Properti',
                                    onAction: () => _openForm(),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.all(16),
                                itemCount: list.length + (_loadingMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) {
                                  if (i >= list.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              color: AppColors.gold)),
                                    );
                                  }
                                  final p = list[i];
                                  return _propertyItem(p);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _propertyItem(Property p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PropertyCard(
          property: p,
          onTap: () => _openForm(p),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _openForm(p);
                case 'calendar':
                  Navigator.pushNamed(context, Routes.mitraCalendar,
                      arguments: p);
                case 'hotel_rooms':
                  Navigator.pushNamed(context, Routes.mitraHotelForm,
                      arguments: p);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (p.bookingMode == 'room')
                const PopupMenuItem(
                  value: 'hotel_rooms',
                  child: ListTile(
                    leading: Icon(Icons.hotel_outlined, color: AppColors.gold),
                    title: Text('Kelola Hotel & Kamar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'calendar',
                child: ListTile(
                  leading: Icon(Icons.calendar_month_outlined),
                  title: Text('Kalender'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: StatusBadge(
            label: Formatters.statusLabel(p.status),
            color: StatusBadge.colorFor(p.status),
          ),
        ),
      ],
    );
  }
}
