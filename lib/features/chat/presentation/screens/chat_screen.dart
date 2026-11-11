// Port of src/screens/ChatScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/chat/presentation/controllers/chat_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/features/chat/domain/entities/chat_message.dart';
import 'package:elhareef/core/widgets/anim.dart';
import 'package:elhareef/core/widgets/icons.dart';
import 'package:elhareef/core/widgets/input.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.msg, required this.maxWidth});
  final ChatMessage msg;

  /// RN `maxWidth: '82%'` of the list content width.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final text = msg.textAr != null ? i18n.pick(msg.text, msg.textAr!) : msg.text;

    if (msg.kind == MessageKind.system) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 13),
          decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.pill)),
          child: Txt(text, w: 600, size: 11.5, color: c.ink5),
        ),
      );
    }

    if (msg.kind == MessageKind.mine) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
            decoration: BoxDecoration(
              color: c.navyBtn,
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(16),
                topEnd: Radius.circular(16),
                bottomStart: Radius.circular(16),
                bottomEnd: Radius.circular(5),
              ),
            ),
            child: Txt(text, size: 13.5, lineHeight: 19.5, color: Brand.cloud),
          ),
        ),
      );
    }

    final who = msg.whoAr != null ? i18n.pick(msg.who ?? '', msg.whoAr!) : (msg.who ?? '');
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Avatar(initial: msg.initial ?? '?', palette: msg.avatar ?? 'tint', size: 28, fontSize: 10.5),
            const SizedBox(width: 8),
            Flexible(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 4, right: 4),
                      child: Txt(who, w: 700, size: 10.5, color: c.ink5),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                      decoration: BoxDecoration(
                        color: c.card,
                        border: Border.all(color: c.ink08, width: 1),
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(16),
                          topEnd: Radius.circular(16),
                          bottomStart: Radius.circular(5),
                          bottomEnd: Radius.circular(16),
                        ),
                      ),
                      child: Txt(text, size: 13.5, lineHeight: 19.5),
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
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _draft = TextEditingController();
  final _list = ScrollController();
  int? _lastCount;

  @override
  void dispose() {
    _draft.dispose();
    _list.dispose();
    super.dispose();
  }

  void _doSend(String text) {
    if (text.trim().isEmpty) return;
    _draft.clear();
    final i18n = context.read<I18n>();
    context.read<ChatController>().send(text).catchError((Object _) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(i18n.pick('Message not sent', 'الرسالة متبعتتش')),
          content: Text(i18n.pick('Check your connection and try again.', 'اتأكد من النت وحاول تاني.')),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    });
  }

  /// RN `onContentSizeChange` → scrollToEnd({animated: true}).
  void _scrollToEndOnChange(int count) {
    if (_lastCount == count) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_list.hasClients) return;
      _list.animateTo(
        _list.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = context.watch<ThemeController>().dark;
    final i18n = context.i18n;
    final messages = context.watch<ChatController>().messages;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    _scrollToEndOnChange(messages.length);

    final quicks = <({String label, String? text})>[
      (label: i18n.t('onWay'), text: null),
      (label: i18n.t('arrived'), text: null),
      (
        label: i18n.t('sharePin'),
        text: i18n.pick(
          'Pitch pin: Dream Sports Arena, Gate 2 — maps.app/eh84213',
          'لوكيشن الملعب: دريم سبورتس أرينا، بوابة 2 — maps.app/eh84213',
        ),
      ),
    ];

    final avatarBorder = dark ? c.bg : Brand.cloud;
    Widget ringed(Widget avatar) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: avatarBorder, width: 2),
          ),
          child: avatar,
        );

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.ink08, width: 1))),
              child: Row(
                children: [
                  EhBackButton(onPressed: Nav.back, size: 36),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt(i18n.t('chatTitle'), w: 800, size: 14.5, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Txt(i18n.t('chatSub'), w: 600, size: 11.5, color: Brand.green),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  // RN: plain 'row' with marginLeft -8 overlaps — physically LTR in both languages.
                  SizedBox(
                    width: 34 + 26.0 * 2,
                    height: 34,
                    child: Stack(
                      textDirection: TextDirection.ltr,
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: ringed(const Avatar(initial: 'A', palette: 'navy', size: 30, fontSize: 11)),
                        ),
                        Positioned(
                          left: 26,
                          top: 0,
                          child: ringed(const Avatar(initial: 'O', palette: 'tint', size: 30, fontSize: 11)),
                        ),
                        Positioned(
                          left: 52,
                          top: 0,
                          child: ringed(const Avatar(initial: '+5', palette: 'green', size: 30, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final maxW = (box.maxWidth - 32) * 0.82;
                  return ListView.separated(
                    controller: _list,
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => MsgIn(
                      key: ValueKey(messages[i].id),
                      child: _MessageRow(msg: messages[i], maxWidth: maxW),
                    ),
                  );
                },
              ),
            ),

            // Quick replies
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 4),
              child: Row(
                children: [
                  for (var i = 0; i < quicks.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Press(
                      onTap: () => _doSend(quicks[i].text ?? quicks[i].label),
                      scale: 0.95,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: c.card,
                          border: Border.all(color: c.ink12, width: 1.5),
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Txt(quicks[i].label, w: 600, size: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Composer
            Container(
              color: c.bg,
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: math.max(bottomInset, 14) + 12),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: i18n.t('msgPh'),
                      child: Input(
                        controller: _draft,
                        placeholder: i18n.t('msgPh'),
                        onSubmitted: _doSend,
                        textInputAction: TextInputAction.send,
                        radius: Radii.pill,
                        fontSize: 14,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Press(
                    onTap: () => _doSend(_draft.text),
                    scale: 0.92,
                    label: i18n.pick('Send', 'إرسال'),
                    child: Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Brand.green, shape: BoxShape.circle),
                      child: const SendIcon(size: 19, color: Brand.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
