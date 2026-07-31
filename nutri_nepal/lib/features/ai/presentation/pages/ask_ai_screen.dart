import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _apiClient = ApiClient();
  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      role: _ChatRole.assistant,
      text:
          'Namaste. I can help with meals, macros, workouts, and progress. What are we figuring out today?',
    ),
  ].toList();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? prompt]) async {
    final text = (prompt ?? _controller.text).trim();
    if (text.isEmpty || _isLoading) return;

    final history = _messages
        .where((message) => !message.isTyping)
        .map(
          (message) => {
            'role': message.role == _ChatRole.user ? 'user' : 'model',
            'text': message.text,
          },
        )
        .toList();

    setState(() {
      _controller.clear();
      _isLoading = true;
      _messages.add(_ChatMessage(role: _ChatRole.user, text: text));
      _messages.add(const _ChatMessage.typing());
    });
    _scrollToBottom();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.aiChat,
        data: {'message': text, 'history': history},
      );
      final data = response.data is Map ? response.data['data'] : null;
      final reply = data is Map
          ? (data['reply'] ?? 'No answer returned').toString()
          : 'No answer returned';

      if (!mounted) return;
      setState(() {
        _messages.removeWhere((message) => message.isTyping);
        _messages.add(_ChatMessage(role: _ChatRole.assistant, text: reply));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((message) => message.isTyping);
        _messages.add(
          _ChatMessage(role: _ChatRole.assistant, text: _readErrorMessage(e)),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  String _readErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return _friendlyAiError(data['message'].toString());
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'I could not reach the backend. Check that the server is running on ${ApiEndpoints.baseUrl}.';
      }
    }
    return 'I could not reach the AI service right now. Check your backend, Gemini API key, and internet connection.';
  }

  String _friendlyAiError(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('quota') ||
        lowerMessage.contains('resource_exhausted') ||
        lowerMessage.contains('rate-limits') ||
        lowerMessage.contains('too many requests')) {
      return 'The AI chat limit has been reached for now. Please try again later, or update the Gemini API billing/quota settings on the backend.';
    }
    if (lowerMessage.contains('generativelanguage.googleapis.com') ||
        lowerMessage.contains('googleapis.com')) {
      return 'The AI service is unavailable right now. Please try again in a moment.';
    }
    return message;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primaryOrange, size: 22),
            SizedBox(width: 10),
            Text(
              'NutriNepal AI',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildPromptStrip();
                return _buildBubble(_messages[index - 1]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildPromptStrip() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _promptChip('Plan my dinner'),
          _promptChip('Explain my macros'),
          _promptChip('Beginner workout today'),
        ],
      ),
    );
  }

  Widget _promptChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(
        color: AppColors.primaryOrange,
        fontFamily: 'OpenSans',
      ),
      onPressed: _isLoading ? null : () => _send(text),
    );
  }

  Widget _buildBubble(_ChatMessage message) {
    final isUser = message.role == _ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          // Leave room for the list's horizontal padding and bubble edges.
          maxWidth: MediaQuery.of(context).size.width - 64,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryOrange : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: message.isTyping
            ? const _TypingDots()
            : Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.white,
                  height: 1.4,
                  fontFamily: 'OpenSans',
                  fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 20, 12),
        decoration: const BoxDecoration(
          color: Color(0xFF15110F),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                enabled: !_isLoading,
                style: const TextStyle(color: AppColors.white),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _isLoading ? null : () => _send(),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                disabledBackgroundColor: AppColors.surfaceSoft,
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ChatRole { user, assistant }

class _ChatMessage {
  final _ChatRole role;
  final String text;
  final bool isTyping;

  const _ChatMessage({required this.role, required this.text})
    : isTyping = false;

  const _ChatMessage.typing()
    : role = _ChatRole.assistant,
      text = '',
      isTyping = true;
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Thinking...',
      style: TextStyle(color: AppColors.grey, fontFamily: 'OpenSans'),
    );
  }
}
