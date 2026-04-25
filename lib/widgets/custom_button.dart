// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Future<void> Function()? onAsyncPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double height;
  final bool isFullWidth;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onAsyncPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 54,
    this.isFullWidth = true,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading) return;

    // Animation de pression
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _animationController.reverse();

    // Haptic feedback
    if (widget.onPressed != null || widget.onAsyncPressed != null) {
      HapticFeedback.lightImpact();
    }

    // Action
    if (widget.onAsyncPressed != null) {
      await widget.onAsyncPressed!();
    } else if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scaleAnimation.value,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: widget.isFullWidth ? double.infinity : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: (widget.isOutlined
                            ? TementColors.indigoTech
                            : widget.backgroundColor ??
                                TementColors.sunsetOrange)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            splashColor:
                (widget.isOutlined ? TementColors.indigoTech : Colors.white)
                    .withOpacity(0.2),
            highlightColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                border: widget.isOutlined
                    ? Border.all(
                        color: TementColors.indigoTech,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor() {
    if (widget.isOutlined) return Colors.transparent;
    if (widget.isLoading) return TementColors.greySecondary;
    return widget.backgroundColor ?? TementColors.sunsetOrange;
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final textStyle = TextStyle(
      color: widget.isOutlined ? TementColors.indigoTech : Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    if (widget.prefixIcon == null && widget.suffixIcon == null) {
      return Text(widget.text, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          Icon(
            widget.prefixIcon,
            color: widget.isOutlined ? TementColors.indigoTech : Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
        ],
        Text(widget.text, style: textStyle),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(
            widget.suffixIcon,
            color: widget.isOutlined ? TementColors.indigoTech : Colors.white,
            size: 18,
          ),
        ],
      ],
    );
  }
}
