import 'package:flutter/material.dart';

class ProcessIndicatorAnimation extends StatefulWidget {
  final double strokeWidth;

  const ProcessIndicatorAnimation({this.strokeWidth = 6, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProcessIndicatorAnimationState createState() => _ProcessIndicatorAnimationState();
}

class _ProcessIndicatorAnimationState extends State<ProcessIndicatorAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Controls the duration of the full color cycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // repeat indefinitely

    // Smooth color transitions using TweenSequence
    _colorAnimation = _controller.drive(
      TweenSequence<Color?>([
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.purple, end: Colors.purpleAccent),
            weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.purpleAccent, end: Colors.blue),
            weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.blue, end: Colors.blue[900]),
            weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.blue[900], end: Colors.purple),
            weight: 1),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        width: 100,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color?>(_colorAnimation.value),
            );
          },
        ),
      ),
    );
  }
}
