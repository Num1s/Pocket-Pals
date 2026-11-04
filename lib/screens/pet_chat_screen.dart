import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_chat_message.dart';
import '../providers/pet_provider.dart';
import '../themes/app_colors.dart';

class PetChatScreen extends ConsumerStatefulWidget {
  const PetChatScreen({super.key});

  @override
  ConsumerState<PetChatScreen> createState() => _PetChatScreenState();
}

class _PetChatScreenState extends ConsumerState<PetChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    await ref.read(petProvider.notifier).sendMessage(text);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'A little chat',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: pet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not open chat: $error')),
        data: (state) => Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFFE79B64),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Offline companion chat · replies are saved on this device',
                      style: TextStyle(
                        color: AppColors.ink.withValues(alpha: .78),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.chatMessages.isEmpty
                  ? _welcome(state.name)
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                      itemCount: state.chatMessages.length,
                      itemBuilder: (context, index) =>
                          _Bubble(message: state.chatMessages[index]),
                    ),
            ),
            if (state.chatMessages.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: ['How are you?', 'Want to play?', 'I missed you!']
                      .map(
                        (text) => ActionChip(
                          label: Text(text),
                          onPressed: () => _send(text),
                        ),
                      )
                      .toList(),
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Say something kind…',
                          filled: true,
                          fillColor: AppColors.cream,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE98E76),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded),
                      tooltip: 'Send message',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcome(String name) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💌', style: TextStyle(fontSize: 62)),
          const SizedBox(height: 10),
          Text(
            'A note for $name',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell me about your day. I’m always happy when we talk.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink.withValues(alpha: .72),
              height: 1.45,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final PetChatMessage message;

  @override
  Widget build(BuildContext context) => Align(
    alignment: message.fromPet ? Alignment.centerLeft : Alignment.centerRight,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 290),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: message.fromPet ? AppColors.cream : const Color(0xFFBDE5C4),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(message.fromPet ? 5 : 18),
          bottomRight: Radius.circular(message.fromPet ? 18 : 5),
        ),
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: AppColors.ink, height: 1.35),
      ),
    ),
  );
}
