import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.focusNode,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final String? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveDesign(
      defaultBuilder: (context, screen) {
        return _buildMaterialField(context);
      },
      material: (context, screen) {
        return _buildMaterialField(context);
      },
      cupertino: (context, screen) {
        return _buildCupertinoField(context);
      },
    );
  }

  Widget _buildMaterialField(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      focusNode: focusNode,
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        prefixIcon: _buildPrefixIcon(),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildCupertinoField(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: hint ?? label,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      focusNode: focusNode,
      style: AppTypography.body,
      prefix: _buildCupertinoPrefixIcon(),
      suffix: suffixIcon,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
        ),
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (prefixIcon == null) return null;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: CommonSvgWidget(
        svgName: prefixIcon!,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget? _buildCupertinoPrefixIcon() {
    if (prefixIcon == null) return null;

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: CommonSvgWidget(
        svgName: prefixIcon!,
        color: AppColors.textMuted,
      ),
    );
  }
}
