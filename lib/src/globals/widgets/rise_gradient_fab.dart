import 'package:flutter/material.dart';

class RiseGradientFab extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? tooltip;

  const RiseGradientFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xff3B82F6),
            Color(0xff1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        child: child,
      ),
    );
  }
}
