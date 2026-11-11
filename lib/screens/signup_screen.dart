// Port of src/screens/SignupScreen.tsx.
import 'package:flutter/material.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/input.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

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

  int get _phoneDigits => _phone.replaceAll(RegExp(r'\D'), '').length;

  void _submit() {
    if (_name.trim().length < 2 || _phoneDigits < 9 || _password.length < 6) {
      setState(() => _showErrors = true);
      return;
    }
    Nav.replace('Tabs');
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

    final nameInvalid = _showErrors && _name.trim().length < 2;
    final phoneInvalid = _showErrors && _phoneDigits < 9;
    final pwInvalid = _showErrors && _password.length < 6;

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
                                  onChanged: (v) => setState(() => _phone = v),
                                  error: phoneInvalid,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (phoneInvalid) error(t('phoneError')),
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
