import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_client.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/ai_service.dart';

// ── Models ──────────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? conversationId;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.conversationId,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? conversationId,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      error: error,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  AiService get _aiService => ref.read(aiServiceProvider);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text.trim(), isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _aiService.chat(
        text.trim(),
        conversationId: state.conversationId,
      );
      final aiMsg = ChatMessage(text: response.response, isUser: false);
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        conversationId: response.conversationId ?? state.conversationId,
      );
    } catch (e) {
      final errorText = ApiClient.parseError(e);
      state = state.copyWith(
        isLoading: false,
        error: errorText,
      );
    }
  }

  void clearChat() {
    state = const ChatState();
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
