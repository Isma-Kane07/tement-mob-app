// lib/widgets/custom_input.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';

class CustomInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final String? hintText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.hintText,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _isFocused = false;
  bool _isValid = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label animé
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(
            left: _isFocused ? 8 : 0,
            bottom: 4,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isFocused
                  ? TementColors.indigoTech
                  : TementColors.greySecondary,
              fontSize: 12,
              fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),

        // Champ de saisie
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: TementColors.indigoTech.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            onChanged: (value) {
              setState(() {
                _isValid = widget.validator?.call(value) == null;
              });
              widget.onChanged?.call(value);
            },
            textInputAction: widget.textInputAction,
            autofocus: widget.autofocus,
            style: const TextStyle(
              fontSize: 16,
              color: TementColors.indigoTech,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? widget.label,
              hintStyle: TextStyle(
                color: TementColors.greySecondary.withOpacity(0.5),
                fontSize: 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? TementColors.indigoTech
                          : TementColors.greySecondary,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.enabled
                  ? (_isFocused
                      ? TementColors.white
                      : TementColors.lightBackground)
                  : TementColors.greySecondary.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TementColors.greySecondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: TementColors.indigoTech,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                _isValid = error == null;
              });
              return error;
            },
          ),
        ),
      ],
    );
  }
}
