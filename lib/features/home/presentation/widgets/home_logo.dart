import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../game/presentation/widgets/glass_tube_widget.dart';
import '../../../game/presentation/widgets/glossy_ball_widget.dart';

/// Title art: three glass tubes with balls and the game name.
class HomeLogo extends StatefulWidget {
  const HomeLogo({super.key});

  @override
  State<HomeLogo> createState() => _HomeLogoState();
}

class _HomeLogoState extends State<HomeLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tubes = [
      [0, 1, 3],
      [3, 4, 4, 1],
      [2, 0, 5],
    ];
    const ball = 30.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_c.value);
            return SizedBox(
              height: 210,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < tubes.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          GlassTubeWidget(
                            width: ball * 1.32,
                            height: ball * 4.6,
                            child: Stack(
                              children: [
                                for (var j = 0; j < tubes[i].length; j++)
                                  Positioned(
                                    left: ball * 0.16,
                                    bottom: ball * 0.14 + j * ball * 1.02,
                                    child: (i == 1 && j == tubes[i].length - 1)
                                        ? Transform.translate(
                                            offset: Offset(
                                              0,
                                              -ball * (1.6 + t * 0.4),
                                            ),
                                            child: GlossyBallWidget(
                                              colorId: tubes[i][j],
                                              diameter: ball,
                                              glow: 0.6,
                                            ),
                                          )
                                        : GlossyBallWidget(
                                            colorId: tubes[i][j],
                                            diameter: ball,
                                          ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.lavender],
          ).createShader(r),
          child: const Text(
            'BALL SORT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [Shadow(color: AppColors.buttonBottom, blurRadius: 24)],
            ),
          ),
        ),
        const Text(
          'COLOR  PUZZLE',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }
}
