import 'package:flutter/services.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The outline of a field: 1 px grey, 2 px brand when focused (C-18f),
/// red on error (C-18e).
InputDecoration _fieldDecoration({
  required bool error,
  required bool readOnly,
  String? hintText,
  double radius = KivetoRadius.m,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  Widget? prefixIcon,
  TextStyle? hintStyle,
}) {
  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
  final idle = error
      ? KivetoColors.danger
      : readOnly
      ? KivetoColors.border
      : KivetoColors.borderStrong;
  return InputDecoration(
    hintText: hintText,
    hintStyle:
        hintStyle ?? KivetoText.input.copyWith(color: KivetoColors.inkMuted),
    filled: true,
    fillColor: readOnly ? KivetoColors.canvas : KivetoColors.surface,
    isDense: false,
    contentPadding: padding,
    constraints: const BoxConstraints(minHeight: 48),
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 48),
    counterText: '',
    enabledBorder: outline(idle),
    disabledBorder: outline(KivetoColors.border),
    focusedBorder: readOnly
        ? outline(idle)
        : outline(error ? KivetoColors.danger : KivetoColors.brand, 2),
    border: outline(idle),
  );
}

/// [field] (a text input) announced by screen readers with [label] and,
/// as its hint, the error or help text shown under it ([note]): the
/// visible label is a separate text, excluded from the semantics tree.
Widget _labelled(String label, Widget field, {String? note}) =>
    Semantics(label: label, hint: note, child: field);

/// The label, field and help/error column of the form fields: gap 6.
class _FieldColumn extends StatelessWidget {
  const new({
    required this.field,
    this.label,
    this.optional = false,
    this.largeLabel = false,
    this.helpText,
    this.errorText,
  });

  final Widget field;
  final String? label;
  final bool optional;
  final bool largeLabel;
  final String? helpText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final note = errorText ?? helpText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          // Read by the input itself (its semantic label): not twice.
          ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                text: label,
                children: [
                  if (optional)
                    TextSpan(
                      text: ' ${AppLocalizations.of(context).commonOptional}',
                      style: KivetoText.optionalSuffix,
                    ),
                ],
              ),
              style: largeLabel
                  ? KivetoText.sectionTitle
                  : KivetoText.labelSmall,
            ),
          ),
          const SizedBox(height: KivetoSpace.s),
        ],
        field,
        if (note != null) ...[
          const SizedBox(height: KivetoSpace.s),
          // Read as the input's hint: not twice.
          ExcludeSemantics(
            child: Text(
              note,
              style: KivetoText.caption.copyWith(
                color: errorText == null
                    ? KivetoColors.inkMuted
                    : KivetoColors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// C-18a: a labelled text field (min-height 48, radius 10) with help text;
/// C-18b when [readOnly]; C-18e with [errorText]; C-18f focused.
/// [KivetoTextField.multiline] is C-18c.
class KivetoTextField extends StatelessWidget {
  const new({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.helpText,
    this.errorText,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  }) : minLines = 1,
       maxLines = 1,
       optional = false,
       largeLabel = false;

  /// C-18c: a textarea of 2–3 lines; a 16/700 label with an optional
  /// "(facultatif)" suffix, or a 13/600 one ([largeLabel] false).
  const new multiline({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.helpText,
    this.errorText,
    this.optional = false,
    this.largeLabel = true,
    this.minLines = 2,
    this.maxLines = 3,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
  }) : readOnly = false,
       keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       autofillHints = null,
       onSubmitted = null;

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helpText;
  final String? errorText;
  final bool readOnly;
  final bool enabled;
  final bool optional;
  final bool largeLabel;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => _FieldColumn(
    label: label,
    optional: optional,
    largeLabel: largeLabel && maxLines > 1,
    helpText: helpText,
    errorText: errorText,
    field: _labelled(
      optional
          ? '$label ${AppLocalizations.of(context).commonOptional}'
          : label,
      note: errorText ?? helpText,
      TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        enabled: enabled,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: KivetoText.input.copyWith(
          color: readOnly ? KivetoColors.inkSecondary : KivetoColors.ink,
        ),
        decoration: _fieldDecoration(
          error: errorText != null,
          readOnly: readOnly,
          hintText: hintText,
        ).copyWith(semanticCounterText: ''),
      ),
    ),
  );
}

/// C-18d: the search field, radius 12, a leading search glyph; its label
/// is for screen readers only.
class KivetoSearchField extends StatelessWidget {
  const new({
    required this.semanticLabel,
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  final String semanticLabel;
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => _labelled(
    semanticLabel,
    TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: KivetoText.input,
      decoration: _fieldDecoration(
        error: false,
        readOnly: false,
        hintText: hintText,
        radius: KivetoRadius.l,
        padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 10),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: KivetoIcon(
              LucideGlyph.search,
              size: 18,
              color: KivetoColors.inkMuted,
            ),
          ),
        ),
      ),
    ),
  );
}

/// C-19: the phone field: a "+33" country button and the number (16 px).
class KivetoPhoneField extends StatelessWidget {
  const new({
    required this.label,
    super.key,
    this.controller,
    this.countryCode = '+33',
    this.onCountryTap,
    this.hintText,
    this.helpText,
    this.errorText,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String countryCode;
  final VoidCallback? onCountryTap;
  final String? hintText;
  final String? helpText;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final input = kivetoTextStyle(16, FontWeight.w400, color: KivetoColors.ink);
    return _FieldColumn(
      label: label,
      helpText: helpText,
      errorText: errorText,
      field: Row(
        children: [
          Semantics(
            button: true,
            label: AppLocalizations.of(context).phoneCountryCode,
            value: countryCode,
            onTap: onCountryTap ?? () {},
            excludeSemantics: true,
            child: TextButton(
              onPressed: onCountryTap ?? () {},
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KivetoRadius.m),
                  ),
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: errorText == null
                        ? KivetoColors.borderStrong
                        : KivetoColors.danger,
                  ),
                ),
                backgroundColor: const WidgetStatePropertyAll(
                  KivetoColors.surface,
                ),
                foregroundColor: const WidgetStatePropertyAll(KivetoColors.ink),
                overlayColor: const WidgetStatePropertyAll(
                  KivetoColors.inkPressed,
                ),
                textStyle: WidgetStatePropertyAll(KivetoText.itemValue),
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(countryCode),
            ),
          ),
          const SizedBox(width: KivetoSpace.sm),
          Expanded(
            child: _labelled(
              label,
              note: errorText ?? helpText,
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                onSubmitted: onSubmitted,
                style: input,
                decoration: _fieldDecoration(
                  error: errorText != null,
                  readOnly: false,
                  hintText: hintText,
                  hintStyle: input.copyWith(color: KivetoColors.inkMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// C-20: a single code field: 18 px digits spaced 0.3 em.
class KivetoCodeField extends StatelessWidget {
  const new({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.helpText,
    this.errorText,
    this.length = 6,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helpText;
  final String? errorText;
  final int length;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final style = kivetoTextStyle(
      18,
      FontWeight.w400,
      letterSpacingEm: 0.3,
      color: KivetoColors.ink,
    );
    return _FieldColumn(
      label: label,
      helpText: helpText,
      errorText: errorText,
      field: _labelled(
        label,
        note: errorText ?? helpText,
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: length,
          style: style,
          decoration: _fieldDecoration(
            error: errorText != null,
            readOnly: false,
            hintText: hintText,
            hintStyle: kivetoTextStyle(
              18,
              FontWeight.w400,
              color: KivetoColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// C-21: the OTP boxes: one hidden text field (digits only, one-time-code
/// autofill) drawing [length] boxes: filled, current (focused) or empty.
class KivetoOtpField extends StatefulWidget {
  const new({
    required this.legend,
    super.key,
    this.helpText,
    this.length = 6,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
  });

  final String legend;
  final String? helpText;
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Called with the code once [length] digits are typed.
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<KivetoOtpField> createState() => _KivetoOtpFieldState();
}

class _KivetoOtpFieldState extends State<KivetoOtpField> {
  TextEditingController? _ownController;
  final _focus = FocusNode();

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    // Redraw the boxes on any change, a programmatic one included
    // (`controller.clear()` after a wrong code).
    _controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(KivetoOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_refresh);
      _controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focus.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _changed(String code) {
    widget.onChanged?.call(code);
    if (code.length == widget.length) widget.onCompleted?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final helpText = widget.helpText;
    final digit = kivetoTextStyle(22, FontWeight.w700, color: KivetoColors.ink);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(widget.legend, style: KivetoText.labelSmall),
        ),
        const SizedBox(height: KivetoSpace.m),
        Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: KivetoSpace.sm),
                  Expanded(
                    child: _OtpBox(
                      digit: i < code.length ? code[i] : null,
                      current: _focus.hasFocus && i == code.length,
                      style: digit,
                    ),
                  ),
                ],
              ],
            ),
            Positioned.fill(
              child: _labelled(
                widget.legend,
                note: widget.helpText,
                TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  onChanged: _changed,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  style: const TextStyle(color: Color(0x00000000)),
                  // Invisible: the boxes draw the code. Every border is
                  // explicit, or the theme's outline would be drawn.
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                    semanticCounterText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
        if (helpText != null) ...[
          const SizedBox(height: KivetoSpace.m),
          ExcludeSemantics(child: Text(helpText, style: KivetoText.caption)),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const new({required this.digit, required this.current, required this.style});

  final String? digit;
  final bool current;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final digit = this.digit;
    return AnimatedContainer(
      duration: KivetoMotion.duration,
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: current ? KivetoColors.brandSubtle : KivetoColors.surface,
        border: Border.all(
          color: digit != null || current
              ? KivetoColors.brand
              : KivetoColors.borderStrong,
          width: current ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(KivetoRadius.m),
      ),
      child: Text(digit ?? '', style: style),
    );
  }
}

/// C-22c (24, radius 6) and the checkbox of C-22a/b (20): brand with a
/// white check when on, a 2 px grey border when off.
class KivetoCheckbox extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    super.key,
    this.size = 24,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final large = size >= 24;
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: AnimatedContainer(
          duration: KivetoMotion.duration,
          curve: KivetoMotion.curve,
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: value ? KivetoColors.brand : KivetoColors.surface,
            border: value
                ? null
                : Border.all(color: KivetoColors.borderStrong, width: 2),
            borderRadius: BorderRadius.circular(large ? KivetoRadius.xs : 3),
          ),
          child: value
              ? KivetoIcon(
                  LucideGlyph.check,
                  size: large ? 14 : 12,
                  strokeWidth: 3,
                  color: KivetoColors.surface,
                )
              : null,
        ),
      ),
    );
  }
}

/// C-22a: a 20 px checkbox and a paragraph with links (the terms).
class KivetoConsentCheckbox extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final List<InlinePart> label;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: KivetoCheckbox(
          value: value,
          onChanged: onChanged,
          size: 20,
          semanticLabel: label.map((part) => part.text).join(),
        ),
      ),
      const SizedBox(width: KivetoSpace.m),
      // A label-for checkbox: a tap on the sentence toggles it; a tap on a
      // link wins the gesture and only follows the link.
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: KivetoInlineLinks(label),
        ),
      ),
    ],
  );
}

/// C-22b: a checkbox tile, min-height 52, radius 12; brand border when on.
class KivetoCheckboxTile extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: Material(
        color: KivetoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KivetoRadius.l),
          side: BorderSide(
            color: value ? KivetoColors.brand : KivetoColors.borderStrong,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onChanged == null ? null : () => onChanged(!value),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  KivetoCheckbox(value: value, onChanged: onChanged, size: 20),
                  const SizedBox(width: KivetoSpace.m),
                  Expanded(child: Text(label, style: KivetoText.label)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// C-23: the switch of the mockup: track 46 × 28, thumb 22, 150 ms;
/// .55 opacity when disabled; a focus ring for the keyboard.
class KivetoSwitch extends StatefulWidget {
  const new({
    required this.value,
    required this.onChanged,
    super.key,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  State<KivetoSwitch> createState() => _KivetoSwitchState();
}

class _KivetoSwitchState extends State<KivetoSwitch> {
  bool _focused = false;

  void _toggle() => widget.onChanged?.call(!widget.value);

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final on = widget.value;
    return Semantics(
      toggled: on,
      enabled: enabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _toggle();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focused
                      ? KivetoColors.brand
                      : const Color(0x00000000),
                  width: 2,
                ),
              ),
              child: AnimatedContainer(
                duration: KivetoMotion.duration,
                curve: KivetoMotion.curve,
                width: 46,
                height: 28,
                decoration: BoxDecoration(
                  color: on ? KivetoColors.brand : KivetoColors.borderStrong,
                  borderRadius: BorderRadius.circular(KivetoRadius.xl),
                ),
                child: AnimatedAlign(
                  duration: KivetoMotion.duration,
                  curve: KivetoMotion.curve,
                  alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: KivetoColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [KivetoShadows.switchThumb],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The radio dot of the radio cards: 22, a 7 px brand ring when selected.
class RadioDot extends StatelessWidget {
  const new({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: KivetoMotion.duration,
    curve: KivetoMotion.curve,
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: KivetoColors.surface,
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? KivetoColors.brand : KivetoColors.borderStrong,
        width: selected ? 7 : 2,
      ),
    ),
  );
}

/// C-24a (with a leading avatar) and C-24b (text): a selectable card,
/// radius 14; 2 px brand border and brand-subtle fill when selected.
class KivetoRadioCard extends StatelessWidget {
  const new({
    required this.title,
    required this.selected,
    required this.onTap,
    super.key,
    this.subtitle,
    this.leading,
    this.pill,
  });

  final String title;
  final String? subtitle;

  /// A 48 avatar (C-24a).
  final Widget? leading;

  /// A status pill next to the title (C-24b).
  final Widget? pill;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final subtitle = this.subtitle;
    final pill = this.pill;
    final avatar = leading != null;
    final border = selected ? 2.0 : 1.0;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: selected ? KivetoColors.brandSubtle : KivetoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KivetoRadius.xl),
          side: BorderSide(
            color: selected ? KivetoColors.brand : KivetoColors.border,
            width: border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: avatar ? 76 : 64),
            child: Padding(
              // The thicker border of the selected state does not move the
              // content.
              padding: EdgeInsets.symmetric(
                vertical: (avatar ? 12 : 10) - (border - 1),
                horizontal: 16 - (border - 1),
              ),
              child: Row(
                children: [
                  if (leading != null) ...[leading, const SizedBox(width: 14)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: KivetoSpace.sm,
                          runSpacing: KivetoSpace.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: avatar
                                  ? KivetoText.sectionTitle
                                  : KivetoText.itemTitle,
                            ),
                            ?pill,
                          ],
                        ),
                        if (subtitle != null) ...[
                          SizedBox(
                            height: avatar
                                ? KivetoSpace.xxs
                                : KivetoSpace.tight,
                          ),
                          Text(subtitle, style: KivetoText.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  RadioDot(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// C-24c: a dashed "add" card: plus 20 and a brand label.
class KivetoAddCard extends StatelessWidget {
  const new({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => KivetoDashedBorder(
    radius: KivetoRadius.xl,
    child: Material(
      color: KivetoColors.surface,
      borderRadius: BorderRadius.circular(KivetoRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const KivetoIcon(LucideGlyph.plus, color: KivetoColors.brand),
                const SizedBox(width: KivetoSpace.ml),
                Expanded(
                  child: Text(
                    label,
                    style: KivetoText.itemValue.copyWith(
                      color: KivetoColors.brand,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// A 1 px dashed rounded border (dash 3, gap 3) around [child]: the add
/// card, the unlisted clinic card, the closed day.
class KivetoDashedBorder extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.color = KivetoColors.borderStrong,
    this.radius = KivetoRadius.l,
    this.dash = 3,
    this.gap = 3,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashedBorderPainter(color, radius, dash, gap),
    child: child,
  );
}

final class _DashedBorderPainter extends CustomPainter {
  new(this.color, this.radius, this.dash, this.gap);

  final Color color;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          Radius.circular(radius),
        ),
      );
    final dashes = Path();
    for (final metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += dash + gap) {
        dashes.addPath(metric.extractPath(start, start + dash), Offset.zero);
      }
    }
    canvas.drawPath(
      dashes,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap;
}
