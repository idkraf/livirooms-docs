import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/chat.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/state_views.dart';

/// Navigation arguments for the chat room. Defined here (top-level) because the
/// router references it; keeps chat routing self-contained.
class ChatRoomArgs {
  final int conversationId;
  final String title;
  final String? subtitle;

  const ChatRoomArgs({
    required this.conversationId,
    required this.title,
    this.subtitle,
  });
}

/// Screen 13 — Chat room. Message thread with a bottom composer.
class ChatRoomScreen extends StatefulWidget {
  final ChatRoomArgs args;
  const ChatRoomScreen({super.key, required this.args});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _service = ChatService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  // Newest-first, matching the reversed ListView.
  final List<Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.messages(widget.args.conversationId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(res.data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final msg = await _service.send(widget.args.conversationId, text);
      if (!mounted) return;
      setState(() {
        _messages.insert(0, msg);
        _inputController.clear();
        _sending = false;
      });
      // Keep the latest message in view (list is reversed).
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  void _callPhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Segera hadir')),
    );
  }

  void _callVc() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Segera hadir')),
    );
  }
  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    args.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, color: AppColors.success),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _callPhone, icon: const ImageIcon(AssetImage('assets/images/phone_icon.png'))),
          IconButton(onPressed: _callVc, icon: const ImageIcon(AssetImage('assets/images/video_call_icon.png'))),
        ],
      ),
      body: Column(
        children: [
          if (args.subtitle != null && args.subtitle!.isNotEmpty) _propertyMiniCard(args.subtitle!),
          Expanded(child: _buildThread()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _propertyMiniCard(String name) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.apartment_rounded, color: AppColors.navy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Properti terkait',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThread() {
    if (_loading) return const LoadingView();
    if (_error != null) {
      return ErrorView(message: 'Gagal memuat pesan.\n$_error', onRetry: _load);
    }
    if (_messages.isEmpty) {
      return const EmptyView(
        message: 'Belum ada pesan. Mulai percakapan!',
        imageAsset: 'assets/images/empty_chat.png',
      );
    }
    final currentUserId = context.read<AuthProvider>().user?.id;
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final isMine = currentUserId != null && m.senderId == currentUserId;
        return _bubble(m, isMine);
      },
    );
  }

  Widget _bubble(Message m, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppColors.navy : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                border: isMine ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                m.body ?? '',
                style: TextStyle(
                  color: isMine ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                Formatters.time(m.createdAt),
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.gold,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sending ? null : _send,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.navy,
                          ),
                        )
                      : Image.asset('assets/images/send_chat.png', width: 22, height: 22, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
