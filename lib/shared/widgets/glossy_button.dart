import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Rounded glossy lavender button with optional red usage badge.
class GlossyIconButton extends StatefulWidget {
  const GlossyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 56,
    this.badge,
    this.enabled = true,
    this.label,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final int? badge;
  final bool enabled;
  final String? label;
  final String? semanticLabel;

  @override
  State<GlossyIconButton> createState() => _GlossyIconButtonState();
}

class _GlossyIconButtonState extends State<GlossyIconButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final enabled = widget.enabled;
    final button = AnimatedScale(
      scale: _down ? 0.9 : 1,
      duration: const Duration(milliseconds: 90),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(s * 0.3),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: enabled
                      ? const [AppColors.buttonTop, AppColors.buttonBottom]
                      : const [Color(0xFF7A7398), Color(0xFF4E476E)],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                  if (enabled)
                    BoxShadow(
                      color: AppColors.buttonTop.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Gloss band.
                  Positioned(
                    left: s * 0.1,
                    right: s * 0.1,
                    top: s * 0.06,
                    height: s * 0.38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(s * 0.22),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: s * 0.52,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.badge != null)
              Positioned(
                right: -s * 0.12,
                top: -s * 0.12,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: s * 0.4,
                    minHeight: s * 0.4,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.badge! > 0
                        ? AppColors.badge
                        : const Color(0xFF6B6585),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.6),
                  ),
                  child: Text(
                    '${widget.badge}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: s * 0.22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button,
            if (widget.label != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.label!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wide pill button for popups and the home screen.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.colors = const [Color(0xFF6BE38F), Color(0xFF21A65A)],
    this.height = 54,
    this.fontSize = 20,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final List<Color> colors;
  final double height;
  final double fontSize;

  static const purple = [AppColors.buttonTop, AppColors.buttonBottom];
  static const red = [Color(0xFFFF7A86), Color(0xFFD62840)];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(height / 2),
        onTap: onTap,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.5),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: fontSize * 1.2),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
