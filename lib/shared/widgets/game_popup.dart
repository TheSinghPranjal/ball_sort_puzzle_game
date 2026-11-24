import 'package:flutter/material.dart';

import '../../app/game_palette.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n.dart';

/// Shows [child] in a dimmed modal with a pop (scale + fade) transition.
Future<T?> showGamePopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = false,
}) {
  // Honor the OS "reduce motion" setting.
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.4,
    ),
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 300),
    pageBuilder: (context, _, _) =>
        SafeArea(child: Center(child: builder(context))),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Rounded purple panel with a title ribbon.
class GamePanel extends StatelessWidget {
  const GamePanel({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width.clamp(0, 420) * 0.86,
        margin: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.panel, palette.panelDark],
          ),
          border: Border.all(color: palette.panelBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withValues(alpha: 0.25),
              blurRadius: 30,
            ),
            BoxShadow(
              color: palette.shadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: AppColors.buttonBottom.withValues(
                            alpha: isDark ? 1 : 0.25,
                          ),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(child: SingleChildScrollView(child: child)),
                ],
              ),
            ),
            if (onClose != null)
              Positioned(
                right: 6,
                top: 6,
                child: IconButton(
                  tooltip: context.l10n.close,
                  onPressed: onClose,
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
