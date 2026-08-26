import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitflow/core/constants/constant_assets.dart';
import 'package:habitflow/core/constants/size_constant.dart';
import 'package:habitflow/core/constants/app_string.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:lottie/lottie.dart';

import 'package:habitflow/core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _gold = Color(0xFFF4C04F);

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );

  late final Animation<double> _scale = Tween(begin: 0.92, end: 1.0).animate(
    CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
  );

  late final Animation<Offset> _slideUp =
      Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    ),
  );
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.journeyGradientTop,
              AppColors.journeyGradientBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative depth — soft, oversized blurred circles that
            // sit outside the viewport, giving the flat gradient some
            // dimensionality without any imagery.
            const Positioned(
              top: -120,
              right: -80,
              child: _GlowCircle(size: 280, opacity: 0.06),
            ),
            const Positioned(
              bottom: -140,
              left: -100,
              child: _GlowCircle(size: 320, opacity: 0.05, color: _gold),
            ),

            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slideUp,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Soft glow sitting directly behind the mark
                          // to lift it off the flat background.
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                              Lottie.asset(
                                Assets.animations,
                                width: 170,
                                height: 170,
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ],
                          ),
                          SBC.sH,
                          // const Gap(18),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFE7EAE8)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              AppString.appName,
                              style: GoogleFonts.syne(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const Gap(10),
                          Container(
                            width: 36,
                            height: 2,
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // const Gap(),
                          Text(
                            AppString.appSubTitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Loader anchored near the bottom rather than stacked
            // directly under the tagline — keeps the hero content
            // centered and gives the loading state its own breathing
            // room, which reads calmer / more premium than everything
            // clustered in the middle.
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: FadeTransition(
                opacity: _fade,
                child: const Center(child: _PulsingDotsLoader(color: _gold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.opacity,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// Three softly pulsing dots — reads calmer and more deliberate than a
/// spinning ring, which is what most splash screens default to.
class _PulsingDotsLoader extends StatefulWidget {
  final Color color;
  const _PulsingDotsLoader({required this.color});

  @override
  State<_PulsingDotsLoader> createState() => _PulsingDotsLoaderState();
}

class _PulsingDotsLoaderState extends State<_PulsingDotsLoader>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = List.generate(
    3,
    (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true, period: const Duration(milliseconds: 900)),
  );

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            final t = _controllers[i].value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.35 + (0.65 * t)),
              ),
              transform: Matrix4.identity()..scale(0.8 + (0.4 * t)),
              transformAlignment: Alignment.center,
            );
          },
        );
      }),
    );
  }
}
