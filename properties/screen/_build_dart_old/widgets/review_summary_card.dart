import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../utils/fmt.dart';

/// The review block of `property_detail_screen_1_with_reviews.jpeg`:
/// a green `5.0 / 5` badge with `Istimewa` + `Dari 2 ulasan` and a red
/// `Lihat Semua`, followed by the most recent review.
///
/// Renders nothing when the property has no reviews — in that state the
/// mockup shows only the `NEW` action card.
class ReviewSummaryCard extends StatelessWidget {
  final ReviewSummary summary;
  final List<PropertyReview> reviews;

  /// How many reviews to preview inline; the sheet shows the rest.
  final int previewCount;

  final VoidCallback? onSeeAll;

  const ReviewSummaryCard({
    super.key,
    required this.summary,
    this.reviews = const [],
    this.previewCount = 1,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();
    final preview = reviews.take(previewCount).toList(growable: false);

    return Container(
      color: DT.surface,
      padding: const EdgeInsets.fromLTRB(DT.gutter, 4, DT.gutter, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScoreBadge(score: summary.average),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.label, style: DT.cardTitle),
                    const SizedBox(height: 3),
                    Text(
                      'Dari ${summary.total} ulasan',
                      style: DT.label,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                behavior: HitTestBehavior.opaque,
                child: Text('Lihat Semua', style: DT.link),
              ),
            ],
          ),
          for (final review in preview) ...[
            const SizedBox(height: 16),
            ReviewTile(review: review),
          ],
        ],
      ),
    );
  }
}

/// Green rounded `5.0 / 5` pill.
class _ScoreBadge extends StatelessWidget {
  final double score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: DT.success,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            Fmt.score(score),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Text(
            ' / 5',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// One review: red score chip, `Sewa Bulanan` period, right-aligned date and
/// the comment underneath. Reused by `reviews_sheet.dart`, where the author's
/// masked name replaces the period label position.
class ReviewTile extends StatelessWidget {
  final PropertyReview review;

  /// The sheet variant shows the masked author name and a `•••` menu.
  final bool showAuthor;

  const ReviewTile({super.key, required this.review, this.showAuthor = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DT.surface,
        borderRadius: BorderRadius.circular(DT.tileRadius),
        border: Border.all(color: DT.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: DT.brand,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  Fmt.score(review.score),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAuthor)
                      Text(review.maskedName, style: DT.bodyStrong),
                    if (review.periodLabel.isNotEmpty)
                      Text(
                        review.periodLabel,
                        style: showAuthor ? DT.caption : DT.label,
                      ),
                  ],
                ),
              ),
              Text(Fmt.date(review.createdAt), style: DT.caption),
              if (showAuthor) ...[
                const SizedBox(width: 8),
                const Icon(Icons.more_horiz, size: 20, color: DT.textTertiary),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment, style: DT.body),
          ],
        ],
      ),
    );
  }
}
