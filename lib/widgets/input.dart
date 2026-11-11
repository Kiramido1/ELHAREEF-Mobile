// Port of src/components/Input.tsx.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../scope.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import 'icons.dart';
import 'txt.dart';

/// Text input matching the design: 1.5px ink14 border, radius 13, card bg,
/// green border on focus.
class Input extends StatefulWidget {
  const Input({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscure = false,
    this.error = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlign,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.contentPadding,
    this.letterSpacing,
    this.fontSize = 15,
    this.textInputAction,
    this.radius = Radii.input,
  });
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscure;

  /// Danger-colored border (RN `style={{borderColor: brand.danger}}`).
  final bool error;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final double? letterSpacing;
  final double fontSize;
  final TextInputAction? textInputAction;

  /// Border radius (RN `style={{borderRadius}}` override).
  final double radius;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final borderColor = widget.error ? Brand.danger : (_focused ? Brand.green : c.ink14);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(color: color, width: 1.5),
        );
    final base = Txt.style(context, size: widget.fontSize, letterSpacing: widget.letterSpacing);
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscure,
      autocorrect: !widget.obscure,
      enableSuggestions: !widget.obscure,
      maxLength: widget.maxLength,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      textAlign: widget.textAlign ?? TextAlign.start,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      cursorColor: Brand.green,
      style: base.merge(widget.style),
      decoration: InputDecoration(
        isDense: true,
        counterText: '',
        hintText: widget.placeholder,
        hintStyle: base.copyWith(color: c.ink45).merge(widget.style?.copyWith(color: c.ink45)),
        filled: true,
        fillColor: c.card,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        enabledBorder: border(borderColor),
        focusedBorder: border(borderColor),
        border: border(borderColor),
      ),
    );
  }
}

/// Secure input with a show/hide eye toggle at the trailing edge.
class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.error = false,
    this.textInputAction,
  });
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool error;
  final TextInputAction? textInputAction;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        Input(
          controller: widget.controller,
          placeholder: widget.placeholder,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          obscure: _hidden,
          error: widget.error,
          textInputAction: widget.textInputAction,
          contentPadding: const EdgeInsetsDirectional.only(top: 15, bottom: 15, start: 16, end: 48),
        ),
        PositionedDirectional(
          end: 6, // 16 in RN; the 10px padding below is RN's hitSlop
          child: Semantics(
            button: true,
            label: _hidden ? i18n.t('showPw') : i18n.t('hidePw'),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _hidden = !_hidden),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _hidden ? EyeIcon(size: 19, color: c.ink45) : EyeOffIcon(size: 19, color: c.ink45),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
