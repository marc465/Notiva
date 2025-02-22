import 'package:flutter/cupertino.dart';

class AmplitudeWaveCircle extends StatefulWidget {
  final ValueNotifier<double> amplitude;
  final Color color;
  final double opacity;
  final double startP;
  final double endP;

  const AmplitudeWaveCircle({
    super.key, 
    required this.amplitude, 
    Color? color,
    double? opacity,
    double? startP,
    double? endP
  })  : color = CupertinoColors.activeBlue,
        opacity = opacity ?? 0.2,
        startP = 200,
        endP = 300;

  @override
  State<AmplitudeWaveCircle> createState() => AmplitudeWaveCircleState();
}

class AmplitudeWaveCircleState extends State<AmplitudeWaveCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _animation = Tween<double>(begin: widget.startP, end: widget.endP).animate(_controller);

    widget.amplitude.addListener(() {
      _controller.animateTo(widget.amplitude.value, curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Значення амплітуди для зміни розміру
    // double amplitudeSize = widget.size + (widget.amplitude.value * 100);

    return AnimatedBuilder(
      animation: _controller, 
      builder: (context, child) {
        return Opacity(
          opacity: widget.opacity,
          child: Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(widget.opacity),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ]
            ),
          ),
        );
      }
    );
  }
}
