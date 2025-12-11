import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiBurst extends StatefulWidget {
  final bool play; // true면 자동으로 재생
  final Duration duration;

  const ConfettiBurst({
    super.key,
    this.play = true,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: widget.duration);

    if (widget.play) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _controller.play();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirection: 3.14 / 2, // 아래 방향
      emissionFrequency: 0.06,
      numberOfParticles: 14,
      maxBlastForce: 18,
      minBlastForce: 6,
      gravity: 0.2,
    );
  }
}
