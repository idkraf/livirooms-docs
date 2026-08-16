import 'package:flutter/material.dart';

import '../theme/detail_tokens.dart';

/// Small building blocks shared by both screens. Kept in one file so the
/// per-section widgets stay focused on layout.

/// Network image with a grey placeholder and a graceful error box.
///
/// Uses `Image.network`, not `cached_network_image`, so this folder has no
/// package dependencies. Swap for `AppNetworkImage`
/// (`flutter/lib/widgets/app_network_image.dart`) when integrating.
class NetImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;

  const NetImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = (url == null || url!.isEmpty)
        ? _fallback()
        : Image.network(
            url!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallback(),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : _fallback(),
          );
    if (radius == null) return child;
    return ClipRRect(borderRadius: radius!, child: child);
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: DT.fill,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: DT.fade(DT.textTertiary, .6)),
      );
}

/// `Fasilitas` / `Peta Lokasi` / `Foto/Video dari Tamu` — a bold section
/// heading with an optional red action on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(DT.gutter, 18, DT.gutter, 12),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: style ?? DT.sectionTitle)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(actionLabel!, style: DT.link),
            ),
        ],
      ),
    );
  }
}

/// The white rounded card the mockups use for Pengantar / Deskripsi /
/// Ringkasan / the info panels.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DT.gutter),
    this.margin = const EdgeInsets.symmetric(horizontal: DT.gutter),
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: DT.card,
        child: child,
      );
}

/// A card whose bold title sits above a hairline rule — `Pengantar`,
/// `Deskripsi`, `Ringkasan`.
class TitledCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Right-hand widget when the header needs more than a text action — the
  /// collapse chevron of `Pilih Add On`.
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;

  const TitledCard({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.margin = const EdgeInsets.symmetric(horizontal: DT.gutter),
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      margin: margin,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
            child: Row(
              children: [
                Expanded(child: Text(title, style: DT.cardTitle)),
                if (actionLabel != null)
                  GestureDetector(
                    onTap: onAction,
                    behavior: HitTestBehavior.opaque,
                    child: Text(actionLabel!, style: DT.link),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(DT.gutter, 14, DT.gutter, 16),
            child: Divider(height: 1, thickness: 1, color: DT.divider),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DT.gutter),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Tinted circular glyph used by the info panels and the "Sekitar" grid.
class SoftIconBadge extends StatelessWidget {
  final IconData icon;
  final Color fill;
  final Color glyph;
  final double size;

  const SoftIconBadge({
    super.key,
    required this.icon,
    required this.fill,
    required this.glyph,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: size * .5, color: glyph),
      );
}

/// The amber `Apartment` tag.
class ToneTag extends StatelessWidget {
  final String label;
  final Color fill;
  final Color textColor;

  const ToneTag({
    super.key,
    required this.label,
    this.fill = DT.accentSoft,
    this.textColor = DT.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      );
}

/// Solid red CTA — `PILIH UNIT`, `PESAN`, `AJUKAN PERTANYAAN`.
class BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const BrandButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: DT.brand,
            disabledBackgroundColor: DT.fade(DT.brand, .5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
        ),
      );
}

/// Outlined red CTA — `HUBUNGI HOST`, `Cek semua promo`.
class BrandOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Widget? trailing;

  const BrandOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 54,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: DT.brand,
            side: const BorderSide(color: DT.brand),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      );
}

/// `✓ Access Card` row of the two full-screen list sheets.
class CheckListTile extends StatelessWidget {
  final String label;
  final bool showDivider;

  const CheckListTile({
    super.key,
    required this.label,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DT.gutter,
              vertical: 18,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 44,
                  child: Icon(Icons.check, color: DT.brand, size: 24),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 17, color: DT.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, thickness: 1, color: DT.divider),
        ],
      );
}

/// Bordered read-only field with an optional caption above and a trailing
/// chevron — the `Bulan` / `Tahun` duration pickers and the
/// `Cicilan / Rencana pembayaran` field of the Rincian Unit screen.
///
/// Tapping delegates to [onTap] instead of opening a `DropdownButton`, because
/// the mockups open a full-screen picker for the payment plan
/// (`tab_tahunan_filter_show_select_screen_cicilan.jpg`).
class DropdownField extends StatelessWidget {
  final String? caption;
  final String value;
  final VoidCallback? onTap;
  final double? width;

  const DropdownField({
    super.key,
    required this.value,
    this.caption,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (caption != null) ...[
          Text(caption!, style: DT.caption),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: DT.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DT.border),
            ),
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DT.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22, color: DT.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Red centred AppBar with an ✕ close button — the shell of every full-screen
/// sheet in the mockups (`Q&A`, `ULASAN`, `DAFTAR FASILITAS GEDUNG`, …).
class SheetScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottom;
  final Color background;

  const SheetScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.background = DT.canvas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: DT.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: body,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(DT.gutter, 0, DT.gutter, 12),
              child: bottom!,
            ),
    );
  }
}
