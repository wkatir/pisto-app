import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../config/api_client.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/ai_service.dart';

part 'ai_provider.g.dart';

// ── Queries ──────────────────────────────────────────────────────────────────

@riverpod
Future<ForecastResult> forecastResult(Ref ref) {
  return ref.watch(aiServiceProvider).getForecast();
}

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
    await _request(text.trim());
  }

  /// Retries the user's last question without duplicating its bubble.
  Future<void> retryLast() async {
    final lastUser = state.messages.lastWhere((m) => m.isUser);
    state = state.copyWith(isLoading: true, error: null);
    await _request(lastUser.text);
  }

  Future<void> _request(String text) async {
    try {
      final response = await _aiService.chat(
        text,
        conversationId: state.conversationId,
      );
      final aiMsg = ChatMessage(text: response.response, isUser: false);
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        conversationId: response.conversationId ?? state.conversationId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiClient.parseError(e),
      );
    }
  }

  /// The error is ephemeral: it must not survive a fresh visit to the chat.
  void clearError() {
    if (state.error != null) state = state.copyWith(error: null);
  }

  void clearChat() {
    state = const ChatState();
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
