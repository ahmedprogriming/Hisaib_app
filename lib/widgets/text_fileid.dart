import 'package:flutter/material.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';


class CustomTextFiled extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obsecureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFiled({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obsecureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextFiled> createState() => _CustomTextFiledState();
}

class _CustomTextFiledState extends State<CustomTextFiled> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obsecureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primary, size: 22)
            : null,
        suffixIcon: widget.obsecureText
            ? IconButton(
                icon: Icon(
                  _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
        ),
      ),
    );
  }
}