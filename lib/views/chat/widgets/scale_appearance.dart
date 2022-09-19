import 'package:flutter/material.dart';

class ScaleAppearance extends StatefulWidget {
  final bool appear;
  final Widget child;

  const ScaleAppearance({
    Key? key,
    required this.appear,
    required this.child,
  }) : super(key: key);

  @override
  State<ScaleAppearance> createState() => _ScaleAppearanceState();
}

class _ScaleAppearanceState extends State<ScaleAppearance>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween(
      begin: 0.0,
      end: 1.0,
    ));

    if (widget.appear) {
      _appear();
    }
  }

  @override
  void didUpdateWidget(ScaleAppearance oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.appear != oldWidget.appear) {
      if (widget.appear) {
        _appear();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    super.dispose();
  }

  void _appear() {
    _appearanceController
      ..duration = const Duration(milliseconds: 600)
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
