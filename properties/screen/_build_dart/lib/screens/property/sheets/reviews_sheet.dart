import 'package:flutter/material.dart';

import '../../../models/property.dart';
import '../../../config/theme.dart';
import '../../../utils/detail_icons.dart';
import '../../../utils/fmt.dart';
import '../../../widgets/detail_primitives.dart';
import '../../../widgets/review_summary_card.dart';

/// `ULASAN` — the full review screen
/// (`property_detail_screen_1_bottom_sheet_ulasan.jpeg`).
///
/// A big red score over `/5` and `Dari 2 Ulasan`, the six-way breakdown in two
/// columns, then the review cards with masked author names.
class ReviewsSheet extends StatelessWidget {
  final ReviewSummary summary;
  final List<PropertyReview> reviews;

  const ReviewsSheet({
    super.key,
    required this.summary,
    this.reviews = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required ReviewSummary summary,
    List<PropertyReview> reviews = const [],
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewsSheet(summary: summary, reviews: reviews),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'ULASAN',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(DT.gutter, DT.gutter, DT.gutter, 28),
        children: [
          SectionCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Fmt.score(summary.average),
                      style: const TextStyle(
                        fontSize: 44,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: DT.brand,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 2),
                      child: Text(
                        '/5',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DT.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Dari ${summary.total} Ulasan', style: DT.label),
                if (summary.breakdown.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: DT.divider),
                  const SizedBox(height: 16),
                  _Breakdown(scores: summary.breakdown),
                ],
              ],
            ),
          ),
          for (final review in reviews)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ReviewTile(review: review, showAuthor: true),
            ),
        ],
      ),
    );
  }
}

/// Two-column grid of `icon · label · score` rows.
class _Breakdown extends StatelessWidget {
  final List<ReviewScore> scores;

  const _Breakdown({required this.scores});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < scores.length; start += 2) {
      final left = scores[start];
      final right = start + 1 < scores.length ? scores[start + 1] : null;
      rows.add(Padding(
        padding: EdgeInsets.only(top: start == 0 ? 0 : 14),
        child: Row(
          children: [
            Expanded(child: _ScoreRow(score: left)),
            const SizedBox(width: 12),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : _ScoreRow(score: right),
            ),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _ScoreRow extends StatelessWidget {
  final ReviewScore score;

  const _ScoreRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(DetailIcons.of(score.iconKey), size: 20, color: DT.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            score.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DT.caption.copyWith(fontSize: 13),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          Fmt.score(score.value),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: DT.textPrimary,
          ),
        ),
      ],
    );
  }
}






