// Port of src/screens/ForgotPasswordScreen.tsx.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/icons.dart';
import 'package:elhareef/core/widgets/input.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

/// 'phone' | 'code' | 'password' | 'done'
typedef _Step = String;

const _codeLength = 4;

class _CodeInput extends StatefulWidget {
  const _CodeInput({required this.code, required this.setCode, required this.error});
  final List<String> code;
  final ValueChanged<List<String>> setCode;
  final bool error;

  @override
  State<_CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<_CodeInput> {
  late final _controllers = List.generate(_codeLength, (i) => TextEditingController(text: widget.code[i]));
  late final _nodes = List.generate(_codeLength, (i) => FocusNode(onKeyEvent: (_, e) => _handleKey(e, i)));
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _codeLength; i++) {
      _nodes[i].addListener(() {
        if (_nodes[i].hasFocus) {
          setState(() => _focusedIndex = i);
          // selectTextOnFocus
          final c = _controllers[i];
          c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length);
        }
      });
    }
  }

  @override
  void didUpdateWidget(_CodeInput old) {
    super.didUpdateWidget(old);
    _sync();
  }

  /// Keep each box showing exactly its controlled digit.
  void _sync() {
    for (var i = 0; i < _codeLength; i++) {
      final v = widget.code[i];
      if (_controllers[i].text != v) {
        _controllers[i].value = TextEditingValue(
          text: v,
          selection: TextSelection.collapsed(offset: v.length),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handleChange(String text, int i) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final next = [...widget.code];
    if (digits.isEmpty) {
      next[i] = '';
      widget.setCode(next);
      return;
    }
    // Support paste of the full code into any box.
    for (var k = 0; k < digits.length && i + k < _codeLength; k++) {
      next[i + k] = digits[k];
    }
    widget.setCode(next);
    final target = math.min(i + digits.length, _codeLength - 1);
    _nodes[target].requestFocus();
  }

  KeyEventResult _handleKey(KeyEvent e, int i) {
    if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace && widget.code[i].isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.card14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _codeLength; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          SizedBox(
            width: 62,
            height: 62,
            child: Semantics(
              label: 'Digit ${i + 1}',
              child: Builder(
                builder: (context) {
                  final bc = widget.error ? Brand.danger : (_focusedIndex == i ? Brand.green : c.ink14);
                  return TextField(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    onChanged: (text) => _handleChange(text, i),
                    keyboardType: TextInputType.number,
                    inputFormatters: [LengthLimitingTextInputFormatter(_codeLength)],
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    expands: true,
                    maxLines: null,
                    cursorColor: Brand.green,
                    style: TextStyle(
                      fontFamily: Fonts.archivo,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: c.ink,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: c.card,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: border(bc),
                      focusedBorder: border(bc),
                      border: border(bc),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  _Step _step = 'phone';
  String _phone = '';
  List<String> _code = List.filled(_codeLength, '');
  String _pw = '';
  String _pw2 = '';
  bool _showErrors = false;
  bool _busy = false;
  int _resendIn = 59;
  Timer? _resendTimer;

  // Inputs keep their values when a step is revisited (RN controlled state).
  final _phoneCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  // Animated.spring(friction: 5, tension: 90) → stiffness 411.2, damping 16.
  late final _pop = AnimationController.unbounded(vsync: this, value: 0);

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pop.dispose();
    _phoneCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  /// Resend countdown while on the code step (RN effect on [step, resendIn]).
  void _syncCountdown() {
    _resendTimer?.cancel();
    _resendTimer = null;
    if (_step != 'code' || _resendIn <= 0) return;
    _resendTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _resendIn -= 1);
      _syncCountdown();
    });
  }

  void _setStep(_Step next) {
    final changed = next != _step;
    setState(() => _step = next);
    _syncCountdown();
    if (changed && next == 'done') {
      _pop.animateWith(
        SpringSimulation(const SpringDescription(mass: 1, stiffness: 411.2, damping: 16), _pop.value, 1, 0),
      );
    }
  }

  int get _phoneDigits => _phone.replaceAll(RegExp(r'\D'), '').length;

  Future<void> _advance(bool valid, _Step next) async {
    if (!valid) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _busy = true);
    await simulateRequest<void>(null, 700);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _showErrors = false;
      if (next == 'code') _resendIn = 59;
    });
    _setStep(next);
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    await simulateRequest<void>(null, 500);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _resendIn = 59;
      _code = List.filled(_codeLength, '');
    });
    _syncCountdown();
  }

  void _primaryAction() {
    if (_step == 'phone') {
      _advance(_phoneDigits >= 9, 'code');
    } else if (_step == 'code') {
      _advance(_code.join().length == _codeLength, 'password');
    } else if (_step == 'password') {
      _advance(_pw.length >= 6 && _pw2 == _pw, 'done');
    } else {
      Nav.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.i18n.t;

    final primaryLabel = _step == 'phone'
        ? t('fpSend')
        : _step == 'code'
        ? t('fpVerify')
        : _step == 'password'
        ? t('fpReset')
        : t('fpBackToLogin');

    if (_step == 'done') {
      return Screen(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pop,
                    builder: (context, child) => Opacity(
                      opacity: _pop.value.clamp(0.0, 1.0),
                      child: Transform.scale(scale: 0.4 + 0.6 * _pop.value, child: child),
                    ),
                    child: Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Brand.green,
                        shape: BoxShape.circle,
                        boxShadow: Shadows.confirmPop,
                      ),
                      child: const CheckIcon(size: 44, color: Brand.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Txt(t('fpDoneTitle'), w: 800, size: 25, letterSpacing: -0.25, center: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Txt(t('fpDoneSub'), size: 14, lineHeight: 22, color: c.ink6, center: true),
                    ),
                  ),
                ],
              ),
            ),
            Button(label: t('fpBackToLogin'), onPressed: Nav.back),
          ],
        ),
      );
    }

    final phoneInvalid = _showErrors && _phoneDigits < 9;
    final codeInvalid = _showErrors && _code.join().length < _codeLength;
    final pwInvalid = _showErrors && _pw.length < 6;
    final pw2Invalid = _showErrors && _pw.length >= 6 && _pw2 != _pw;

    Widget title(String text) =>
        Padding(padding: const EdgeInsets.only(top: 18), child: Txt(text, w: 800, size: 28, letterSpacing: -0.28));
    Widget sub(String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Txt(text, size: 14.5, lineHeight: 22, color: c.ink6),
    );
    Widget label(String text, double top) => Padding(
      padding: EdgeInsets.only(top: top),
      child: Txt(text, w: 600, size: 12.5, color: c.ink65),
    );
    Widget error(String text) => Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Txt(text, size: 12, color: Brand.danger),
    );

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        EhBackButton(
                          onPressed: () => _step == 'phone' ? Nav.back() : _setStep(_step == 'code' ? 'phone' : 'code'),
                        ),
                      ],
                    ),
                    if (_step == 'phone') ...[
                      title(t('fpTitle')),
                      sub(t('fpSub')),
                      label(t('phone'), 28),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: c.card,
                                  border: Border.all(color: c.ink14, width: 1.5),
                                  borderRadius: BorderRadius.circular(Radii.input),
                                ),
                                child: const Txt('+20', w: 600, size: 15),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Semantics(
                                  label: t('phone'),
                                  child: Input(
                                    controller: _phoneCtrl,
                                    placeholder: '10 1234 5678',
                                    keyboardType: TextInputType.phone,
                                    onChanged: (v) => setState(() => _phone = v),
                                    autofocus: true,
                                    error: phoneInvalid,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (phoneInvalid) error(t('phoneError')),
                    ],
                    if (_step == 'code') ...[
                      title(t('fpCodeTitle')),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text.rich(
                          TextSpan(
                            style: Txt.style(context, size: 14.5, lineHeight: 22, color: c.ink6),
                            children: [
                              TextSpan(text: '${t('fpCodeSub')} '),
                              TextSpan(
                                text: '+20 $_phone',
                                style: Txt.style(context, w: 700, size: 14.5, lineHeight: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: _CodeInput(code: _code, setCode: (v) => setState(() => _code = v), error: codeInvalid),
                      ),
                      if (codeInvalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Txt(t('fpCodeError'), size: 12, color: Brand.danger, center: true),
                        ),
                      // marginTop 18; the 8px padding is the link's RN hitSlop
                      // (also applied to the countdown so the swap doesn't shift).
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: _resendIn > 0
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Txt(
                                    '${t('fpResendIn')} 0:${_resendIn.toString().padLeft(2, '0')}',
                                    size: 13,
                                    color: c.ink5,
                                  ),
                                )
                              : Press(
                                  onTap: _resend,
                                  scale: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Txt(t('fpResend'), w: 600, size: 13, color: Brand.green),
                                  ),
                                ),
                        ),
                      ),
                    ],
                    if (_step == 'password') ...[
                      title(t('fpNewTitle')),
                      sub(t('fpNewSub')),
                      label(t('fpNewPw'), 28),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Semantics(
                          label: t('fpNewPw'),
                          child: PasswordInput(
                            key: const ValueKey('pw'),
                            controller: _pwCtrl,
                            placeholder: t('passwordPh'),
                            onChanged: (v) => setState(() => _pw = v),
                            error: pwInvalid,
                          ),
                        ),
                      ),
                      if (pwInvalid) error(t('pwError')),
                      label(t('fpConfirmPw'), 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Semantics(
                          label: t('fpConfirmPw'),
                          child: PasswordInput(
                            key: const ValueKey('pw2'),
                            controller: _pw2Ctrl,
                            placeholder: t('passwordPh'),
                            onChanged: (v) => setState(() => _pw2 = v),
                            error: pw2Invalid,
                          ),
                        ),
                      ),
                      if (pw2Invalid) error(t('fpMatchError')),
                    ],
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: _busy
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Brand.green,
                                borderRadius: BorderRadius.circular(Radii.card14),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Brand.white),
                              ),
                            )
                          : Button(label: primaryLabel, onPressed: _primaryAction, weight: 600),
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
