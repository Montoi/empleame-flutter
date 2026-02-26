import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// ── Mock seed data ────────────────────────────────────────────────────────────

final _seedMessages = [
  ChatMessage(
    id: '1',
    text: 'Hola! Tengo una pregunta sobre el servicio.',
    isUser: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  ChatMessage(
    id: '2',
    text: '¡Hola! Claro, ¿en qué te puedo ayudar?',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
  ),
  ChatMessage(
    id: '3',
    text: '¿A qué hora estarás disponible mañana?',
    isUser: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
  ),
  ChatMessage(
    id: '4',
    text: 'Puedo ir a las 10 AM o a las 2 PM. ¿Cuál te viene mejor?',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  ChatMessage(
    id: '5',
    text: 'Perfecto, a las 10 AM me viene bien. ¡Gracias!',
    isUser: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  final String providerName;
  final String providerImage;

  const ChatScreen({
    super.key,
    required this.providerName,
    required this.providerImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Newest message at index 0 (matches reverse:true ListView)
  final List<ChatMessage> _messages = List.from(_seedMessages.reversed);

  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  final Set<String> _shownTimestamps = {};

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      // Insert at front — displayed at bottom via reverse:true
      _messages.insert(0, msg);
      _inputController.clear();
    });
  }

  void _toggleTimestamp(String id) {
    setState(() {
      if (_shownTimestamps.contains(id)) {
        _shownTimestamps.remove(id);
      } else {
        _shownTimestamps.add(id);
      }
    });
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final hm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (msgDay == today) return hm;
    if (msgDay == today.subtract(const Duration(days: 1))) return 'Ayer $hm';
    return '${dt.day}/${dt.month} $hm';
  }

  @override
  Widget build(BuildContext context) {
    // resizeToAvoidBottomInset:true (the default) handles the keyboard natively
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _ChatHeader(
            providerName: widget.providerName,
            providerImage: widget.providerImage,
          ),
          Expanded(
            child: ListView.builder(
              reverse: true, // newest at the bottom
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (ctx, index) {
                final msg = _messages[index];
                final showTime = _shownTimestamps.contains(msg.id);
                return _MessageBubble(
                  message: msg,
                  showTimestamp: showTime,
                  formattedTime: _formatTime(msg.timestamp),
                  onTap: () => _toggleTimestamp(msg.id),
                );
              },
            ),
          ),
          _InputBar(
            controller: _inputController,
            focusNode: _focusNode,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final String providerName;
  final String providerImage;

  const _ChatHeader({required this.providerName, required this.providerImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      // SafeArea only on top to avoid status bar overlap
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: providerImage,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (ctx, url, err) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + online indicator
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'En línea',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More options
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final String formattedTime;
  final VoidCallback onTap;

  static const _primary = Color(0xFF7210FF);
  static const _surfaceGrey = Color(0xFFF1F5F9);

  const _MessageBubble({
    required this.message,
    required this.showTimestamp,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isUser ? _primary : _surfaceGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isUser ? Colors.white : const Color(0xFF0F172A),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          // Timestamp — shown on tap
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: showTimestamp
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  static const _primary = Color(0xFF7210FF);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button (placeholder for future image picking)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Icon(
              Icons.add_circle_outline,
              color: Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLines: null,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  isDense: true,
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: _hasText ? widget.onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hasText ? _primary : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: _hasText ? Colors.white : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
