import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../models/property.dart';
import '../../models/city.dart';
import '../../services/host_service.dart';
import '../../services/city_service.dart';

const _kDraftKey = 'property_form_draft';

class PropertyFormScreen extends StatefulWidget {
  final Property? property;
  const PropertyFormScreen({super.key, this.property});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> with SingleTickerProviderStateMixin {
  final _service = HostService();
  final _cityService = CityService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _buildingNameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  static const _types = ['apartment', 'house', 'villa', 'hotel_residence', 'guest_house', 'exclusive_kost'];
  static const _allFacilities = [
    'Wi-Fi',
    'AC',
    'Pool',
    'Parking',
    'Breakfast',
    'GYM',
    'TV',
    'Kitchen',
  ];

  late TabController _tabController;
  String _type = 'apartment';
  final String _status = 'active';
  int? _cityId;
  int _guests = 1;
  int _bedrooms = 1;
  final Set<String> _facilities = {};
  final List<String> _gallery = [];
  bool _saving = false;
  bool _uploading = false;
  bool _loadingCities = false;
  double? _latitude;
  double? _longitude;
  List<City> _cities = [];
  final ImagePicker _picker = ImagePicker();
  Timer? _autoSaveTimer;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCities();
    _loadDraft();
    final p = widget.property;
    if (p != null) {
      _nameCtrl.text = p.name;
      _addressCtrl.text = p.address;
      _buildingNameCtrl.text = p.buildingName ?? '';
      _descCtrl.text = p.description ?? '';
      if (_types.contains(p.propertyType)) _type = p.propertyType;
      _cityId = p.cityId;
      _guests = p.guestCapacity;
      _bedrooms = p.bedrooms;
      _facilities.addAll(p.facilities);
      final price = p.priceFrom ?? (p.prices.isNotEmpty ? p.prices.first.amount : null);
      if (price != null) _priceCtrl.text = price.toStringAsFixed(0);
      _gallery.addAll(p.gallery);
    }
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _autoSaveTimer?.cancel();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _buildingNameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _scheduleAutoSave();
    }
  }

  Future<void> _loadCities() async {
    setState(() => _loadingCities = true);
    try {
      final cities = await _cityService.list();
      if (mounted) setState(() => _cities = cities);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDraftKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final draft = jsonDecode(raw) as Map<String, dynamic>;
      if (mounted && !_isEdit) {
        setState(() {
          _nameCtrl.text = draft['name'] ?? '';
          _addressCtrl.text = draft['address'] ?? '';
          _buildingNameCtrl.text = draft['building_name'] ?? '';
          _descCtrl.text = draft['description'] ?? '';
          _type = draft['property_type'] ?? _type;
          _cityId = draft['city_id'];
          _guests = draft['guest_capacity'] ?? 1;
          _bedrooms = draft['bedrooms'] ?? 1;
          _facilities
            ..clear()
            ..addAll((draft['facilities'] as List<dynamic>? ?? []).cast<String>());
          _gallery
            ..clear()
            ..addAll((draft['gallery'] as List<dynamic>? ?? []).cast<String>());
        });
      }
    } catch (_) {
      // ignore malformed draft
    }
  }

  Future<void> _scheduleAutoSave() async {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      await _saveLocalDraft();
    });
  }

  Future<void> _saveLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'building_name': _buildingNameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'property_type': _type,
      'city_id': _cityId,
      'guest_capacity': _guests,
      'bedrooms': _bedrooms,
      'facilities': _facilities.toList(),
      'gallery': _gallery.toList(),
    };
    await prefs.setString(_kDraftKey, jsonEncode(draft));
  }

  Future<void> _clearLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDraftKey);
  }

  Future<void> _submit({String status = 'active'}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final gallery = _gallery.map(_toRelativePath).toList();
    final body = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'property_type': _type,
      'address': _addressCtrl.text.trim(),
      'building_name': _buildingNameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'guest_capacity': _guests,
      'bedrooms': _bedrooms,
      'facilities': _facilities.toList(),
      'status': status,
      'gallery': gallery,
      'city_id': _cityId,
      'prices': [
        {
          'price_type': 'daily',
          'amount': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        },
      ],
    };
    try {
      if (_isEdit) {
        await _service.updateProperty(widget.property!.id, body);
      } else {
        await _service.createProperty(body);
      }
      if (!mounted) return;
      await _clearLocalDraft();
      final label = status == 'draft' ? 'Draft disimpan' : 'Properti ditambahkan';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label)),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan properti')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Properti' : 'Tambah Properti'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '1. Dasar'),
            Tab(text: '2. Lokasi'),
            Tab(text: '3. Harga'),
            Tab(text: '4. Galeri'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildLocationTab(),
            _buildPricingTab(),
            _buildMediaFacilityTab(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : () => _submit(status: 'draft'),
                child: const Text('Simpan Draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : () => _submit(status: 'active'),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Publikasikan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Properti'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _buildingNameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Gedung'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Tipe Properti'),
          items: _types
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(_typeLabel(t)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descCtrl,
          decoration: const InputDecoration(labelText: 'Deskripsi'),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildLocationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int>(
          initialValue: _cityId,
          decoration: InputDecoration(
            labelText: 'Kota',
            hintText: _loadingCities ? 'Memuat kota...' : 'Pilih kota',
          ),
          items: _cities.isEmpty
              ? const []
              : _cities.map((city) {
                  return DropdownMenuItem<int>(
                    value: city.id,
                    child: Text(city.name),
                  );
                }).toList(),
          onChanged: (v) => setState(() => _cityId = v),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _openGoogleMaps,
          icon: const Icon(Icons.map_outlined),
          label: const Text('Buka di Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        _label('Kapasitas Tamu'),
        _stepper(
          value: _guests,
          onChanged: (v) => setState(() => _guests = v),
          min: 1,
        ),
        const SizedBox(height: 16),
        _label('Kamar Tidur'),
        _stepper(
          value: _bedrooms,
          onChanged: (v) => setState(() => _bedrooms = v),
          min: 1,
        ),
      ],
    );
  }

  Widget _buildPricingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Harga Sewa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Harga per Malam (IDR)',
            prefixText: 'Rp ',
          ),
          validator: (v) {
            final n = double.tryParse((v ?? '').trim());
            if (n == null || n <= 0) return 'Masukkan harga yang valid';
            return null;
          },
        ),
        const SizedBox(height: 20),
        const Text('Catatan: Backend mendukung multi-durasi (daily, weekly, monthly, yearly). '
            'Saat ini form hanya mengirim tarif harian.'),
      ],
    );
  }

  Widget _buildMediaFacilityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Fasilitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _allFacilities.map((f) {
            final selected = _facilities.contains(f);
            return FilterChip(
              label: Text(f),
              selected: selected,
              onSelected: (on) => setState(() {
                if (on) {
                  _facilities.add(f);
                } else {
                  _facilities.remove(f);
                }
              }),
              selectedColor: AppColors.navy,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _label('Galeri'),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _gallery.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index < _gallery.length) {
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        image: DecorationImage(
                          image: NetworkImage(_gallery[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () async {
                          final removed = _gallery[index];
                          setState(() => _gallery.removeAt(index));
                          final relative = _toRelativePath(removed);
                          try {
                            if (_isEdit && widget.property != null) {
                              await _service.deleteGallery(
                                  widget.property!.id, relative);
                            } else {
                              await _service.deleteGalleryTemp(relative);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _gallery.insert(index, removed));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Gagal menghapus gambar')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return GestureDetector(
                onTap: _uploading
                    ? null
                    : () => _showImageSourceSelection(context),
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _uploading
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.navy,
                            ),
                          ),
                        )
                      : const Icon(Icons.add_a_photo_outlined,
                          color: AppColors.textSecondary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      );

  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    await _uploadGalleryItem(picked);
  }

  Future<void> _uploadGalleryItem(XFile image) async {
    setState(() => _uploading = true);
    try {
      final path = await _service.uploadGallery(image.path);
      if (path.isNotEmpty) {
        setState(() => _gallery.add(path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload gambar')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Widget _stepper({
    required int value,
    required ValueChanged<int> onChanged,
    int min = 0,
  }) {
    return Row(
      children: [
        _stepBtn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('$value',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        _stepBtn(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.border.withValues(alpha: 0.4)
              : AppColors.navy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  String _toRelativePath(String url) {
    if (url.contains('/storage/')) {
      return url.split('/storage/').last;
    }
    return url;
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'apartment': return 'Apartemen';
      case 'house': return 'Rumah';
      case 'villa': return 'Villa';
      case 'hotel_residence': return 'Hotel Residence';
      case 'guest_house': return 'Guest House';
      case 'exclusive_kost': return 'Exclusive Kost';
      default: return t;
    }
  }

  Future<void> _openGoogleMaps() async {
    final query = _latitude != null && _longitude != null
        ? '${_latitude!.toStringAsFixed(6)},${_longitude!.toStringAsFixed(6)}'
        : Uri.encodeComponent(_addressCtrl.text.trim());
    
    if (query.isEmpty) return;
    
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
