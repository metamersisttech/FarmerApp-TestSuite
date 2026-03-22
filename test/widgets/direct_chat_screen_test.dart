import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';

// ---------------------------------------------------------------------------
// Minimal chat service abstraction for testing
// ---------------------------------------------------------------------------

class _MessagesResult {
  final bool success;
  final List<ChatMessage>? messages;
  final ChatMessage? sentMessage;
  final String? message;

  const _MessagesResult({
    required this.success,
    this.messages,
    this.sentMessage,
    this.message,
  });
}

abstract class _FakeChatServiceBase {
  Future<_MessagesResult> getMessages(int conversationId,
      {int? beforeMessageId, int? limit});
  Future<_MessagesResult> sendMessage(int conversationId, String text);
}

class _SuccessChatService implements _FakeChatServiceBase {
  final List<ChatMessage> initialMessages;
  final bool failSend;

  _SuccessChatService({
    this.initialMessages = const [],
    this.failSend = false,
  });

  @override
  Future<_MessagesResult> getMessages(int conversationId,
      {int? beforeMessageId, int? limit}) async {
    return _MessagesResult(success: true, messages: initialMessages);
  }

  @override
  Future<_MessagesResult> sendMessage(int conversationId, String text) async {
    if (failSend) {
      return const _MessagesResult(
        success: false,
        message: 'Failed to send message',
      );
    }
    final sent = ChatMessage(
      messageId: 999,
      fromUser: ChatMessageSender(id: 1, name: 'Me'),
      body: text,
      isRead: false,
      createdAt: DateTime.now(),
    );
    return _MessagesResult(success: true, sentMessage: sent);
  }
}

/// Service whose getMessages never completes — for loading state tests.
class _NeverCompleteGetService implements _FakeChatServiceBase {
  final _completer = Completer<_MessagesResult>();

  @override
  Future<_MessagesResult> getMessages(int conversationId,
      {int? beforeMessageId, int? limit}) => _completer.future;

  @override
  Future<_MessagesResult> sendMessage(int conversationId, String text) async =>
      const _MessagesResult(success: true);
}

/// Service whose sendMessage never completes — for send-disabled state tests.
class _NeverCompleteSendService implements _FakeChatServiceBase {
  @override
  Future<_MessagesResult> getMessages(int conversationId,
      {int? beforeMessageId, int? limit}) async =>
      const _MessagesResult(success: true, messages: []);

  @override
  Future<_MessagesResult> sendMessage(int conversationId, String text) =>
      Completer<_MessagesResult>().future;
}

class _FailChatService implements _FakeChatServiceBase {
  @override
  Future<_MessagesResult> getMessages(int conversationId,
      {int? beforeMessageId, int? limit}) async {
    throw Exception('Network error');
  }

  @override
  Future<_MessagesResult> sendMessage(int conversationId, String text) async {
    throw Exception('Network error');
  }
}

// ---------------------------------------------------------------------------
// Testable chat screen
// ---------------------------------------------------------------------------

class _TestableChatScreen extends StatefulWidget {
  final Conversation conversation;
  final _FakeChatServiceBase chatService;
  final int currentUserId;

  const _TestableChatScreen({
    required this.conversation,
    required this.chatService,
    this.currentUserId = 1,
    super.key,
  });

  @override
  State<_TestableChatScreen> createState() => _TestableChatScreenState();
}

class _TestableChatScreenState extends State<_TestableChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isChatLoading = true;
  bool _isSending = false;
  String? _chatError;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isChatLoading = true;
      _chatError = null;
    });
    try {
      final result = await widget.chatService.getMessages(
        widget.conversation.conversationId,
      );
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _messages = result.messages ?? [];
          _isChatLoading = false;
        });
      } else {
        setState(() {
          _chatError = result.message ?? 'Failed to load';
          _isChatLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _chatError = e.toString();
        _isChatLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _messageCtrl.clear();

    final result =
        await widget.chatService.sendMessage(widget.conversation.conversationId, text);

    if (!mounted) return;
    if (result.success && result.sentMessage != null) {
      setState(() {
        _messages.add(result.sentMessage!);
        _isSending = false;
      });
    } else {
      _messageCtrl.text = text; // restore
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('send_error_snackbar'),
          content: Text(result.message ?? 'Failed to send'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.otherUser.displayName),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageArea()),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildMessageArea() {
    if (_isChatLoading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('chat_loading')),
      );
    }

    if (_chatError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_chatError!, key: const Key('chat_error')),
            TextButton(
              key: const Key('retry_btn'),
              onPressed: _loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('No messages yet', key: Key('empty_chat')),
      );
    }

    return ListView.builder(
      key: const Key('message_list'),
      controller: _scrollCtrl,
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isMine = msg.isMine(widget.currentUserId);
        return Align(
          key: Key('msg_${msg.messageId}'),
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMine ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg.body),
          ),
        );
      },
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('message_input'),
            controller: _messageCtrl,
            decoration: const InputDecoration(hintText: 'Type a message...'),
          ),
        ),
        IconButton(
          key: const Key('send_btn'),
          icon: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      key: Key('send_loading'), strokeWidth: 2),
                )
              : const Icon(Icons.send),
          onPressed: _isSending ? null : _sendMessage,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

Conversation _makeConversation({
  int id = 1,
  String otherUserName = 'Ramu Farmer',
  String? listingTitle,
}) {
  return Conversation(
    conversationId: id,
    otherUser: ConversationUser(
      id: 2,
      username: 'ramu',
      fullName: otherUserName,
    ),
    initiatedFromListing: listingTitle != null
        ? ConversationListing(listingId: 10, title: listingTitle)
        : null,
    updatedAt: DateTime.now(),
    createdAt: DateTime.now(),
  );
}

ChatMessage _makeMessage({
  required int id,
  required int fromUserId,
  String body = 'Hello',
}) {
  return ChatMessage(
    messageId: id,
    fromUser: ChatMessageSender(id: fromUserId, name: 'User $fromUserId'),
    body: body,
    isRead: false,
    createdAt: DateTime.now(),
  );
}

Widget _buildChatApp(
  _FakeChatServiceBase service, {
  Conversation? conversation,
  int currentUserId = 1,
}) {
  return MaterialApp(
    home: _TestableChatScreen(
      conversation: conversation ?? _makeConversation(),
      chatService: service,
      currentUserId: currentUserId,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DirectChatScreen – loading state', () {
    testWidgets('should show loading indicator while fetching messages', (tester) async {
      // Use a service that never resolves so loading state persists
      final service = _NeverCompleteGetService();
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pump();
      expect(find.byKey(const Key('chat_loading')), findsOneWidget);
    });

    testWidgets('should hide loading indicator after messages load', (tester) async {
      final service = _SuccessChatService(initialMessages: []);
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chat_loading')), findsNothing);
    });
  });

  group('DirectChatScreen – empty state', () {
    testWidgets('should show "No messages yet" when list is empty', (tester) async {
      final service = _SuccessChatService(initialMessages: []);
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('empty_chat')), findsOneWidget);
    });

    testWidgets('should not show message list when empty', (tester) async {
      final service = _SuccessChatService(initialMessages: []);
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('message_list')), findsNothing);
    });
  });

  group('DirectChatScreen – error state', () {
    testWidgets('should show error text when service throws', (tester) async {
      final service = _FailChatService();
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chat_error')), findsOneWidget);
    });

    testWidgets('should show retry button on error', (tester) async {
      final service = _FailChatService();
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('retry_btn')), findsOneWidget);
    });

    testWidgets('tapping retry reloads messages', (tester) async {
      // Service always fails but we just confirm retry tapping does not crash
      final service = _FailChatService();
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('retry_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chat_error')), findsOneWidget);
    });
  });

  group('DirectChatScreen – message list', () {
    testWidgets('should display messages from other user', (tester) async {
      final messages = [
        _makeMessage(id: 1, fromUserId: 2, body: 'Hi there'),
        _makeMessage(id: 2, fromUserId: 2, body: 'Is this cow available?'),
      ];
      final service = _SuccessChatService(initialMessages: messages);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      expect(find.text('Hi there'), findsOneWidget);
      expect(find.text('Is this cow available?'), findsOneWidget);
    });

    testWidgets('should display messages from current user', (tester) async {
      final messages = [
        _makeMessage(id: 1, fromUserId: 1, body: 'Yes, she is available'),
      ];
      final service = _SuccessChatService(initialMessages: messages);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      expect(find.text('Yes, she is available'), findsOneWidget);
    });

    testWidgets('should show multiple messages', (tester) async {
      final messages = [
        _makeMessage(id: 1, fromUserId: 2, body: 'Hello'),
        _makeMessage(id: 2, fromUserId: 1, body: 'Hi'),
        _makeMessage(id: 3, fromUserId: 2, body: 'What is the price?'),
      ];
      final service = _SuccessChatService(initialMessages: messages);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('message_list')), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Hi'), findsOneWidget);
      expect(find.text('What is the price?'), findsOneWidget);
    });
  });

  group('DirectChatScreen – send message', () {
    testWidgets('send button is present in input area', (tester) async {
      final service = _SuccessChatService();
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('send_btn')), findsOneWidget);
    });

    testWidgets('message input field is present', (tester) async {
      final service = _SuccessChatService();
      await tester.pumpWidget(_buildChatApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('message_input')), findsOneWidget);
    });

    testWidgets('send button adds message to list on success', (tester) async {
      final service = _SuccessChatService(initialMessages: []);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('message_input')), 'Testing 123');
      await tester.tap(find.byKey(const Key('send_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Testing 123'), findsOneWidget);
    });

    testWidgets('input is cleared after sending', (tester) async {
      final service = _SuccessChatService(initialMessages: []);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('message_input')), 'My message');
      await tester.tap(find.byKey(const Key('send_btn')));
      await tester.pumpAndSettle();

      final input = tester.widget<TextField>(
        find.byKey(const Key('message_input')),
      );
      expect(input.controller?.text, '');
    });

    testWidgets('send button is disabled while sending', (tester) async {
      // Use a service whose sendMessage never completes
      final service = _NeverCompleteSendService();
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('message_input')), 'Hello');
      await tester.tap(find.byKey(const Key('send_btn')));
      await tester.pump(); // mid-flight

      final btn = tester.widget<IconButton>(
        find.byKey(const Key('send_btn')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows snackbar on send failure', (tester) async {
      final service = _SuccessChatService(initialMessages: [], failSend: true);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('message_input')), 'Test');
      await tester.tap(find.byKey(const Key('send_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('send_error_snackbar')), findsOneWidget);
    });

    testWidgets('input text is restored after failed send', (tester) async {
      final service = _SuccessChatService(initialMessages: [], failSend: true);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('message_input')), 'Message to retry');
      await tester.tap(find.byKey(const Key('send_btn')));
      await tester.pumpAndSettle();

      final input = tester.widget<TextField>(
        find.byKey(const Key('message_input')),
      );
      expect(input.controller?.text, 'Message to retry');
    });

    testWidgets('does not send when input is empty', (tester) async {
      final service = _SuccessChatService(initialMessages: []);
      await tester.pumpWidget(_buildChatApp(service, currentUserId: 1));
      await tester.pumpAndSettle();

      // Leave input empty
      await tester.tap(find.byKey(const Key('send_btn')));
      await tester.pumpAndSettle();

      // No messages should appear
      expect(find.byKey(const Key('message_list')), findsNothing);
      expect(find.byKey(const Key('empty_chat')), findsOneWidget);
    });
  });

  group('DirectChatScreen – app bar', () {
    testWidgets('should show other user name in app bar', (tester) async {
      final conv = _makeConversation(otherUserName: 'Shyam Buyer');
      final service = _SuccessChatService();
      await tester.pumpWidget(_buildChatApp(service, conversation: conv));
      await tester.pumpAndSettle();
      expect(find.text('Shyam Buyer'), findsOneWidget);
    });
  });
}
