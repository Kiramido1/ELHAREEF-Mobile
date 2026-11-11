// Port of src/screens/LoginScreen.tsx.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/features/auth/domain/entities/credentials.dart';
import 'package:elhareef/features/auth/presentation/controllers/session_controller.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/input.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _phone = '';
  String _password = '';
  bool _showErrors = false;
  late final _signupTap = TapGestureRecognizer()..onTap = () => Nav.navigate('Signup');

  @override
  void dispose() {
    _signupTap.dispose();
    super.dispose();
  }

  bool get _phoneOk => EgyptianPhone.isValid(_phone);
  bool get _pwOk => CredentialRules.isValidPassword(_password);

  /// Social sign-in is not wired to a provider yet.
  void _social() => showToast(context.i18n.t('comingSoon'));

  Future<void> _submit() async {
    if (!_phoneOk || !_pwOk) {
      setState(() => _showErrors = true);
      return;
    }
    final ok = await context.read<SessionController>().signIn(_phone, _password);
    if (!mounted) return;
    if (ok) {
      Nav.resetTo('Tabs');
    } else {
      showToast(context.i18n.t('postFailed'), error: true);
    }
  }

  void _forgot() => Nav.navigate('ForgotPassword');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final dark = context.watch<ThemeController>().dark;
    final phoneInvalid = _showErrors && !_phoneOk;
    final pwInvalid = _showErrors && !_pwOk;

    Widget label(String text, double top) => Padding(
      padding: EdgeInsets.only(top: top),
      child: Txt(text, w: 600, size: 12.5, color: c.ink65),
    );
    Widget error(String text) => Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Txt(text, size: 12, color: Brand.danger),
    );
    Widget divider() => Expanded(child: Container(height: 1, color: c.ink1));

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 18, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Semantics(
                          label: 'ELHAREEF',
                          image: true,
                          child: Image.asset(
                            dark ? 'assets/brand/symbol-reverse.png' : 'assets/brand/symbol.png',
                            width: 76,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Txt(t('welcome'), w: 800, size: 28, letterSpacing: -0.28),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Txt(t('loginSub'), size: 14.5, lineHeight: 22, color: c.ink6),
                    ),
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
                                  placeholder: '10 1234 5678',
                                  keyboardType: TextInputType.phone,
                                  maxLength: 11,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (v) => setState(() => _phone = v),
                                  error: phoneInvalid,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (phoneInvalid) error(t('egPhoneError')),
                    label(t('password'), 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Semantics(
                        label: t('password'),
                        child: PasswordInput(
                          placeholder: t('passwordPh'),
                          onChanged: (v) => setState(() => _password = v),
                          error: pwInvalid,
                          onSubmitted: (_) => _submit(),
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ),
                    if (pwInvalid) error(t('pwError')),
                    // alignSelf: 'flex-end' (physical right, as in RN); the 6px
                    // padding is RN's hitSlop, compensated in the margins.
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(6, 0),
                          child: Press(
                            onTap: _forgot,
                            scale: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Txt(t('forgotPw'), w: 600, size: 12.5, color: Brand.green),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Button(
                        label: t('continue'),
                        onPressed: context.watch<SessionController>().busy ? null : _submit,
                        weight: 600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: Row(
                        children: [
                          divider(),
                          const SizedBox(width: 12),
                          Txt(t('or'), size: 12.5, color: c.ink35),
                          const SizedBox(width: 12),
                          divider(),
                        ],
                      ),
                    ),
                    Button(
                      label: t('google'),
                      onPressed: _social,
                      variant: 'outline',
                      size: 14.5,
                      weight: 600,
                      paddingV: 14,
                    ),
                    const SizedBox(height: 10),
                    Button(
                      label: t('apple'),
                      onPressed: _social,
                      variant: 'outline',
                      size: 14.5,
                      weight: 600,
                      paddingV: 14,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Text.rich(
                        TextSpan(
                          style: Txt.style(context, size: 14, color: c.ink6),
                          children: [
                            TextSpan(text: '${t('newTo')} '),
                            TextSpan(
                              text: t('createAcc'),
                              style: Txt.style(context, w: 600, size: 14, color: Brand.green),
                              recognizer: _signupTap,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
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
