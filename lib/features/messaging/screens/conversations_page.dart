import 'package:flutter/material.dart';
import 'package:flutter_app/features/messaging/mixins/conversation_list_state_mixin.dart';
import 'package:flutter_app/features/messaging/widgets/conversation_tile.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Conversations list screen (inbox).
///
/// Displays all conversations for the current user, ordered by most recent.
/// Accessible from Profile → Messages.
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage>
    with ConversationListStateMixin {
  @override
  void initState() {
    super.initState();
    initializeConversations();
  }

  @override
  void dispose() {
    disposeConversations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoadingConversations) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (conversationsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48,
                  color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                conversationsError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => initializeConversations(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppTheme.mutedForeground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedForeground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start chatting from a listing!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.mutedForeground.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshConversations,
      color: AppTheme.primaryColor,
      child: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 70,
          endIndent: 16,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.directChat,
                arguments: conversation,
              );
            },
          );
        },
      ),
    );
  }
}
