import 'package:flutter/material.dart';

import '../theme/detail_tokens.dart';

/// The three white cards under the spec strip in
/// `property_detail_screen_1.jpg` — `Review (0)`, `Diskusi (0)`, `Bagikan`.
///
/// The first card shows a `NEW` word-mark instead of a glyph while the
/// property has no reviews yet, exactly as in the mockup; once reviews exist
/// the star score takes its place.
class DetailActionRow extends StatelessWidget {
  final int reviewCount;
  final double? reviewScore;
  final int questionCount;
  final VoidCallback? onReviewTap;
  final VoidCallback? onDiscussionTap;
  final VoidCallback? onShareTap;

  const DetailActionRow({
    super.key,
    this.reviewCount = 0,
    this.reviewScore,
    this.questionCount = 0,
    this.onReviewTap,
    this.onDiscussionTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = reviewCount > 0 && reviewScore != null;
    return Container(
      color: DT.surface,
      padding: const EdgeInsets.fromLTRB(DT.gutter, 20, DT.gutter, 20),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              label: 'Review ($reviewCount)',
              onTap: onReviewTap,
              glyph: hasScore
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 22, color: DT.accent),
                        const SizedBox(width: 4),
                        Text(
                          reviewScore!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: DT.textPrimary,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                        color: DT.brandMuted,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionCard(
              label: 'Diskusi ($questionCount)',
              onTap: onDiscussionTap,
              glyph: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 24, color: DT.textPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionCard(
              label: 'Bagikan',
              onTap: onShareTap,
              glyph: const Icon(Icons.share_outlined,
                  size: 24, color: DT.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Widget glyph;
  final String label;
  final VoidCallback? onTap;

  const _ActionCard({required this.glyph, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: DT.surface,
          borderRadius: BorderRadius.circular(DT.tileRadius),
          border: Border.all(color: DT.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 26, child: Center(child: glyph)),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DT.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
