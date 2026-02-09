import 'package:flutter/material.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_app_colors.dart';

/// A status badge widget that matches the Rise design system
class RiseStatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const RiseStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    final statusConfig = _getStatusConfig(status, colors);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: statusConfig.textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status, RiseAppColors? colors) {
    final lowerStatus = status.toLowerCase();

    switch (lowerStatus) {
      case 'approved':
      case 'paid':
        return _StatusConfig(
          backgroundColor: colors?.successContainer ?? Colors.green.shade100,
          textColor: colors?.onSuccessContainer ?? Colors.green.shade900,
        );
      case 'draft':
        return _StatusConfig(
          backgroundColor: colors?.surfaceContainerHigh ?? Colors.grey.shade200,
          textColor: colors?.onSurfaceVariant ?? Colors.grey.shade700,
        );
      case 'sent':
      case 'requested':
        return _StatusConfig(
          backgroundColor: colors?.primaryContainer ?? Colors.blue.shade100,
          textColor: colors?.onPrimaryContainer ?? Colors.blue.shade900,
        );
      case 'overdue':
      case 'rejected':
        return _StatusConfig(
          backgroundColor: colors?.errorContainer ?? Colors.red.shade100,
          textColor: colors?.onErrorContainer ?? Colors.red.shade900,
        );
      default:
        return _StatusConfig(
          backgroundColor: colors?.surfaceContainerHigh ?? Colors.grey.shade200,
          textColor: colors?.onSurfaceVariant ?? Colors.grey.shade700,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
  });
}
