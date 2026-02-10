import 'package:flutter/material.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

/// An info row widget that matches the Rise design system
class RiseInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final CrossAxisAlignment alignment;

  const RiseInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: textTheme.bodyMedium?.copyWith(
                color: colors?.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colors?.onSurface,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
