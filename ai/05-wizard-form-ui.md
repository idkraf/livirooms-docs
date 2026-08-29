# Wizard Form UI — Icon Rendering & Input Upgrades

> **Last updated:** 2026-08-29
> **Scope:** `app/Livewire/Accommodations/WizardForm.php` + `resources/views/livewire/accommodations/wizard_form.blade.php`

---

## Icon Rendering System

All icon fields in the wizard use **Material Design SVG paths** — no Metronic `ki-outline` classes.

### Blade Components

| Component | Path | Purpose |
|---|---|---|
| `flutter-icon` | `resources/views/components/flutter-icon.blade.php` | Server-side inline SVG for static display (badges, tables) |
| `flutter-icon-registry` | `resources/views/components/flutter-icon-registry.blade.php` | `<script>` injecting `window._flutterIconPaths` for Alpine |
| `icon-picker` | `resources/views/components/icon-picker.blade.php` | Alpine.js dropdown with live SVG preview, bound to Livewire |

### Usage

```blade
{{-- Static icon in a badge / table cell --}}
<x-flutter-icon name="pool" size="16" />

{{-- Interactive icon picker bound to a Livewire property --}}
<x-icon-picker
    wire="new_facility_group_icon"
    :icons="['star' => 'Star', 'pool' => 'Kolam Renang']"
/>
```

The `icon-picker` uses a reactive getter `get selected() { return $wire.get(prop) || ''; }` to seamlessly read Livewire state on mount/edit/reset without entangle race conditions.
On item click it calls `$wire.set(propertyName, key)` for immediate, reliable Livewire state synchronization.

### Single Root Element Invariant
The Livewire Blade view (`wizard_form.blade.php`) maintains `<div class="modal fade" ...>` as its single root DOM element. `<x-flutter-icon-registry />` is placed inside this root container to ensure Livewire DOM diffing and event listener attachments operate without DOM morph corruption.

All supported keys are defined in both `flutter-icon-registry.blade.php` (for Alpine)
and `flutter-icon.blade.php` (for server-side rendering).
They map 1:1 to Flutter `Icons.*` identifiers used in the mobile app.

---

## Suggestion Pools (`WizardForm::loadSuggestions()`)

Populated on `booted()` and passed to Blade templates:

| Property | Source | Used in |
|---|---|---|
| `$facilitySuggestions` | `FacilityItem` (context=facility) DB | Tab 2/3 facility name autocomplete |
| `$specSuggestions` | `FacilityItem` (context=spec) DB | Tab 2 spec autocomplete |
| `$nearbySuggestions` | `NearbyPoint` DB | Tab 6 nearby name autocomplete |
| `$buildingListSuggestions` | `BuildingList` DB | Tab 1 building_name autocomplete |
| `$roomNameSuggestions` | Hardcoded presets | Tab 2 room name autocomplete |
| `$bedSuggestions` | Hardcoded presets | Tab 2 bed configuration autocomplete |
| `$facilityCategorySuggestions` | Hardcoded presets | Tab 3 facility group category autocomplete |
| `$nearbyTypeSuggestions` | Hardcoded presets | Tab 6 type autocomplete |
| `$nearbyDistanceSuggestions` | Hardcoded presets | Tab 6 distance autocomplete |
| `$nearbyDurationSuggestions` | Hardcoded presets | Tab 6 duration autocomplete |
| `$badgeSuggestions` | Hardcoded presets | Tab 3 item badge quick-select |
| `$cancellationPolicyPresets` | Hardcoded presets | Tab 1 cancellation policy |
| `$faqQuestionSuggestions` | Hardcoded presets | Tab 7 FAQ question autocomplete |
| `$detailSuggestions` | Hardcoded presets | Tab 7 unit detail label autocomplete |

---

## Per-Tab Input Upgrades Summary

### Tab 1 — Informasi Umum
- `building_name` → Alpine autocomplete from `$buildingListSuggestions`

### Tab 2 — Kapasitas & Kamar
**ROOM mode:**
- `new_room_name` → Alpine autocomplete from `$roomNameSuggestions`
- `new_bed_config` → Alpine autocomplete from `$bedSuggestions`

**UNIT mode:**
- `new_facility_icon` → `<x-icon-picker>` (building facilities)
- `new_spec_icon` → `<x-icon-picker>` (spec icons)
- `new_bed_icon` → `<x-icon-picker>` (bed type icons)
- `new_furniture_icon` → `<x-icon-picker>` (furniture/appliance icons)
- Facility badges list → `<x-flutter-icon>` SVG rendering

### Tab 3 — Fasilitas Hotel (ROOM mode) / Harga & Biaya (UNIT mode)
- ROOM mode: `new_facility_group_category` → Alpine autocomplete from `$facilityCategorySuggestions`
- ROOM mode: `new_facility_group_icon` → `<x-icon-picker>`
- ROOM mode: `new_facility_item_badge` → Quick-preset buttons (Gratis / Biaya tambahan / ...) + free input

### Tab 5 — Kebijakan & Jadwal
- `cancellation_policies` → Dynamic list builder with quick presets (`$cancellationPolicyPresets`) & custom inputs
- ROOM mode: `policy_notes` (Info check-in/out, jam resepsionis, usia min, deposit, kebijakan anak, extra bed, rokok, resepsionis 24 jam)
- `new_check_in_icon` → `<x-icon-picker>`
- `new_check_in_tone` → `<select>` with named tones (info/warning/success/danger/primary)

### Tab 6 — Lokasi Terdekat
- `new_nearby_name` → Alpine autocomplete from `$nearbySuggestions`
- `new_nearby_type` → Alpine autocomplete from `$nearbyTypeSuggestions`
- `new_nearby_distance` → Alpine autocomplete from `$nearbyDistanceSuggestions`
- `new_nearby_duration` → Alpine autocomplete from `$nearbyDurationSuggestions`
- `new_nearby_icon` → `<x-icon-picker>`
- `new_transit_icon` → `<x-icon-picker>`
- Transport point badges → `<x-flutter-icon>` SVG
- Nearby table icon column → `<x-flutter-icon>` SVG

### Tab 7 — FAQ & Detail
- `new_faq_question` → Alpine autocomplete from `$faqQuestionSuggestions`
- `new_detail_icon` → `<x-icon-picker>`
- `new_detail_label` → Alpine autocomplete from `$detailSuggestions`
- Unit detail table icon column → `<x-flutter-icon>` SVG

---

## HotelNormalizer Integration

`HotelNormalizer::normalize()` called during `save()` — unchanged.
Icon key strings stored in DB are plain identifiers (`"star"`, `"pool"`, etc.).
No Metronic class names are persisted.
