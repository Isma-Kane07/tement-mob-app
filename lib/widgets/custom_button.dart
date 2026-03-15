import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Future<void> Function()? onAsyncPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final IconData? prefixIcon; // NOUVEAU : paramètre pour l'icône
  final IconData? suffixIcon; // Optionnel : pour icône de fin

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onAsyncPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.prefixIcon, // NOUVEAU
    this.suffixIcon, // NOUVEAU
  });

  Future<void> _handlePress() async {
    if (onAsyncPressed != null) {
      await onAsyncPressed!();
    } else if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : _handlePress,
        style: OutlinedButton.styleFrom(
          foregroundColor: TementColors.indigoTech,
          side: const BorderSide(color: TementColors.indigoTech),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildChildWithIcons(),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? TementColors.sunsetOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildChildWithIcons(),
    );
  }

  Widget _buildChildWithIcons() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // Si pas d'icônes, retourner le texte simple
    if (prefixIcon == null && suffixIcon == null) {
      return Text(text);
    }

    // Construire un Row avec icônes
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(suffixIcon, size: 20),
        ],
      ],
    );
  }
}
