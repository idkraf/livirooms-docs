import 'package:flutter/material.dart';

import '../models/property_detail.dart';
import '../theme/detail_tokens.dart';
import '../widgets/detail_primitives.dart';

/// `Q&A` — the discussion screen behind the `Diskusi (0)` action card
/// (`property_detail_screen_1_bottom_sheet_diskusi.jpeg`).
///
/// Empty state: a centred `Belum ada pertanyaan tentang properti ini.` with
/// `AJUKAN PERTANYAAN` pinned at the bottom.
class QnaSheet extends StatelessWidget {
  final List<PropertyQuestion> questions;
  final VoidCallback? onAsk;

  const QnaSheet({super.key, this.questions = const [], this.onAsk});

  /// Pushed as a full-screen route, not a modal sheet — the mockup shows a
  /// red AppBar with an ✕, i.e. a page.
  static Future<void> show(
    BuildContext context, {
    List<PropertyQuestion> questions = const [],
    VoidCallback? onAsk,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QnaSheet(questions: questions, onAsk: onAsk),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'Q&A',
      background: DT.surface,
      bottom: BrandButton(label: 'AJUKAN PERTANYAAN', onPressed: onAsk),
      body: questions.isEmpty ? _empty() : _list(),
    );
  }

  Widget _empty() => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Belum ada pertanyaan tentang properti ini.',
            textAlign: TextAlign.center,
            style: DT.bodyMuted,
          ),
        ),
      );

  Widget _list() => ListView.separated(
        padding: const EdgeInsets.all(DT.gutter),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final q = questions[i];
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
                Text(q.question, style: DT.bodyStrong),
                if (q.answer != null && q.answer!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(q.answer!, style: DT.bodyMuted),
                ],
              ],
            ),
          );
        },
      );
}
