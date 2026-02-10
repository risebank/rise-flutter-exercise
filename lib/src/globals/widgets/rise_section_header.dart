import 'package:flutter/material.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

/// A section header widget that matches the Rise design system
class RiseSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const RiseSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: colors?.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
