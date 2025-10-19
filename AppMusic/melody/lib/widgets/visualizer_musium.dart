import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';

/// Advanced Audio Visualizer with Animated Bars
class VisualizerMusium extends StatefulWidget {
  final bool isPlaying;
  final int barCount;

  const VisualizerMusium({
    Key? key,
    this.isPlaying = true,
    this.barCount = 20,
  }) : super(key: key);

  @override
  State<VisualizerMusium> createState() => _VisualizerMusiumState();
}

class _VisualizerMusiumState extends State<VisualizerMusium>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<double> _heights;
  late List<Offset> _particlePositions;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeParticles();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 20)),
        vsync: this,
      ),
    );

    _heights = List.generate(widget.barCount, (_) => 0.0);

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  void _initializeParticles() {
    _particlePositions = List.generate(15, (_) => Offset.zero);
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
    }
  }

  @override
  void didUpdateWidget(VisualizerMusium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        for (var controller in _controllers) {
          controller.stop();
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VisualizerPainter(
        controllers: _controllers,
        particleProgress: _particleController,
        barCount: widget.barCount,
      ),
      size: Size.infinite,
    );
  }
}

/// Custom Painter for Visualizer
class VisualizerPainter extends CustomPainter {
  final List<AnimationController> controllers;
  final Animation<double> particleProgress;
  final int barCount;

  VisualizerPainter({
    required this.controllers,
    required this.particleProgress,
    required this.barCount,
  }) : super(repaint: particleProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final barWidth = (width / barCount) * 0.6;
    final spacing = (width / barCount) * 0.4;

    // Draw bars
    for (int i = 0; i < barCount; i++) {
      final xPos = (width / barCount) * i + spacing / 2;
      final progress = controllers[i].value;

      // Bar height with random variation
      final baseHeight = height * 0.3;
      final randomHeight = baseHeight * (0.5 + 0.5 * ((i % 3) / 3) * progress);

      // Gradient for bar
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColorMusium.accentTeal.withValues(alpha: 1.0),
          AppColorMusium.accentTeal.withValues(alpha: 0.5),
          AppColorMusium.accentPurple.withValues(alpha: 0.7),
        ],
      );

      // Draw bar with gradient
      final rect = Rect.fromLTWH(
        xPos,
        height / 2 - randomHeight / 2,
        barWidth,
        randomHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        paint..shader = gradient.createShader(rect),
      );

      // Add glow effect
      paint
        ..color = AppColorMusium.accentTeal.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        paint,
      );

      // Reset mask filter
      paint.maskFilter = null;
    }

    // Draw particles
    _drawParticles(canvas, size);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final progress = particleProgress.value;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 15; i++) {
      final angle = (i / 15) * 2 * 3.14159;
      final distance = 100 * progress;

      final x = centerX + distance * cos(angle);
      final y = centerY + distance * sin(angle);

      final opacity = (1 - progress).clamp(0.0, 1.0);

      paint.color = AppColorMusium.accentPink.withValues(alpha: opacity * 0.6);

      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) => true;

  double cos(double value) => _cos(value);
  double sin(double value) => _sin(value);

  static double _cos(double value) {
    value = value % (2 * 3.14159);
    if (value < 0) value += 2 * 3.14159;
    if (value < 3.14159 / 2) return 1 - value / (3.14159 / 2);
    if (value < 3.14159) return (value - 3.14159 / 2) / (3.14159 / 2) - 1;
    if (value < 3 * 3.14159 / 2) return -(value - 3.14159) / (3.14159 / 2) - 1;
    return (value - 3 * 3.14159 / 2) / (3.14159 / 2);
  }

  static double _sin(double value) {
    value = value % (2 * 3.14159);
    if (value < 0) value += 2 * 3.14159;
    return _cos(value - 3.14159 / 2);
  }
}
