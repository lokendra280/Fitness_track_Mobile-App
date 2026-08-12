import 'package:flutter/material.dart';

/// Fades + slides a child up into place. Give each item on a screen an
/// increasing [index] to get a staggered entrance.
class StaggerFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;

  const StaggerFadeIn({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  State<StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<StaggerFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Animates a linear progress bar value from 0 to [value] once, then
/// re-animates smoothly whenever [value] changes.
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;
  final double borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor = const Color(0xFFEDEEF0),
    this.height = 6,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );
      },
    );
  }
}

/// Animates a circular ring from 0 to [value], with a percentage label
/// counting up in the center.
class AnimatedRingProgress extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? center;
  final bool showPercentLabel;
  final TextStyle? labelStyle;

  const AnimatedRingProgress({
    super.key,
    required this.value,
    this.size = 72,
    this.strokeWidth = 7,
    required this.color,
    this.backgroundColor = const Color(0xFFEDEEF0),
    this.center,
    this.showPercentLabel = true,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              center ??
                  (showPercentLabel
                      ? Text('${(animatedValue * 100).round()}%',
                          style: labelStyle)
                      : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}

/// Counts a number up from its previous value to [value] whenever it
/// changes, e.g. for a weight readout.
class AnimatedCountUp extends StatelessWidget {
  final double value;
  final int decimals;
  final String suffix;
  final TextStyle? style;

  const AnimatedCountUp({
    super.key,
    required this.value,
    this.decimals = 1,
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text('${animatedValue.toStringAsFixed(decimals)}$suffix',
            style: style);
      },
    );
  }
}

/// Wraps a child with a subtle press-down scale, for tappable
/// cards/chips/icons that need to feel responsive.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  double _scale = 1;

  void _setScale(double s) => setState(() => _scale = s);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setScale(widget.pressedScale),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
