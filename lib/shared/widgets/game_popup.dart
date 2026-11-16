import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Shows [child] in a dimmed modal with a pop (scale + fade) transition.
Future<T?> showGamePopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'popup',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, _, _) => SafeArea(child: Center(child: builder(context))),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// Rounded purple panel with a title ribbon.
class GamePanel extends StatelessWidget {
  const GamePanel({super.key, required this.title, required this.child, this.onClose});

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width.clamp(0, 420) * 0.86,
        margin: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.panel, AppColors.panelDark],
          ),
          border: Border.all(color: AppColors.panelBorder, width: 2),
          boxShadow: [
            BoxShadow(color: AppColors.lavender.withValues(alpha: 0.25), blurRadius: 30),
            const BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: AppColors.buttonBottom, blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(child: SingleChildScrollView(child: child)),
            ]),
          ),
          if (onClose != null)
            Positioned(
              right: 6,
              top: 6,
              child: IconButton(
                tooltip: 'Close',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ),
        ]),
      ),
    );
  }
}
