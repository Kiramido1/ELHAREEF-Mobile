// Port of src/screens/SignupScreen.tsx.
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _name = '';
  String _phone = '';
  String _password = '';
  int _pos = 2;
  int _skill = 1;
  bool _showErrors = false;

  bool get _phoneOk => EgyptianPhone.isValid(_phone);
  bool get _pwOk => CredentialRules.isValidPassword(_password);

  bool get _nameOk => CredentialRules.isValidName(_name);

  Future<void> _submit() async {
    if (!_nameOk || !_phoneOk || !_pwOk) {
      setState(() => _showErrors = true);
      return;
    }
    final ok = await context.read<SessionController>().signUp(_name, _phone, _password);
    if (!mounted) return;
    if (ok) {
      Nav.resetTo('Tabs');
    } else {
      showToast(context.i18n.t('postFailed'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final pick = i18n.pick;

    final positions = [
      pick('Goalkeeper', 'حارس'),
      pick('Defender', 'مدافع'),
      pick('Midfielder', 'وسط'),
      pick('Winger', 'جناح'),
      pick('Striker', 'مهاجم'),
    ];

    final nameInvalid = _showErrors && !_nameOk;
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

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(children: [EhBackButton(onPressed: Nav.back)]),
                    ),
                    Txt(t('createAcc'), w: 800, size: 28, letterSpacing: -0.28),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Txt(t('signupSub'), size: 14.5, color: c.ink6),
                    ),
                    label(t('fullName'), 26),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Semantics(
                        label: t('fullName'),
                        child: Input(
                          placeholder: 'Youssef Adel',
                          onChanged: (v) => setState(() => _name = v),
                          error: nameInvalid,
                        ),
                      ),
                    ),
                    if (nameInvalid) error(pick('Please enter your full name.', 'من فضلك اكتب اسمك بالكامل.')),
                    label(t('phone'), 16),
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
                        ),
                      ),
                    ),
                    if (pwInvalid) error(t('pwError')),
                    label(t('prefPos'), 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < positions.length; i++)
                            EhChip(
                              key: ValueKey(positions[i]),
                              label: positions[i],
                              selected: _pos == i,
                              onPressed: () => setState(() => _pos = i),
                              paddingV: 9,
                              paddingH: 15,
                              size: 13.5,
                            ),
                        ],
                      ),
                    ),
                    label(t('skill'), 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Segmented(
                        options: [pick('Beginner', 'مبتدئ'), pick('Intermediate', 'متوسط'), pick('Advanced', 'متقدم')],
                        selectedIndex: _skill,
                        onSelect: (i) => setState(() => _skill = i),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Button(label: t('createAcc'), onPressed: _submit, weight: 600),
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
