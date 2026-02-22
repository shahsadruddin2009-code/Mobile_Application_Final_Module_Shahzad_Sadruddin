// ============================================================================
// MUSCLE POWER - Exercise Illustration Widget
// ============================================================================
//
// File: exercise_illustration.dart
// Description: Animated custom paint illustrations for exercises
//
// Features:
// - 25+ unique exercise animations
// - Custom paint rendering for each exercise type
// - Smooth looping animations with configurable speed
// - Realistic human figure with muscle definition
// - Equipment rendering (barbells, dumbbells, cables, benches)
// - Color customization for primary and secondary colors
// - Scalable size for different display contexts
//
// Supported Exercises:
//
// Chest:
// - Bench Press, Incline Press, Cable Flyes, Push-Ups, Dips, Incline Cable Fly
//
// Back:
// - Deadlift, Pull-Ups, Barbell Rows, Lat Pulldown
//
// Shoulders:
// - Overhead Press, Lateral Raise, Front Raise, Shrugs
//
// Arms:
// - Bicep Curl, Hammer Curl, Tricep Pushdown, Skull Crushers
//
// Legs:
// - Squats, Leg Press, Lunges, Leg Curl, Leg Extension, Calf Raises
//
// Core:
// - Plank, Crunches, Leg Raises, Russian Twist
//
// Animation Types:
// - Standard reverse: Most exercises (back and forth motion)
// - Alternating: Hammer curls, lunges (left/right alternation)
//
// Custom Painters:
// - Each exercise has a dedicated CustomPainter class
// - Base class ExercisePainterBase provides common utilities
// - Realistic skin tones and muscle shading
// - Equipment rendered with proper perspective
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated exercise illustration widget using custom painting
///
/// Displays a dynamic, animated visualization of the specified exercise.
/// Uses CustomPainter to render a human figure performing the exercise
/// with smooth animation transitions.
///
/// Parameters:
/// - [exerciseName]: Name of the exercise to illustrate (case-insensitive)
/// - [size]: Width and height of the illustration (square)
/// - [primaryColor]: Main color for the figure
/// - [secondaryColor]: Accent color for equipment and highlights
/// - [animate]: Whether to animate the exercise (default: true)
///
/// Example:
/// ```dart
/// ExerciseIllustration(
///   exerciseName: 'Bench Press',
///   size: 200,
///   primaryColor: Color(0xFFFF6B35),
///   secondaryColor: Color(0xFF00D9FF),
///   animate: true,
/// )
/// ```
class ExerciseIllustration extends StatefulWidget {
  final String exerciseName;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool animate;

  const ExerciseIllustration({
    super.key,
    required this.exerciseName,
    this.size = 200,
    this.primaryColor = const Color(0xFFFF6B35),
    this.secondaryColor = const Color(0xFF00D9FF),
    this.animate = true,
  });

  @override
  State<ExerciseIllustration> createState() => _ExerciseIllustrationState();
}

class _ExerciseIllustrationState extends State<ExerciseIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Check if exercise needs non-reversing animation (alternating movements)
  bool get _isAlternatingExercise {
    final key = widget.exerciseName.toLowerCase();
    return key.contains('hammer curl') ||
        key.contains('alternating') ||
        key.contains('lunges');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: _isAlternatingExercise ? 3000 : 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: _isAlternatingExercise ? Curves.linear : Curves.easeInOut),
    );
    if (widget.animate) {
      // Alternating exercises don't reverse - they need full 0→1 cycle for proper alternation
      if (_isAlternatingExercise) {
        _controller.repeat(reverse: false);
      } else {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _getExercisePainter(),
        );
      },
    );
  }

  CustomPainter _getExercisePainter() {
    final exerciseKey = widget.exerciseName.toLowerCase();

    // Chest Exercises
    if (exerciseKey.contains('bench press') ||
        exerciseKey.contains('barbell bench')) {
      return BenchPressPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('incline') &&
        exerciseKey.contains('press')) {
      return InclinePressPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('incline') &&
        (exerciseKey.contains('cable') || exerciseKey.contains('fly'))) {
      return InclineCableFlyPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('flye') || exerciseKey.contains('fly')) {
      return CableFlyePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('push-up') ||
        exerciseKey.contains('pushup')) {
      return PushUpPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('dip')) {
      return DipsPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    }
    // Back Exercises
    else if (exerciseKey.contains('deadlift')) {
      return DeadliftPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('pull-up') ||
        exerciseKey.contains('pullup')) {
      return PullUpPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('row')) {
      return BarbellRowPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('lat pulldown') ||
        exerciseKey.contains('pulldown')) {
      return LatPulldownPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    }
    // Shoulder Exercises
    else if (exerciseKey.contains('overhead press') ||
        exerciseKey.contains('military press') ||
        exerciseKey.contains('shoulder press')) {
      return OverheadPressPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('lateral raise')) {
      return LateralRaisePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('front raise')) {
      return FrontRaisePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('shrug')) {
      return ShrugPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    }
    // Arm Exercises
    else if (exerciseKey.contains('bicep curl') ||
        exerciseKey.contains('barbell curl')) {
      return BicepCurlPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('hammer curl')) {
      return HammerCurlPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('tricep') &&
        (exerciseKey.contains('pushdown') ||
            exerciseKey.contains('extension'))) {
      return TricepPushdownPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('skull crusher')) {
      return SkullCrusherPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    }
    // Leg Exercises
    else if (exerciseKey.contains('squat')) {
      return SquatPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('leg press')) {
      return LegPressPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('lunge')) {
      return LungePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('leg curl')) {
      return LegCurlPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('leg extension')) {
      return LegExtensionPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('calf')) {
      return CalfRaisePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    }
    // Core Exercises
    else if (exerciseKey.contains('plank')) {
      return PlankPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('crunch') ||
        exerciseKey.contains('cable crunch')) {
      return CrunchPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('leg raise') &&
        !exerciseKey.contains('lateral') &&
        !exerciseKey.contains('front')) {
      return LegRaisePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    } else if (exerciseKey.contains('russian twist')) {
      return RussianTwistPainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      );
    }
    // Default fallback
    else {
      return DefaultExercisePainter(
        progress: _animation.value,
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
        exerciseName: widget.exerciseName,
      );
    }
  }
}

// ==================== BASE PAINTER CLASS ====================

abstract class ExercisePainterBase extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  ExercisePainterBase({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  // Skin and body colors for realistic look
  Color get skinColor => const Color(0xFFD4A574);
  Color get skinShadow => const Color(0xFFB8956A);
  Color get skinHighlight => const Color(0xFFE8C4A0);
  Color get muscleDefinition => const Color(0xFF9A7B5A);

  // Common paint styles
  Paint get bodyPaint => Paint()
    ..color = primaryColor
    ..style = PaintingStyle.fill;

  Paint get outlinePaint => Paint()
    ..color = primaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  Paint get equipmentPaint => Paint()
    ..color = secondaryColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  Paint get weightPaint => Paint()
    ..color = secondaryColor
    ..style = PaintingStyle.fill;

  Paint get benchPaint => Paint()
    ..color = Colors.grey[700]!
    ..style = PaintingStyle.fill;

  // Draw realistic muscular head with neck
  void drawRealisticHead(Canvas canvas, Offset center, double scale) {
    final headRadius = 14 * scale;

    // Neck (thick muscular neck)
    final neckPath = Path();
    neckPath.moveTo(center.dx - 8 * scale, center.dy + headRadius * 0.6);
    neckPath.lineTo(center.dx - 12 * scale, center.dy + headRadius * 1.8);
    neckPath.lineTo(center.dx + 12 * scale, center.dy + headRadius * 1.8);
    neckPath.lineTo(center.dx + 8 * scale, center.dy + headRadius * 0.6);
    neckPath.close();

    // Neck gradient
    final neckPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skinColor, skinShadow],
      ).createShader(Rect.fromCircle(center: center, radius: headRadius * 2));
    canvas.drawPath(neckPath, neckPaint);

    // Trapezius muscle hints on neck
    final trapPaint = Paint()
      ..color = muscleDefinition.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - 6 * scale, center.dy + headRadius * 0.8),
      Offset(center.dx - 10 * scale, center.dy + headRadius * 1.6),
      trapPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 6 * scale, center.dy + headRadius * 0.8),
      Offset(center.dx + 10 * scale, center.dy + headRadius * 1.6),
      trapPaint,
    );

    // Head base
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [skinHighlight, skinColor, skinShadow],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: headRadius));
    canvas.drawCircle(center, headRadius, headPaint);

    // Jaw definition
    final jawPath = Path();
    jawPath.moveTo(center.dx - headRadius * 0.7, center.dy + headRadius * 0.2);
    jawPath.quadraticBezierTo(
      center.dx,
      center.dy + headRadius * 1.1,
      center.dx + headRadius * 0.7,
      center.dy + headRadius * 0.2,
    );
    canvas.drawPath(
        jawPath,
        Paint()
          ..color = skinShadow.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Hair (short athletic cut)
    final hairPaint = Paint()..color = const Color.fromARGB(255, 45, 45, 45);
    final hairPath = Path();
    hairPath.addArc(
      Rect.fromCircle(
          center: Offset(center.dx + 2 * scale, center.dy - 2 * scale), radius: headRadius),
      math.pi * 1.15,
      math.pi * 0.7,
    );
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Simple face features
    const eyeColor = Color(0xFF2D2D2D);
    canvas.drawCircle(Offset(center.dx - 4 * scale, center.dy - 2 * scale),
        1.5 * scale, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(center.dx + 4 * scale, center.dy - 2 * scale),
        1.5 * scale, Paint()..color = eyeColor);
  }

  // Draw muscular torso with definition
  void drawMuscularTorso(Canvas canvas, Offset shoulderCenter, double width,
      double height, double flexAmount) {
    final left = shoulderCenter.dx - width / 2;
    final right = shoulderCenter.dx + width / 2;
    final top = shoulderCenter.dy;
    final bottom = shoulderCenter.dy + height;

    // Main torso shape
    final torsoPath = Path();
    torsoPath.moveTo(left + width * 0.15, top);
    // Left shoulder curve (deltoid)
    torsoPath.quadraticBezierTo(
        left - width * 0.1, top + height * 0.1, left, top + height * 0.25);
    // Left side (lats)
    torsoPath.quadraticBezierTo(left - width * 0.08, top + height * 0.5,
        left + width * 0.15, top + height * 0.7);
    // Left oblique
    torsoPath.quadraticBezierTo(
        left + width * 0.2, top + height * 0.85, left + width * 0.3, bottom);
    // Bottom (waist)
    torsoPath.lineTo(right - width * 0.3, bottom);
    // Right oblique
    torsoPath.quadraticBezierTo(right - width * 0.2, top + height * 0.85,
        right - width * 0.15, top + height * 0.7);
    // Right side (lats)
    torsoPath.quadraticBezierTo(
        right + width * 0.08, top + height * 0.5, right, top + height * 0.25);
    // Right shoulder curve (deltoid)
    torsoPath.quadraticBezierTo(
        right + width * 0.1, top + height * 0.1, right - width * 0.15, top);
    torsoPath.close();

    // Torso gradient (3D effect)
    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [skinHighlight, skinColor, skinShadow],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTRB(left, top, right, bottom));
    canvas.drawPath(torsoPath, torsoPaint);

    // Pectoral muscles
    final chestFlex = 1.0 + flexAmount * 0.15;
    _drawPectoralMuscle(
        canvas,
        Offset(shoulderCenter.dx - width * 0.18, top + height * 0.15),
        width * 0.35 * chestFlex,
        height * 0.22,
        true);
    _drawPectoralMuscle(
        canvas,
        Offset(shoulderCenter.dx + width * 0.18, top + height * 0.15),
        width * 0.35 * chestFlex,
        height * 0.22,
        false);

    // Sternum line
    final sternumPaint = Paint()
      ..color = muscleDefinition.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(shoulderCenter.dx, top + height * 0.08),
      Offset(shoulderCenter.dx, top + height * 0.38),
      sternumPaint,
    );

    // Abdominal muscles (6-pack)
    _drawAbdominals(canvas, Offset(shoulderCenter.dx, top + height * 0.45),
        width * 0.35, height * 0.45, flexAmount);

    // Serratus anterior (side ribs)
    _drawSerratus(canvas, Offset(left + width * 0.12, top + height * 0.35),
        width * 0.1, height * 0.25, true);
    _drawSerratus(canvas, Offset(right - width * 0.12, top + height * 0.35),
        width * 0.1, height * 0.25, false);

    // Oblique definition
    final obliquePaint = Paint()
      ..color = muscleDefinition.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(left + width * 0.18, top + height * 0.55),
      Offset(left + width * 0.28, bottom - height * 0.05),
      obliquePaint,
    );
    canvas.drawLine(
      Offset(right - width * 0.18, top + height * 0.55),
      Offset(right - width * 0.28, bottom - height * 0.05),
      obliquePaint,
    );
  }

  void _drawPectoralMuscle(
      Canvas canvas, Offset center, double width, double height, bool isLeft) {
    final path = Path();
    final startX = isLeft ? center.dx + width * 0.4 : center.dx - width * 0.4;
    final endX = isLeft ? center.dx - width * 0.5 : center.dx + width * 0.5;

    path.moveTo(startX, center.dy);
    path.quadraticBezierTo(
      center.dx,
      center.dy - height * 0.3,
      endX,
      center.dy + height * 0.2,
    );
    path.quadraticBezierTo(
      center.dx,
      center.dy + height * 0.8,
      startX,
      center.dy + height * 0.5,
    );
    path.close();

    // Pec shadow/definition
    final pecPaint = Paint()
      ..shader = RadialGradient(
        center:
            isLeft ? const Alignment(0.3, -0.3) : const Alignment(-0.3, -0.3),
        colors: [
          skinHighlight.withOpacity(0.3),
          muscleDefinition.withOpacity(0.4)
        ],
      ).createShader(
          Rect.fromCenter(center: center, width: width, height: height));
    canvas.drawPath(path, pecPaint);

    // Pec outline
    canvas.drawPath(
        path,
        Paint()
          ..color = muscleDefinition.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
  }

  void _drawAbdominals(Canvas canvas, Offset center, double width,
      double height, double flexAmount) {
    final abPaint = Paint()
      ..color = muscleDefinition.withOpacity(0.25 + flexAmount * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = skinShadow.withOpacity(0.15 + flexAmount * 0.1);

    // Linea alba (center line)
    canvas.drawLine(
      Offset(center.dx, center.dy - height * 0.5),
      Offset(center.dx, center.dy + height * 0.5),
      abPaint,
    );

    // Ab sections (3 rows of 2)
    for (int row = 0; row < 3; row++) {
      final rowY = center.dy - height * 0.35 + (row * height * 0.32);
      final abHeight = height * 0.28;
      final abWidth = width * 0.42;

      // Left ab
      final leftRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - abWidth * 0.6, rowY),
          width: abWidth,
          height: abHeight,
        ),
        Radius.circular(abWidth * 0.3),
      );
      canvas.drawRRect(leftRect, fillPaint);
      canvas.drawRRect(leftRect, abPaint);

      // Right ab
      final rightRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + abWidth * 0.6, rowY),
          width: abWidth,
          height: abHeight,
        ),
        Radius.circular(abWidth * 0.3),
      );
      canvas.drawRRect(rightRect, fillPaint);
      canvas.drawRRect(rightRect, abPaint);
    }
  }

  void _drawSerratus(
      Canvas canvas, Offset start, double width, double height, bool isLeft) {
    final paint = Paint()
      ..color = muscleDefinition.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 3; i++) {
      final y = start.dy + (i * height * 0.35);
      final direction = isLeft ? 1.0 : -1.0;
      canvas.drawLine(
        Offset(start.dx, y),
        Offset(start.dx + direction * width, y + height * 0.15),
        paint,
      );
    }
  }

  // Draw muscular arm with bicep/tricep definition
  void drawMuscularArm(Canvas canvas, Offset shoulder, Offset elbow,
      Offset hand, double thickness, double flexAmount,
      {bool showBicep = true}) {
    // Upper arm
    _drawMuscularLimb(canvas, shoulder, elbow, thickness * 1.2, flexAmount,
        isBicep: showBicep);

    // Forearm
    _drawMuscularLimb(canvas, elbow, hand, thickness * 0.9, 0);

    // Deltoid at shoulder
    _drawDeltoid(canvas, shoulder, thickness * 1.5, flexAmount);

    // Bicep bulge when flexed
    if (showBicep && flexAmount > 0.3) {
      final bicepCenter = Offset(
        shoulder.dx + (elbow.dx - shoulder.dx) * 0.4,
        shoulder.dy + (elbow.dy - shoulder.dy) * 0.4,
      );
      final bicepSize = thickness * 1.3 * (0.8 + flexAmount * 0.4);
      _drawBicepBulge(canvas, bicepCenter, bicepSize, shoulder, elbow);
    }
  }

  void _drawMuscularLimb(Canvas canvas, Offset start, Offset end,
      double thickness, double flexAmount,
      {bool isBicep = false}) {
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final perpAngle = angle + math.pi / 2;

    final bulgeFactor = isBicep ? (1.0 + flexAmount * 0.3) : 1.0;
    final midPoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    // Create limb path with muscle bulge
    final path = Path();
    final halfThick = thickness / 2 * bulgeFactor;

    path.moveTo(
      start.dx + math.cos(perpAngle) * thickness / 2,
      start.dy + math.sin(perpAngle) * thickness / 2,
    );

    // Outer curve (bulging muscle)
    path.quadraticBezierTo(
      midPoint.dx + math.cos(perpAngle) * halfThick * 1.3,
      midPoint.dy + math.sin(perpAngle) * halfThick * 1.3,
      end.dx + math.cos(perpAngle) * thickness / 2 * 0.8,
      end.dy + math.sin(perpAngle) * thickness / 2 * 0.8,
    );

    // End cap
    path.lineTo(
      end.dx - math.cos(perpAngle) * thickness / 2 * 0.8,
      end.dy - math.sin(perpAngle) * thickness / 2 * 0.8,
    );

    // Inner curve
    path.quadraticBezierTo(
      midPoint.dx - math.cos(perpAngle) * halfThick * 0.9,
      midPoint.dy - math.sin(perpAngle) * halfThick * 0.9,
      start.dx - math.cos(perpAngle) * thickness / 2,
      start.dy - math.sin(perpAngle) * thickness / 2,
    );

    path.close();

    // Gradient for 3D effect
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [skinHighlight, skinColor, skinShadow],
      ).createShader(Rect.fromPoints(start, end).inflate(thickness));
    canvas.drawPath(path, paint);

    // Muscle definition line
    if (isBicep) {
      final defPaint = Paint()
        ..color = muscleDefinition.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(start.dx + (end.dx - start.dx) * 0.2,
            start.dy + (end.dy - start.dy) * 0.2),
        Offset(start.dx + (end.dx - start.dx) * 0.8,
            start.dy + (end.dy - start.dy) * 0.8),
        defPaint,
      );
    }
  }

  void _drawDeltoid(
      Canvas canvas, Offset shoulder, double size, double flexAmount) {
    final deltoidPath = Path();
    final bulgeFactor = 1.0 + flexAmount * 0.2;

    deltoidPath.addOval(Rect.fromCenter(
      center: shoulder,
      width: size * bulgeFactor,
      height: size * 0.8 * bulgeFactor,
    ));

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [skinHighlight, skinColor, skinShadow],
      ).createShader(Rect.fromCircle(center: shoulder, radius: size));
    canvas.drawPath(deltoidPath, paint);

    // Deltoid separation lines
    final sepPaint = Paint()
      ..color = muscleDefinition.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCircle(center: shoulder, radius: size * 0.4),
      -math.pi * 0.3,
      math.pi * 0.6,
      false,
      sepPaint,
    );
  }

  void _drawBicepBulge(Canvas canvas, Offset center, double size,
      Offset shoulder, Offset elbow) {
    final bulgePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.4),
        colors: [skinHighlight, skinColor],
      ).createShader(Rect.fromCircle(center: center, radius: size));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size * 1.2, height: size),
      bulgePaint,
    );

    // Bicep peak highlight
    final highlightPaint = Paint()
      ..color = skinHighlight.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.2, center.dy - size * 0.2),
        width: size * 0.4,
        height: size * 0.25,
      ),
      highlightPaint,
    );
  }

  // Draw muscular leg
  void drawMuscularLeg(
      Canvas canvas, Offset hip, Offset knee, Offset ankle, double thickness) {
    // Quadriceps (upper leg)
    _drawMuscularLimb(canvas, hip, knee, thickness * 1.4, 0);

    // Calf (lower leg)
    _drawCalfMuscle(canvas, knee, ankle, thickness);

    // Quad definition
    final quadMid = Offset(
      hip.dx + (knee.dx - hip.dx) * 0.5,
      hip.dy + (knee.dy - hip.dy) * 0.5,
    );
    final quadPaint = Paint()
      ..color = muscleDefinition.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(quadMid.dx - 2, hip.dy + (knee.dy - hip.dy) * 0.2),
      Offset(quadMid.dx - 2, hip.dy + (knee.dy - hip.dy) * 0.8),
      quadPaint,
    );
  }

  void _drawCalfMuscle(
      Canvas canvas, Offset knee, Offset ankle, double thickness) {
    final angle = math.atan2(ankle.dy - knee.dy, ankle.dx - knee.dx);
    final perpAngle = angle + math.pi / 2;

    // Calf has a distinctive bulge at the top
    final calfBulge = Offset(
      knee.dx + (ankle.dx - knee.dx) * 0.3,
      knee.dy + (ankle.dy - knee.dy) * 0.3,
    );

    final path = Path();
    path.moveTo(
      knee.dx + math.cos(perpAngle) * thickness * 0.5,
      knee.dy + math.sin(perpAngle) * thickness * 0.5,
    );

    // Outer calf curve with bulge
    path.quadraticBezierTo(
      calfBulge.dx + math.cos(perpAngle) * thickness * 0.8,
      calfBulge.dy + math.sin(perpAngle) * thickness * 0.8,
      ankle.dx + math.cos(perpAngle) * thickness * 0.3,
      ankle.dy + math.sin(perpAngle) * thickness * 0.3,
    );

    path.lineTo(
      ankle.dx - math.cos(perpAngle) * thickness * 0.3,
      ankle.dy - math.sin(perpAngle) * thickness * 0.3,
    );

    // Inner calf curve
    path.quadraticBezierTo(
      calfBulge.dx - math.cos(perpAngle) * thickness * 0.6,
      calfBulge.dy - math.sin(perpAngle) * thickness * 0.6,
      knee.dx - math.cos(perpAngle) * thickness * 0.5,
      knee.dy - math.sin(perpAngle) * thickness * 0.5,
    );

    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [skinHighlight, skinColor, skinShadow],
      ).createShader(Rect.fromPoints(knee, ankle).inflate(thickness));
    canvas.drawPath(path, paint);
  }

  // Draw hand
  void drawHand(Canvas canvas, Offset position, double size, double angle) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // Palm
    final palmPaint = Paint()
      ..shader = RadialGradient(
        colors: [skinHighlight, skinColor, skinShadow],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero, width: size * 1.2, height: size * 0.9),
        Radius.circular(size * 0.2),
      ),
      palmPaint,
    );

    // Fingers (simplified)
    final fingerPaint = Paint()..color = skinColor;
    for (int i = 0; i < 4; i++) {
      final fingerX = -size * 0.4 + (i * size * 0.27);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(fingerX, -size * 0.7, size * 0.2, size * 0.35),
          Radius.circular(size * 0.1),
        ),
        fingerPaint,
      );
    }

    // Thumb
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size * 0.35, -size * 0.15, size * 0.35, size * 0.2),
        Radius.circular(size * 0.1),
      ),
      fingerPaint,
    );

    canvas.restore();
  }

  // Legacy methods for compatibility
  void drawHead(Canvas canvas, Offset center, double radius) {
    drawRealisticHead(canvas, center, radius / 14);
  }

  void drawBody(Canvas canvas, Offset start, Offset end) {
    canvas.drawLine(start, end, outlinePaint..strokeWidth = 8);
  }

  void drawLimb(Canvas canvas, Offset start, Offset end, {double width = 5}) {
    canvas.drawLine(start, end, outlinePaint..strokeWidth = width);
  }

  void drawBarbell(
      Canvas canvas, Offset start, Offset end, double plateRadius) {
    // Enhanced barbell with metallic look
    final barGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey[300]!,
        Colors.grey[500]!,
        Colors.grey[300]!,
      ],
    );

    final barPaint = Paint()
      ..shader = barGradient.createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, barPaint);

    // Weight plates with 3D effect
    _drawWeightPlate(canvas, start, plateRadius);
    _drawWeightPlate(canvas, end, plateRadius);
  }

  void _drawWeightPlate(Canvas canvas, Offset center, double radius) {
    // Outer ring
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor,
          secondaryColor.withOpacity(0.7),
          secondaryColor
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    // Inner ring
    final innerPaint = Paint()..color = secondaryColor.withOpacity(0.5);
    canvas.drawCircle(center, radius * 0.6, innerPaint);

    // Center hole
    canvas.drawCircle(center, radius * 0.2, Paint()..color = Colors.grey[800]!);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      -math.pi * 0.8,
      math.pi * 0.5,
      false,
      highlightPaint,
    );
  }

  void drawDumbbell(Canvas canvas, Offset center, double length,
      double plateSize, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Bar with metallic gradient
    final barPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB0B0B0), Color(0xFF707070), Color(0xFFB0B0B0)],
      ).createShader(
          Rect.fromCenter(center: Offset.zero, width: length, height: 8))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-length / 2, 0), Offset(length / 2, 0), barPaint);

    // Enhanced plates
    _drawDumbbellPlate(canvas, Offset(-length / 2, 0), plateSize);
    _drawDumbbellPlate(canvas, Offset(length / 2, 0), plateSize);

    canvas.restore();
  }

  void _drawDumbbellPlate(Canvas canvas, Offset center, double size) {
    final platePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          secondaryColor,
          secondaryColor.withOpacity(0.6),
          secondaryColor
        ],
      ).createShader(
          Rect.fromCenter(center: center, width: size, height: size * 1.5));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size, height: size * 1.5),
        Radius.circular(size * 0.15),
      ),
      platePaint,
    );

    // Highlight
    canvas.drawLine(
      Offset(center.dx - size * 0.3, center.dy - size * 0.5),
      Offset(center.dx - size * 0.3, center.dy + size * 0.5),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 1.5,
    );
  }

  void drawBench(Canvas canvas, Rect rect) {
    // Enhanced bench with padding look
    final benchGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey[600]!, Colors.grey[800]!, Colors.grey[700]!],
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    final benchPaintFill = Paint()..shader = benchGradient.createShader(rect);
    canvas.drawRRect(rrect, benchPaintFill);

    // Padding texture
    final paddingPaint = Paint()
      ..color = Colors.grey[500]!.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double x = rect.left + 15; x < rect.right - 10; x += 20) {
      canvas.drawLine(
          Offset(x, rect.top + 3), Offset(x, rect.bottom - 3), paddingPaint);
    }

    // Metal frame
    final framePaint = Paint()..color = Colors.grey[900]!;
    canvas.drawRect(
        Rect.fromLTWH(rect.left + 8, rect.bottom, 10, 25), framePaint);
    canvas.drawRect(
        Rect.fromLTWH(rect.right - 18, rect.bottom, 10, 25), framePaint);

    // Frame feet
    canvas.drawRect(
        Rect.fromLTWH(rect.left + 3, rect.bottom + 22, 20, 5), framePaint);
    canvas.drawRect(
        Rect.fromLTWH(rect.right - 23, rect.bottom + 22, 20, 5), framePaint);
  }

  void drawMuscleHighlight(
      Canvas canvas, Offset center, double radius, Color color) {
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.5),
        color.withOpacity(0.2),
        color.withOpacity(0)
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  // ==================== GYM CLOTHING COLORS ====================
  Color get jerseyColor => const Color(0xFF1A1A2E);
  Color get jerseyHighlight => const Color(0xFF2D2D44);
  Color get shortsColor => const Color(0xFF2D2D2D);
  Color get shortsHighlight => const Color(0xFF404040);

  // ==================== COMPLETE HEAD WITH DETAILED FACE ====================
  void drawCompleteHead(Canvas canvas, Offset center, double scale,
      {double rotation = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final headRadius = 12 * scale;

    // Neck (muscular)
    final neckPath = Path();
    neckPath.moveTo(-7 * scale, headRadius * 0.4);
    neckPath.quadraticBezierTo(
        -9 * scale, headRadius * 1.2, -10 * scale, headRadius * 1.6);
    neckPath.lineTo(10 * scale, headRadius * 1.6);
    neckPath.quadraticBezierTo(
        9 * scale, headRadius * 1.2, 7 * scale, headRadius * 0.4);
    neckPath.close();

    canvas.drawPath(
        neckPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [skinShadow, skinColor, skinShadow],
          ).createShader(
              Rect.fromLTWH(-10 * scale, 0, 20 * scale, headRadius * 2)));

    // Head shape (oval)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero,
          width: headRadius * 1.8,
          height: headRadius * 2.0),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.3),
          colors: [skinHighlight, skinColor, skinShadow],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: Offset.zero, radius: headRadius)),
    );

    // Ears
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-headRadius * 0.85, 0),
          width: 3 * scale,
          height: 6 * scale),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headRadius * 0.85, 0),
          width: 3 * scale,
          height: 6 * scale),
      Paint()..color = skinColor,
    );

    // Hair
    final hairPath = Path();
    hairPath.moveTo(-headRadius * 0.8, -headRadius * 0.2);
    hairPath.quadraticBezierTo(
        -headRadius * 0.85, -headRadius * 0.85, 0, -headRadius * 0.95);
    hairPath.quadraticBezierTo(headRadius * 0.85, -headRadius * 0.85,
        headRadius * 0.8, -headRadius * 0.2);
    hairPath.quadraticBezierTo(
        headRadius * 0.6, -headRadius * 0.65, 0, -headRadius * 0.7);
    hairPath.quadraticBezierTo(-headRadius * 0.6, -headRadius * 0.65,
        -headRadius * 0.8, -headRadius * 0.2);
    hairPath.close();
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF1A1A1A));

    // Eyebrows
    canvas.drawLine(
      Offset(-5 * scale, -3.5 * scale),
      Offset(-2 * scale, -4 * scale),
      Paint()
        ..color = const Color(0xFF2D2D2D)
        ..strokeWidth = 1.8 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(2 * scale, -4 * scale),
      Offset(5 * scale, -3.5 * scale),
      Paint()
        ..color = const Color(0xFF2D2D2D)
        ..strokeWidth = 1.8 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Eyes
    // Left eye
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-3.5 * scale, -1 * scale),
            width: 4.5 * scale,
            height: 2.8 * scale),
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(-3.5 * scale, -1 * scale), 1.3 * scale,
        Paint()..color = const Color(0xFF4A3728));
    canvas.drawCircle(Offset(-3.5 * scale, -1 * scale), 0.7 * scale,
        Paint()..color = const Color(0xFF1A1A1A));

    // Right eye
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(3.5 * scale, -1 * scale),
            width: 4.5 * scale,
            height: 2.8 * scale),
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(3.5 * scale, -1 * scale), 1.3 * scale,
        Paint()..color = const Color(0xFF4A3728));
    canvas.drawCircle(Offset(3.5 * scale, -1 * scale), 0.7 * scale,
        Paint()..color = const Color(0xFF1A1A1A));

    // Nose
    final nosePath = Path();
    nosePath.moveTo(0, 0);
    nosePath.lineTo(-1.2 * scale, 3.5 * scale);
    nosePath.quadraticBezierTo(0, 4.2 * scale, 1.2 * scale, 3.5 * scale);
    canvas.drawPath(
        nosePath,
        Paint()
          ..color = skinShadow.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Mouth
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(0, 6 * scale), width: 5 * scale, height: 2.5 * scale),
      0.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = const Color(0xFFB57B6A)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  // ==================== TANK TOP / GYM JERSEY ====================
  void drawTankTop(
      Canvas canvas, Offset center, double width, double height, double scale) {
    // Tank top body
    final tankPath = Path();
    tankPath.moveTo(center.dx - width * 0.12, center.dy);
    tankPath.quadraticBezierTo(center.dx, center.dy + height * 0.06,
        center.dx + width * 0.12, center.dy);
    tankPath.lineTo(center.dx + width * 0.32, center.dy);
    tankPath.quadraticBezierTo(
        center.dx + width * 0.42,
        center.dy + height * 0.08,
        center.dx + width * 0.38,
        center.dy + height * 0.22);
    tankPath.lineTo(center.dx + width * 0.32, center.dy + height);
    tankPath.lineTo(center.dx - width * 0.32, center.dy + height);
    tankPath.lineTo(center.dx - width * 0.38, center.dy + height * 0.22);
    tankPath.quadraticBezierTo(center.dx - width * 0.42,
        center.dy + height * 0.08, center.dx - width * 0.32, center.dy);
    tankPath.close();

    canvas.drawPath(
        tankPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [jerseyHighlight, jerseyColor, jerseyColor],
          ).createShader(
              Rect.fromCenter(center: center, width: width, height: height)));

    // Brand stripes
    canvas.drawLine(
      Offset(center.dx - width * 0.1, center.dy + height * 0.12),
      Offset(center.dx + width * 0.1, center.dy + height * 0.12),
      Paint()
        ..color = primaryColor.withOpacity(0.6)
        ..strokeWidth = 2 * scale,
    );
    canvas.drawLine(
      Offset(center.dx - width * 0.07, center.dy + height * 0.17),
      Offset(center.dx + width * 0.07, center.dy + height * 0.17),
      Paint()
        ..color = primaryColor.withOpacity(0.6)
        ..strokeWidth = 1.5 * scale,
    );

    // Gym Shirt name/logo with border - positioned lower to not block hand movement
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Body Builder',
        style: TextStyle(
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
          fontSize: 5 * scale,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Calculate text position - moved lower (0.25 instead of 0.12)
    final textX = center.dx - textPainter.width / 2;
    final textY = center.dy + height * 0.28;
    
    // Draw border rectangle around the text
    final borderPadding = 2 * scale;
    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        textX - borderPadding,
        textY - borderPadding - 2 * scale,
        textPainter.width + borderPadding * 2,
        textPainter.height + borderPadding * 2 + 2 * scale,
      ),
      Radius.circular(2 * scale),
    );
    
    // Draw border line above text
    canvas.drawLine(
      Offset(textX - borderPadding, textY - borderPadding),
      Offset(textX + textPainter.width + borderPadding, textY - borderPadding),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 1 * scale,
    );
    
    // Draw border background
    canvas.drawRRect(
      borderRect,
      Paint()..color = Colors.black.withOpacity(0.3),
    );
    
    // Draw border outline
    canvas.drawRRect(
      borderRect,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale,
    );
    
    // Draw text below the border line
    textPainter.paint(canvas, Offset(textX, textY));
    
    // Draw "B" circle below the Body Builder text
    final bRadius = 4 * scale;
    final bCenter = Offset(center.dx, textY + textPainter.height + bRadius + 3 * scale);
    
    // Circle background
    canvas.drawCircle(
      bCenter,
      bRadius,
      Paint()..color = primaryColor.withOpacity(0.8),
    );
    
    // Circle border
    canvas.drawCircle(
      bCenter,
      bRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * scale,
    );
    
    // Draw "B" letter
    final bTextPainter = TextPainter(
      text: TextSpan(
        text: 'B',
        style: TextStyle(
          color: Colors.white,
          fontSize: 5 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    bTextPainter.layout();
    bTextPainter.paint(
      canvas,
      Offset(bCenter.dx - bTextPainter.width / 2, bCenter.dy - bTextPainter.height / 2),
    );
  }

  // Draw a circle with "B" below the Body Builder text
  void drawBrandCircle(Canvas canvas, Offset center, double radius, double scale) {
    // Circle background
    final circlePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);
    
    // Circle border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    canvas.drawCircle(center, radius, borderPaint);
    
    // "B" letter inside the circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'B',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  // ==================== GYM SHORTS ====================
  void drawGymShorts(Canvas canvas, Offset hipCenter, double width,
      double height, double scale) {
    final shortsPath = Path();
    shortsPath.moveTo(hipCenter.dx - width * 0.45, hipCenter.dy);
    shortsPath.lineTo(hipCenter.dx + width * 0.45, hipCenter.dy);
    shortsPath.quadraticBezierTo(
        hipCenter.dx + width * 0.48,
        hipCenter.dy + height * 0.4,
        hipCenter.dx + width * 0.38,
        hipCenter.dy + height);
    shortsPath.lineTo(hipCenter.dx + width * 0.08, hipCenter.dy + height);
    shortsPath.quadraticBezierTo(hipCenter.dx, hipCenter.dy + height * 0.7,
        hipCenter.dx - width * 0.08, hipCenter.dy + height);
    shortsPath.lineTo(hipCenter.dx - width * 0.38, hipCenter.dy + height);
    shortsPath.quadraticBezierTo(hipCenter.dx - width * 0.48,
        hipCenter.dy + height * 0.4, hipCenter.dx - width * 0.45, hipCenter.dy);
    shortsPath.close();

    canvas.drawPath(
        shortsPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [shortsHighlight, shortsColor],
          ).createShader(Rect.fromCenter(
              center: hipCenter, width: width, height: height)));

    // Waistband
    canvas.drawRect(
      Rect.fromLTWH(hipCenter.dx - width * 0.44, hipCenter.dy, width * 0.88,
          height * 0.1),
      Paint()..color = shortsHighlight,
    );

    // Side stripes
    canvas.drawLine(
      Offset(hipCenter.dx - width * 0.38, hipCenter.dy + height * 0.12),
      Offset(hipCenter.dx - width * 0.32, hipCenter.dy + height * 0.95),
      Paint()
        ..color = primaryColor.withOpacity(0.5)
        ..strokeWidth = 2.5 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(hipCenter.dx + width * 0.38, hipCenter.dy + height * 0.12),
      Offset(hipCenter.dx + width * 0.32, hipCenter.dy + height * 0.95),
      Paint()
        ..color = primaryColor.withOpacity(0.5)
        ..strokeWidth = 2.5 * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  // ==================== COMPLETE HAND WITH FINGERS ====================
  void drawCompleteHand(
      Canvas canvas, Offset position, double size, double angle,
      {bool gripping = false}) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // Palm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size * 1.3, height: size),
        Radius.circular(size * 0.2),
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [skinHighlight, skinColor, skinShadow],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: size)),
    );

    // Palm lines
    canvas.drawLine(
        Offset(-size * 0.35, size * 0.1),
        Offset(size * 0.25, -size * 0.05),
        Paint()
          ..color = skinShadow.withOpacity(0.25)
          ..strokeWidth = 0.5);

    // Fingers
    final fingerWidths = [0.16, 0.15, 0.15, 0.14];
    final fingerLengths =
        gripping ? [0.5, 0.6, 0.55, 0.45] : [0.65, 0.8, 0.75, 0.6];
    final fingerXs = [-0.32, -0.11, 0.11, 0.32];

    for (int i = 0; i < 4; i++) {
      final fingerPath = Path();
      if (gripping) {
        // Curved gripping fingers
        fingerPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
              size * fingerXs[i] - size * fingerWidths[i] / 2,
              -size * 0.5 - size * fingerLengths[i] * 0.4,
              size * fingerWidths[i],
              size * fingerLengths[i]),
          Radius.circular(size * 0.06),
        ));
      } else {
        fingerPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
              size * fingerXs[i] - size * fingerWidths[i] / 2,
              -size * 0.5 - size * fingerLengths[i] * 0.5,
              size * fingerWidths[i],
              size * fingerLengths[i]),
          Radius.circular(size * 0.06),
        ));
      }
      canvas.drawPath(fingerPath, Paint()..color = skinColor);

      // Fingernails
      if (!gripping) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                size * fingerXs[i] - size * 0.04,
                -size * 0.5 - size * fingerLengths[i] + size * 0.02,
                size * 0.08,
                size * 0.06),
            Radius.circular(size * 0.02),
          ),
          Paint()..color = const Color(0xFFE8D4C4),
        );
      }
    }

    // Thumb
    canvas.save();
    canvas.rotate(gripping ? 0.8 : 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size * 0.45, -size * 0.08, size * 0.45, size * 0.2),
        Radius.circular(size * 0.08),
      ),
      Paint()..color = skinColor,
    );
    if (!gripping) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size * 0.82, -size * 0.03, size * 0.08, size * 0.1),
          Radius.circular(size * 0.02),
        ),
        Paint()..color = const Color(0xFFE8D4C4),
      );
    }
    canvas.restore();

    canvas.restore();
  }

  // ==================== GYM SHOE ====================
  void drawGymShoe(
      Canvas canvas, Offset ankle, Offset toeDirection, double size) {
    final angle =
        math.atan2(toeDirection.dy - ankle.dy, toeDirection.dx - ankle.dx);

    canvas.save();
    canvas.translate(ankle.dx, ankle.dy);
    canvas.rotate(angle);

    // Shoe body
    final shoePath = Path();
    shoePath.moveTo(-size * 0.2, -size * 0.2);
    shoePath.lineTo(size * 1.6, -size * 0.15);
    shoePath.quadraticBezierTo(size * 1.8, -size * 0.1, size * 1.8, size * 0.1);
    shoePath.lineTo(size * 1.7, size * 0.25);
    shoePath.lineTo(-size * 0.15, size * 0.25);
    shoePath.quadraticBezierTo(
        -size * 0.25, size * 0.1, -size * 0.2, -size * 0.2);
    shoePath.close();

    canvas.drawPath(
        shoePath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3D3D3D),
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D)
            ],
          ).createShader(
              Rect.fromLTWH(-size * 0.3, -size * 0.3, size * 2.2, size * 0.6)));

    // Sole
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size * 0.1, size * 0.18, size * 1.8, size * 0.12),
        Radius.circular(size * 0.04),
      ),
      Paint()..color = const Color(0xFF0A0A0A),
    );

    // Accent stripe
    canvas.drawLine(
      Offset(size * 0.3, -size * 0.02),
      Offset(size * 1.1, -size * 0.06),
      Paint()
        ..color = primaryColor
        ..strokeWidth = size * 0.1
        ..strokeCap = StrokeCap.round,
    );

    // Laces
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(size * 0.4 + i * size * 0.22, -size * 0.14),
        Offset(size * 0.48 + i * size * 0.22, -size * 0.02),
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = size * 0.03,
      );
    }

    canvas.restore();
  }

  // ==================== CABLE / STRING EQUIPMENT ====================
  void drawCable(Canvas canvas, Offset start, Offset end, double thickness) {
    final cablePaint = Paint()
      ..color = const Color(0xFF505050)
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, cablePaint);

    // Highlight
    canvas.drawLine(
      Offset(start.dx + 1, start.dy),
      Offset(end.dx + 1, end.dy),
      Paint()
        ..color = Colors.grey[500]!
        ..strokeWidth = thickness * 0.3,
    );
  }

  void drawCableHandle(
      Canvas canvas, Offset position, double size, double angle) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero, width: size * 2, height: size * 0.7),
        Radius.circular(size * 0.15),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4A4A4A),
            const Color(0xFF2D2D2D),
            const Color(0xFF4A4A4A)
          ],
        ).createShader(Rect.fromCenter(
            center: Offset.zero, width: size * 2, height: size)),
    );

    // Grip texture
    for (double x = -size * 0.7; x <= size * 0.7; x += size * 0.18) {
      canvas.drawLine(
          Offset(x, -size * 0.25),
          Offset(x, size * 0.25),
          Paint()
            ..color = Colors.black.withOpacity(0.25)
            ..strokeWidth = 1);
    }

    // Attachment ring
    canvas.drawCircle(Offset(-size * 1.15, 0), size * 0.2,
        Paint()..color = Colors.grey[600]!);
    canvas.drawCircle(Offset(-size * 1.15, 0), size * 0.12,
        Paint()..color = Colors.grey[800]!);

    canvas.restore();
  }
}

// ==================== CHEST EXERCISES ====================

class BenchPressPainter extends ExercisePainterBase {
  BenchPressPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorY = centerY + 85 * scale;
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, size.width, 20 * scale),
      Paint()..color = Colors.grey[900]!,
    );

    // === FLAT BENCH (view from feet - bench goes away from viewer) ===
    final benchTopY = centerY + 15 * scale; // Far end (where head is)
    final benchBottomY = centerY + 55 * scale; // Close end (where legs hang)

    // Bench pad - perspective trapezoid (narrower at top/far, wider at bottom/near)
    final benchPath = Path();
    benchPath.moveTo(centerX - 18 * scale, benchTopY);
    benchPath.lineTo(centerX + 18 * scale, benchTopY);
    benchPath.lineTo(centerX + 28 * scale, benchBottomY);
    benchPath.lineTo(centerX - 28 * scale, benchBottomY);
    benchPath.close();
    canvas.drawPath(benchPath, Paint()..color = const Color(0xFF8B0000));

    // Bench pad center highlight
    final highlightPath = Path();
    highlightPath.moveTo(centerX - 12 * scale, benchTopY + 5 * scale);
    highlightPath.lineTo(centerX + 12 * scale, benchTopY + 5 * scale);
    highlightPath.lineTo(centerX + 20 * scale, benchBottomY - 5 * scale);
    highlightPath.lineTo(centerX - 20 * scale, benchBottomY - 5 * scale);
    highlightPath.close();
    canvas.drawPath(highlightPath, Paint()..color = const Color(0xFFAA2525));

    // Bench front edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 30 * scale, benchBottomY, 60 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = const Color(0xFF6B0000),
    );

    // Bench legs
    canvas.drawRect(
      Rect.fromLTWH(centerX - 26 * scale, benchBottomY + 4 * scale, 6 * scale,
          floorY - benchBottomY - 4 * scale),
      Paint()..color = Colors.grey[600]!,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX + 20 * scale, benchBottomY + 4 * scale, 6 * scale,
          floorY - benchBottomY - 4 * scale),
      Paint()..color = Colors.grey[600]!,
    );

    // === MAN LYING ON BENCH (view from feet) ===
    // The body is drawn ON the bench, lying flat

    // === BODY LYING ON BENCH (foreshortened - appears compressed vertically) ===

    // --- HEAD at far end (small due to perspective) ---
    final headY = benchTopY - 5 * scale;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX, headY),
          width: 16 * scale,
          height: 18 * scale),
      Paint()..color = skinColor,
    );
    // Hair
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(centerX, headY - 5 * scale),
          width: 16 * scale,
          height: 10 * scale),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF2C1810),
    );
    // Eyes looking up
    canvas.drawCircle(Offset(centerX - 3 * scale, headY - 1 * scale), 1.5 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(centerX + 3 * scale, headY - 1 * scale), 1.5 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(centerX - 3 * scale, headY - 2 * scale), 0.8 * scale,
        Paint()..color = Colors.brown[800]!);
    canvas.drawCircle(Offset(centerX + 3 * scale, headY - 2 * scale), 0.8 * scale,
        Paint()..color = Colors.brown[800]!);

    // --- SHOULDERS/UPPER CHEST (on bench) ---
    final shoulderY = benchTopY + 12 * scale;
    // Tank top straps visible, shoulders skin showing
    // Left shoulder
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX - 20 * scale, shoulderY),
          width: 18 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );
    // Right shoulder
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 20 * scale, shoulderY),
          width: 18 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );

    // --- CHEST/TORSO (lying on bench - foreshortened) ---
    final chestY = benchTopY + 22 * scale;
    // Tank top body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, chestY + 8 * scale),
            width: 44 * scale,
            height: 30 * scale),
        Radius.circular(6 * scale),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Visible pecs at top of tank top
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX - 12 * scale, chestY),
          width: 20 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 12 * scale, chestY),
          width: 20 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );

    // Chest muscle highlights
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 12 * scale, chestY),
        14 * scale * (0.8 + progress * 0.3),
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 12 * scale, chestY),
        14 * scale * (0.8 + progress * 0.3),
        primaryColor);

    // --- HIPS/SHORTS (on bench near bottom) ---
    final hipY = benchBottomY - 12 * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, hipY),
            width: 40 * scale,
            height: 18 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = const Color(0xFF2D3436),
    );

    // --- LEGS hanging off end of bench ---
    final legStartY = benchBottomY;

    // Left thigh
    canvas.drawLine(
      Offset(centerX - 12 * scale, legStartY),
      Offset(centerX - 16 * scale, legStartY + 22 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Right thigh
    canvas.drawLine(
      Offset(centerX + 12 * scale, legStartY),
      Offset(centerX + 16 * scale, legStartY + 22 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Feet (at bottom, closest to viewer)
    drawGymShoe(canvas, Offset(centerX - 16 * scale, legStartY + 20 * scale),
        Offset(centerX - 28 * scale, floorY - 2 * scale), 8 * scale);
    drawGymShoe(canvas, Offset(centerX + 16 * scale, legStartY + 20 * scale),
        Offset(centerX + 28 * scale, floorY - 2 * scale), 8 * scale);

    // === BARBELL MOVEMENT ===
    // progress 0 = arms extended (bar up), progress 1 = bar at chest (down)
    final barExtendedY = chestY - 50 * scale;
    final barAtChestY = chestY - 5 * scale;
    final barbellY = barExtendedY + (barAtChestY - barExtendedY) * progress;

    // === ARMS reaching up to grip bar ===
    final armShoulderY = shoulderY;
    final elbowSpread = 30 * scale + (progress * 15 * scale);

    // LEFT ARM
    final leftShoulderX = centerX - 20 * scale;
    final leftElbowX = centerX - elbowSpread;
    final leftElbowY = armShoulderY - 18 * scale + (progress * 16 * scale);
    final leftHandX = centerX - 35 * scale;

    canvas.drawLine(
      Offset(leftShoulderX, armShoulderY),
      Offset(leftElbowX, leftElbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(leftElbowX, leftElbowY),
      Offset(leftHandX, barbellY + 4 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Left hand
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(leftHandX, barbellY + 3 * scale),
          width: 10 * scale,
          height: 8 * scale),
      Paint()..color = skinColor,
    );

    // RIGHT ARM
    final rightShoulderX = centerX + 20 * scale;
    final rightElbowX = centerX + elbowSpread;
    final rightElbowY = armShoulderY - 18 * scale + (progress * 16 * scale);
    final rightHandX = centerX + 35 * scale;

    canvas.drawLine(
      Offset(rightShoulderX, armShoulderY),
      Offset(rightElbowX, rightElbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(rightElbowX, rightElbowY),
      Offset(rightHandX, barbellY + 4 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Right hand
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(rightHandX, barbellY + 3 * scale),
          width: 10 * scale,
          height: 8 * scale),
      Paint()..color = skinColor,
    );

    // === BARBELL with VERTICAL PLATES (circles from this view) ===
    final barThickness = 4 * scale;

    // Main bar (horizontal)
    canvas.drawLine(
      Offset(centerX - 75 * scale, barbellY),
      Offset(centerX + 75 * scale, barbellY),
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = barThickness
        ..strokeCap = StrokeCap.round,
    );
    // Bar highlight
    canvas.drawLine(
      Offset(centerX - 70 * scale, barbellY - 1.5 * scale),
      Offset(centerX + 70 * scale, barbellY - 1.5 * scale),
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 1 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === LEFT SIDE PLATES (vertical circles) ===
    // Outer plate (45lb - blue, largest)
    canvas.drawCircle(
      Offset(centerX - 68 * scale, barbellY),
      14 * scale,
      Paint()..color = const Color(0xFF1565C0),
    );
    canvas.drawCircle(
      Offset(centerX - 68 * scale, barbellY),
      12 * scale,
      Paint()
        ..color = const Color(0xFF1E88E5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );
    canvas.drawCircle(
      Offset(centerX - 68 * scale, barbellY),
      3 * scale,
      Paint()..color = Colors.grey[700]!,
    );

    // Inner plate (25lb - green, smaller)
    canvas.drawCircle(
      Offset(centerX - 55 * scale, barbellY),
      11 * scale,
      Paint()..color = const Color(0xFF388E3C),
    );
    canvas.drawCircle(
      Offset(centerX - 55 * scale, barbellY),
      9 * scale,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale,
    );
    canvas.drawCircle(
      Offset(centerX - 55 * scale, barbellY),
      2.5 * scale,
      Paint()..color = Colors.grey[700]!,
    );

    // === RIGHT SIDE PLATES (vertical circles) ===
    // Outer plate (45lb - blue, largest)
    canvas.drawCircle(
      Offset(centerX + 68 * scale, barbellY),
      14 * scale,
      Paint()..color = const Color(0xFF1565C0),
    );
    canvas.drawCircle(
      Offset(centerX + 68 * scale, barbellY),
      12 * scale,
      Paint()
        ..color = const Color(0xFF1E88E5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );
    canvas.drawCircle(
      Offset(centerX + 68 * scale, barbellY),
      3 * scale,
      Paint()..color = Colors.grey[700]!,
    );

    // Inner plate (25lb - green, smaller)
    canvas.drawCircle(
      Offset(centerX + 55 * scale, barbellY),
      11 * scale,
      Paint()..color = const Color(0xFF388E3C),
    );
    canvas.drawCircle(
      Offset(centerX + 55 * scale, barbellY),
      9 * scale,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale,
    );
    canvas.drawCircle(
      Offset(centerX + 55 * scale, barbellY),
      2.5 * scale,
      Paint()..color = Colors.grey[700]!,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class InclinePressPainter extends ExercisePainterBase {
  InclinePressPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Gym floor
    final floorY = centerY + 65 * scale;
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, size.width, 40 * scale),
      Paint()..color = Colors.grey[900]!,
    );

    // === INCLINE BENCH (drawn FIRST so body appears ON TOP of it) ===
    const inclineAngle = 0.45; // ~25 degrees
    final benchFramePaint = Paint()..color = Colors.grey[600]!;

    // Calculate bench position
    final benchCenterX = centerX;
    final benchCenterY = centerY + 15 * scale;

    // Bench frame legs (draw these first - behind everything)
    // Back leg (taller, on right for incline going up-right)
    canvas.drawRect(
      Rect.fromLTWH(centerX + 30 * scale, benchCenterY - 20 * scale, 8 * scale,
          floorY - benchCenterY + 20 * scale),
      benchFramePaint,
    );
    // Front leg (shorter, on left)
    canvas.drawRect(
      Rect.fromLTWH(centerX - 35 * scale, benchCenterY + 25 * scale, 8 * scale,
          floorY - benchCenterY - 25 * scale),
      benchFramePaint,
    );
    // Horizontal support bar
    canvas.drawRect(
      Rect.fromLTWH(centerX - 35 * scale, benchCenterY + 25 * scale, 73 * scale,
          6 * scale),
      benchFramePaint,
    );

    // Inclined back pad (the part the back rests on)
    canvas.save();
    canvas.translate(benchCenterX + 5 * scale, benchCenterY);
    canvas.rotate(-inclineAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-35 * scale, -8 * scale, 70 * scale, 16 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = const Color(0xFF8B0000),
    );
    // Pad highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-32 * scale, -5 * scale, 64 * scale, 5 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = const Color(0xFFAA2020),
    );
    canvas.restore();

    // Seat pad (horizontal part where butt sits)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 38 * scale, benchCenterY + 18 * scale,
            30 * scale, 10 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = const Color(0xFF8B0000),
    );

    // === FIGURE SITTING ON INCLINE BENCH (body ON TOP of bench) ===
    // Position the body so it appears to be resting on the bench pad

    // Hip/butt on the seat
    final hipX = centerX - 22 * scale;
    final hipY = benchCenterY + 12 * scale;

    // Calculate body along incline (going UP to the RIGHT)
    final torsoLength = 45 * scale;
    final shoulderX = hipX + torsoLength * math.cos(inclineAngle);
    final shoulderY = hipY - torsoLength * math.sin(inclineAngle);

    // Head at top of incline
    final neckLength = 12 * scale;
    final headX = shoulderX + neckLength * math.cos(inclineAngle);
    final headY = shoulderY - neckLength * math.sin(inclineAngle) - 10 * scale;

    // === Draw body parts (ON TOP of bench) ===

    // Torso (tank top) along incline
    canvas.save();
    canvas.translate((hipX + shoulderX) / 2, (hipY + shoulderY) / 2);
    canvas.rotate(-inclineAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-25 * scale, -14 * scale, 50 * scale, 28 * scale),
        Radius.circular(6 * scale),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );
    canvas.restore();

    // Shoulder (skin showing)
    canvas.drawCircle(
        Offset(shoulderX, shoulderY), 12 * scale, Paint()..color = skinColor);

    // Neck connecting head to shoulder
    canvas.drawLine(
      Offset(shoulderX + 5 * scale, shoulderY - 5 * scale),
      Offset(headX - 3 * scale, headY + 10 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Head (profile, tilted back on incline)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX, headY), width: 22 * scale, height: 24 * scale),
      Paint()..color = skinColor,
    );
    // Hair
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(headX + 5 * scale, headY - 3 * scale),
          width: 20 * scale,
          height: 18 * scale),
      -math.pi * 0.3,
      math.pi * 1.0,
      true,
      Paint()..color = const Color(0xFF2C1810),
    );
    // Eye
    canvas.drawCircle(Offset(headX - 4 * scale, headY - 2 * scale), 2.5 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(headX - 4 * scale, headY - 3 * scale), 1.2 * scale,
        Paint()..color = Colors.brown[800]!);
    // Ear
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 10 * scale, headY + 2 * scale),
          width: 5 * scale,
          height: 8 * scale),
      Paint()..color = skinColor,
    );

    // Gym shorts at hip area
    drawGymShorts(canvas, Offset(hipX + 3 * scale, hipY + 3 * scale),
        24 * scale, 16 * scale, scale);

    // === LEG (from hip down to floor) ===
    final kneeX = hipX - 10 * scale;
    final kneeY = hipY + 38 * scale;
    final ankleX = kneeX + 10 * scale;
    final ankleY = floorY - 8 * scale;

    // Thigh from hip
    canvas.drawLine(
      Offset(hipX, hipY + 12 * scale),
      Offset(kneeX, kneeY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Knee
    canvas.drawCircle(
        Offset(kneeX, kneeY), 6 * scale, Paint()..color = skinColor);
    // Calf
    canvas.drawLine(
      Offset(kneeX, kneeY),
      Offset(ankleX, ankleY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Shoe
    drawGymShoe(canvas, Offset(ankleX, ankleY),
        Offset(ankleX + 15 * scale, floorY - 2 * scale), 6 * scale);

    // === DUMBBELL (pressing upward) ===
    final pressDistance = progress * 25 * scale;
    final dumbbellX = shoulderX + 8 * scale;
    final dumbbellY = shoulderY - 25 * scale - pressDistance;

    // Dumbbell (end-on circle view)
    canvas.drawCircle(Offset(dumbbellX, dumbbellY), 14 * scale,
        Paint()..color = Colors.grey[700]!);
    canvas.drawCircle(Offset(dumbbellX, dumbbellY), 11 * scale,
        Paint()..color = Colors.grey[800]!);
    canvas.drawCircle(Offset(dumbbellX, dumbbellY), 4 * scale,
        Paint()..color = Colors.grey[500]!);

    // === ARM pressing dumbbell ===
    final elbowX = shoulderX + 15 * scale - progress * 5 * scale;
    final elbowY =
        (shoulderY + dumbbellY) / 2 + 5 * scale + progress * 5 * scale;

    // Upper arm
    canvas.drawLine(
      Offset(shoulderX + 5 * scale, shoulderY - 5 * scale),
      Offset(elbowX, elbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Forearm
    canvas.drawLine(
      Offset(elbowX, elbowY),
      Offset(dumbbellX, dumbbellY + 10 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Hand
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(dumbbellX, dumbbellY + 10 * scale),
          width: 10 * scale,
          height: 8 * scale),
      Paint()..color = skinColor,
    );

    // Muscle highlights
    drawMuscleHighlight(canvas, Offset(elbowX - 3 * scale, elbowY - 5 * scale),
        10 * scale, primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset((hipX + shoulderX) / 2 + 5 * scale,
            (hipY + shoulderY) / 2 - 5 * scale),
        14 * scale * (0.7 + progress * 0.3),
        primaryColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CableFlyePainter extends ExercisePainterBase {
  CableFlyePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Cable towers with pulleys
    final towerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.grey[700]!, Colors.grey[500]!, Colors.grey[700]!],
      ).createShader(Rect.fromLTWH(10, 10, 15 * scale, size.height - 40));
    canvas.drawRect(
        Rect.fromLTWH(10, 10, 15 * scale, size.height - 40), towerPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width - 25, 10, 15 * scale, size.height - 40),
        towerPaint);

    // Pulleys at top
    canvas.drawCircle(
        Offset(17, 25), 8 * scale, Paint()..color = Colors.grey[300]!);
    canvas.drawCircle(Offset(size.width - 17, 25), 8 * scale,
        Paint()..color = Colors.grey[300]!);

    // Head with detailed features
    drawCompleteHead(canvas, Offset(centerX, centerY - 50 * scale), scale,
        rotation: 0);

    // Tank top torso
    drawTankTop(canvas, Offset(centerX, centerY - 25 * scale), 48 * scale,
        55 * scale, scale);

    // Chest highlight
    drawMuscleHighlight(canvas, Offset(centerX, centerY - 25 * scale),
        20 * scale, primaryColor);

    // Gym shorts
    drawGymShorts(canvas, Offset(centerX, centerY + 15 * scale), 40 * scale,
        25 * scale, scale);

    // Muscular legs (slight stance)
    drawMuscularLeg(
        canvas,
        Offset(centerX - 8 * scale, centerY + 20 * scale),
        Offset(centerX - 15 * scale, centerY + 45 * scale),
        Offset(centerX - 12 * scale, centerY + 68 * scale),
        11 * scale);
    drawMuscularLeg(
        canvas,
        Offset(centerX + 8 * scale, centerY + 20 * scale),
        Offset(centerX + 15 * scale, centerY + 45 * scale),
        Offset(centerX + 12 * scale, centerY + 68 * scale),
        11 * scale);

    // Gym shoes
    drawGymShoe(
        canvas,
        Offset(centerX - 12 * scale, centerY + 68 * scale),
        Offset(centerX - 12 * scale + 12 * scale, centerY + 72 * scale),
        7 * scale);
    drawGymShoe(
        canvas,
        Offset(centerX + 12 * scale, centerY + 68 * scale),
        Offset(centerX + 12 * scale + 12 * scale, centerY + 72 * scale),
        7 * scale);

    // Arms coming together in flye motion
    final armSpread = 50 * scale - (progress * 45 * scale);
    final handY = centerY - 25 * scale;

    // Muscular arms with chest flex
    drawMuscularArm(
        canvas,
        Offset(centerX - 15 * scale, centerY - 35 * scale),
        Offset(centerX - armSpread * 0.6, handY - 10 * scale),
        Offset(centerX - armSpread, handY),
        9 * scale,
        0.4 + progress * 0.4);
    drawMuscularArm(
        canvas,
        Offset(centerX + 15 * scale, centerY - 35 * scale),
        Offset(centerX + armSpread * 0.6, handY - 10 * scale),
        Offset(centerX + armSpread, handY),
        9 * scale,
        0.4 + progress * 0.4);

    // Cables with realistic look
    drawCable(
        canvas, Offset(17, 25), Offset(centerX - armSpread, handY), 2 * scale);
    drawCable(canvas, Offset(size.width - 17, 25),
        Offset(centerX + armSpread, handY), 2 * scale);

    // Cable handles
    drawCableHandle(canvas, Offset(centerX - armSpread, handY), 6 * scale, 0);
    drawCableHandle(canvas, Offset(centerX + armSpread, handY), 6 * scale, 0);

    // Complete hands gripping handles
    drawCompleteHand(canvas, Offset(centerX - armSpread, handY), 5 * scale, 0,
        gripping: true);
    drawCompleteHand(canvas, Offset(centerX + armSpread, handY), 5 * scale, 0,
        gripping: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== INCLINE CABLE FLY ====================

class InclineCableFlyPainter extends ExercisePainterBase {
  InclineCableFlyPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorY = centerY + 85 * scale;
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, size.width, 20 * scale),
      Paint()..color = Colors.grey[900]!,
    );

    // Floor line highlight
    canvas.drawLine(
      Offset(0, floorY),
      Offset(size.width, floorY),
      Paint()
        ..color = Colors.grey[700]!
        ..strokeWidth = 1.5 * scale,
    );

    // ============================================================
    // CABLE TOWERS (left and right, behind everything)
    // ============================================================
    final towerWidth = 14 * scale;
    const towerLeftX = 4.0;
    final towerRightX = size.width - 4 - towerWidth;

    // Left tower frame
    final towerGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.grey[800]!, Colors.grey[600]!, Colors.grey[800]!],
      ).createShader(
          Rect.fromLTWH(towerLeftX, 5, towerWidth, floorY - 5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(towerLeftX, 5, towerWidth, floorY - 5),
        Radius.circular(2 * scale),
      ),
      towerGrad,
    );

    // Right tower frame
    final towerGradR = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.grey[800]!, Colors.grey[600]!, Colors.grey[800]!],
      ).createShader(
          Rect.fromLTWH(towerRightX, 5, towerWidth, floorY - 5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(towerRightX, 5, towerWidth, floorY - 5),
        Radius.circular(2 * scale),
      ),
      towerGradR,
    );

    // Weight stacks on each tower
    for (int i = 0; i < 7; i++) {
      final stackY = 14.0 + i * 10 * scale;
      // Left
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              towerLeftX + 1.5, stackY, towerWidth - 3, 8 * scale),
          Radius.circular(1 * scale),
        ),
        Paint()..color = Colors.grey[850] ?? Colors.grey[900]!,
      );
      canvas.drawLine(
        Offset(towerLeftX + 3, stackY + 1.5),
        Offset(towerLeftX + towerWidth - 3, stackY + 1.5),
        Paint()
          ..color = Colors.grey[500]!
          ..strokeWidth = 0.8 * scale,
      );
      // Right
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              towerRightX + 1.5, stackY, towerWidth - 3, 8 * scale),
          Radius.circular(1 * scale),
        ),
        Paint()..color = Colors.grey[850] ?? Colors.grey[900]!,
      );
      canvas.drawLine(
        Offset(towerRightX + 3, stackY + 1.5),
        Offset(towerRightX + towerWidth - 3, stackY + 1.5),
        Paint()
          ..color = Colors.grey[500]!
          ..strokeWidth = 0.8 * scale,
      );
    }

    // Pulleys at BOTTOM of towers (low cable for incline fly)
    final pulleyLeftX = towerLeftX + towerWidth / 2;
    final pulleyRightX = towerRightX + towerWidth / 2;
    final pulleyY = floorY - 10 * scale;

    // Left pulley
    canvas.drawCircle(Offset(pulleyLeftX, pulleyY), 7 * scale,
        Paint()..color = Colors.grey[400]!);
    canvas.drawCircle(Offset(pulleyLeftX, pulleyY), 5 * scale,
        Paint()..color = Colors.grey[600]!);
    canvas.drawCircle(Offset(pulleyLeftX, pulleyY), 2 * scale,
        Paint()..color = Colors.grey[300]!);

    // Right pulley
    canvas.drawCircle(Offset(pulleyRightX, pulleyY), 7 * scale,
        Paint()..color = Colors.grey[400]!);
    canvas.drawCircle(Offset(pulleyRightX, pulleyY), 5 * scale,
        Paint()..color = Colors.grey[600]!);
    canvas.drawCircle(Offset(pulleyRightX, pulleyY), 2 * scale,
        Paint()..color = Colors.grey[300]!);

    // ============================================================
    // INCLINE BENCH (front-facing / from-feet perspective)
    // same style as BenchPressPainter but inclined
    // ============================================================
    final benchTopY = centerY + 5 * scale; // Far end (head rests here)
    final benchBottomY = centerY + 48 * scale; // Close end (seat)

    // Back pad - perspective trapezoid (narrower at top, wider at bottom)
    final padPath = Path();
    padPath.moveTo(centerX - 16 * scale, benchTopY);
    padPath.lineTo(centerX + 16 * scale, benchTopY);
    padPath.lineTo(centerX + 24 * scale, benchBottomY - 14 * scale);
    padPath.lineTo(centerX - 24 * scale, benchBottomY - 14 * scale);
    padPath.close();
    canvas.drawPath(padPath, Paint()..color = const Color(0xFF8B0000));

    // Pad highlight
    final padHighlight = Path();
    padHighlight.moveTo(centerX - 10 * scale, benchTopY + 4 * scale);
    padHighlight.lineTo(centerX + 10 * scale, benchTopY + 4 * scale);
    padHighlight.lineTo(centerX + 17 * scale, benchBottomY - 18 * scale);
    padHighlight.lineTo(centerX - 17 * scale, benchBottomY - 18 * scale);
    padHighlight.close();
    canvas.drawPath(padHighlight, Paint()..color = const Color(0xFFAA2525));

    // Seat pad (wider horizontal strip)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 26 * scale, benchBottomY - 14 * scale,
            52 * scale, 14 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = const Color(0xFF6B0000),
    );

    // Front edge of bench
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 28 * scale, benchBottomY, 56 * scale, 5 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = const Color(0xFF5A0000),
    );

    // Bench legs
    canvas.drawRect(
      Rect.fromLTWH(centerX - 24 * scale, benchBottomY + 3 * scale,
          5 * scale, floorY - benchBottomY - 3 * scale),
      Paint()..color = Colors.grey[600]!,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX + 19 * scale, benchBottomY + 3 * scale,
          5 * scale, floorY - benchBottomY - 3 * scale),
      Paint()..color = Colors.grey[600]!,
    );

    // Incline indicator — small angular support behind pad
    canvas.drawLine(
      Offset(centerX - 18 * scale, benchTopY + 2 * scale),
      Offset(centerX - 22 * scale, benchBottomY - 16 * scale),
      Paint()
        ..color = Colors.grey[600]!
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(centerX + 18 * scale, benchTopY + 2 * scale),
      Offset(centerX + 22 * scale, benchBottomY - 16 * scale),
      Paint()
        ..color = Colors.grey[600]!
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round,
    );

    // ============================================================
    // MAN LYING ON INCLINE BENCH (front / from-feet view)
    // ============================================================

    // --- HEAD at far end (small due to perspective / incline) ---
    final headY = benchTopY - 8 * scale;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX, headY),
          width: 16 * scale,
          height: 18 * scale),
      Paint()..color = skinColor,
    );
    // Hair
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(centerX, headY - 5 * scale),
          width: 16 * scale,
          height: 10 * scale),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF2C1810),
    );
    // Eyes looking up at hands
    canvas.drawCircle(Offset(centerX - 3 * scale, headY - 1 * scale),
        1.5 * scale, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(centerX + 3 * scale, headY - 1 * scale),
        1.5 * scale, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(centerX - 3 * scale, headY - 2 * scale),
        0.8 * scale, Paint()..color = Colors.brown[800]!);
    canvas.drawCircle(Offset(centerX + 3 * scale, headY - 2 * scale),
        0.8 * scale, Paint()..color = Colors.brown[800]!);
    // Mouth
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(centerX, headY + 4 * scale),
          width: 5 * scale,
          height: 3 * scale),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF8B6550)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 * scale,
    );

    // --- SHOULDERS (visible on either side of bench) ---
    final shoulderY = benchTopY + 10 * scale;
    // Left shoulder (skin deltoid)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX - 22 * scale, shoulderY),
          width: 18 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );
    // Right shoulder
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 22 * scale, shoulderY),
          width: 18 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );

    // --- CHEST / TORSO (foreshortened on bench) ---
    final chestY = benchTopY + 18 * scale;
    // Tank top body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, chestY + 8 * scale),
            width: 44 * scale,
            height: 28 * scale),
        Radius.circular(6 * scale),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Upper pecs visible above tank top neckline
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX - 12 * scale, chestY),
          width: 20 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 12 * scale, chestY),
          width: 20 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );

    // Chest muscle highlights (glow when squeezed)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 12 * scale, chestY),
        14 * scale * (0.7 + progress * 0.4),
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 12 * scale, chestY),
        14 * scale * (0.7 + progress * 0.4),
        primaryColor);

    // --- HIPS / GYM SHORTS ---
    final hipY = benchBottomY - 10 * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX, hipY),
            width: 40 * scale,
            height: 16 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = const Color(0xFF2D3436),
    );

    // --- LEGS (going down from bench, FEET FLAT ON FLOOR) ---
    final legStartY = benchBottomY;

    // Left thigh
    canvas.drawLine(
      Offset(centerX - 12 * scale, legStartY),
      Offset(centerX - 18 * scale, legStartY + 18 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Left calf going to floor
    canvas.drawLine(
      Offset(centerX - 18 * scale, legStartY + 18 * scale),
      Offset(centerX - 16 * scale, floorY - 8 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Right thigh
    canvas.drawLine(
      Offset(centerX + 12 * scale, legStartY),
      Offset(centerX + 18 * scale, legStartY + 18 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Right calf going to floor
    canvas.drawLine(
      Offset(centerX + 18 * scale, legStartY + 18 * scale),
      Offset(centerX + 16 * scale, floorY - 8 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Feet flat on floor (front-facing shoe ovals)
    drawGymShoe(
        canvas,
        Offset(centerX - 16 * scale, floorY - 8 * scale),
        Offset(centerX - 26 * scale, floorY - 1 * scale),
        7 * scale);
    drawGymShoe(
        canvas,
        Offset(centerX + 16 * scale, floorY - 8 * scale),
        Offset(centerX + 26 * scale, floorY - 1 * scale),
        7 * scale);

    // ============================================================
    // ARMS & FLY MOTION
    // progress 0 = arms wide open / back (stretched)
    // progress 1 = arms together above chest (squeezed)
    // ============================================================
    final armShoulderY = shoulderY;

    // Arm horizontal spread: wide at start, near-zero at peak squeeze
    final maxSpread = 70 * scale;
    final minSpread = 6 * scale;
    final armSpread = maxSpread - (maxSpread - minSpread) * progress;

    // Arm vertical lift: hands start low behind and come up over chest
    final handStartY = chestY + 10 * scale; // Behind/low when stretched
    final handEndY = chestY - 40 * scale; // Above chest when squeezed
    final handY = handStartY + (handEndY - handStartY) * progress;

    // Elbows bow outward with slight bend
    final elbowSpread = armSpread * 0.7 + 8 * scale;
    final elbowY = (armShoulderY + handY) / 2 + 6 * scale * (1 - progress);

    // LEFT ARM-------
    final leftShoulderPt = Offset(centerX - 22 * scale, armShoulderY);
    final leftElbow = Offset(centerX - elbowSpread, elbowY);
    final leftHand = Offset(centerX - armSpread, handY);

    drawMuscularArm(canvas, leftShoulderPt, leftElbow, leftHand,
        9 * scale, 0.3 + progress * 0.5);

    // RIGHT ARM-------
    final rightShoulderPt = Offset(centerX + 22 * scale, armShoulderY);
    final rightElbow = Offset(centerX + elbowSpread, elbowY);
    final rightHand = Offset(centerX + armSpread, handY);

    drawMuscularArm(canvas, rightShoulderPt, rightElbow, rightHand,
        9 * scale, 0.3 + progress * 0.5);

    // ============================================================
    // CABLES from low pulleys up to the hands
    // ============================================================
    drawCable(canvas, Offset(pulleyLeftX, pulleyY), leftHand, 2 * scale);
    drawCable(canvas, Offset(pulleyRightX, pulleyY), rightHand, 2 * scale);

    // CABLE HANDLES in hands
    final leftAngle = math.atan2(
        leftHand.dy - leftElbow.dy, leftHand.dx - leftElbow.dx);
    final rightAngle = math.atan2(
        rightHand.dy - rightElbow.dy, rightHand.dx - rightElbow.dx);

    drawCableHandle(canvas, leftHand, 5 * scale, leftAngle + math.pi / 2);
    drawCableHandle(canvas, rightHand, 5 * scale, rightAngle + math.pi / 2);

    // Hands gripping handles
    drawCompleteHand(
        canvas, leftHand, 5 * scale, leftAngle, gripping: true);
    drawCompleteHand(
        canvas, rightHand, 5 * scale, rightAngle, gripping: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PushUpPainter extends ExercisePainterBase {
  PushUpPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Ground (gym floor)
    final groundY = centerY + 50 * scale;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 50 * scale),
      Paint()..color = Colors.grey[900]!,
    );

    // === SIDE VIEW PUSH-UP (head LEFT, feet RIGHT) ===
    // Body drops when progress increases (lowering phase)
    final bodyDrop = progress * 20 * scale;

    // === KEY BODY POSITIONS (HEAD ON LEFT, FEET ON RIGHT) ===
    // Head at far left
    final headX = centerX - 55 * scale;
    final headY = centerY - 15 * scale + bodyDrop;

    // Hand directly under shoulders (left side)
    final handX = centerX - 25 * scale;
    final handY = groundY - 5 * scale;

    // Shoulder above hand
    final shoulderX = handX + 5 * scale;
    final shoulderY = centerY - 10 * scale + bodyDrop;

    // Hip position (forms straight plank line, toward right)
    final hipX = centerX + 35 * scale;
    final hipY = shoulderY + 6 * scale;

    // Feet position (far right)
    final feetX = centerX + 70 * scale;
    final feetY = groundY - 8 * scale;

    // Calculate neck angle first to align head properly
    final neckAngle = math.atan2(
        shoulderY - 2 * scale - headY, shoulderX - 5 * scale - headX);

    // === HEAD (profile view, aligned with neck direction, looking at floor) ===
    canvas.save();
    canvas.translate(headX, headY);
    // Rotate head to align with neck, then tilt slightly down to look at floor
    canvas.rotate(neckAngle - 0.3);
    // Head shape
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: 20 * scale, height: 24 * scale),
      Paint()..color = skinColor,
    );
    // Hair - fuller coverage on top and back of head
    final hairPath = Path();
    hairPath.moveTo(-8 * scale, -8 * scale);
    hairPath.quadraticBezierTo(-10 * scale, -14 * scale, 0, -14 * scale);
    hairPath.quadraticBezierTo(12 * scale, -14 * scale, 12 * scale, -5 * scale);
    hairPath.quadraticBezierTo(13 * scale, 2 * scale, 10 * scale, 6 * scale);
    hairPath.quadraticBezierTo(8 * scale, 0, 8 * scale, -6 * scale);
    hairPath.quadraticBezierTo(6 * scale, -10 * scale, 0, -10 * scale);
    hairPath.quadraticBezierTo(-6 * scale, -10 * scale, -8 * scale, -8 * scale);
    hairPath.close();
    canvas.drawPath(hairPath, Paint()..color = const Color(0xFF1A0F0A));
    // Hair texture lines
    canvas.drawLine(
      Offset(2 * scale, -12 * scale),
      Offset(6 * scale, -8 * scale),
      Paint()
        ..color = const Color(0xFF2C1810)
        ..strokeWidth = 1.5 * scale,
    );
    canvas.drawLine(
      Offset(-2 * scale, -12 * scale),
      Offset(0, -9 * scale),
      Paint()
        ..color = const Color(0xFF2C1810)
        ..strokeWidth = 1.5 * scale,
    );
    // Eye looking at floor
    canvas.drawCircle(Offset(-7 * scale, 4 * scale), 2.5 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(-7 * scale, 5 * scale), 1.3 * scale,
        Paint()..color = Colors.brown[800]!);
    // Ear
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(8 * scale, 0), width: 5 * scale, height: 8 * scale),
      Paint()..color = skinColor,
    );
    canvas.restore();

    // Neck (thicker, muscular) - align with head rotation
    final neckStartX = headX + math.cos(neckAngle - 0.3) * 8 * scale + math.sin(neckAngle - 0.3) * 10 * scale;
    final neckStartY = headY + math.sin(neckAngle - 0.3) * 8 * scale + math.cos(neckAngle - 0.3) * 10 * scale;
    canvas.drawLine(
      Offset(neckStartX, neckStartY),
      Offset(shoulderX - 5 * scale, shoulderY - 2 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Neck muscle definition
    canvas.drawLine(
      Offset(neckStartX + 2 * scale, neckStartY + 2 * scale),
      Offset(shoulderX - 3 * scale, shoulderY),
      Paint()
        ..color = skinShadow
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === TORSO (horizontal plank, head to left, hip to right) ===
    final torsoCenterX = (shoulderX + hipX) / 2;
    final torsoCenterY = (shoulderY + hipY) / 2;
    final bodyAngle = math.atan2(hipY - shoulderY, hipX - shoulderX);

    canvas.save();
    canvas.translate(torsoCenterX, torsoCenterY);
    canvas.rotate(bodyAngle);
    // Tank top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-35 * scale, -13 * scale, 70 * scale, 26 * scale),
        Radius.circular(6 * scale),
      ),
      Paint()..color = const Color(0xFF1A1A2E),
    );
    canvas.restore();

    // Shoulder/chest area
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(shoulderX, shoulderY),
          width: 22 * scale,
          height: 18 * scale),
      Paint()..color = skinColor,
    );

    // Chest highlight
    drawMuscleHighlight(
        canvas,
        Offset(shoulderX + 8 * scale, shoulderY + 2 * scale),
        14 * scale,
        primaryColor);

    // === ARM (under body, pressing up) ===
    final elbowBend = progress * 0.5;
    final elbowX = shoulderX - 8 * scale - elbowBend * 8 * scale;
    final elbowY = (shoulderY + handY) / 2 + elbowBend * 10 * scale;

    // Upper arm
    canvas.drawLine(
      Offset(shoulderX - 5 * scale, shoulderY + 8 * scale),
      Offset(elbowX, elbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Forearm to hand
    canvas.drawLine(
      Offset(elbowX, elbowY),
      Offset(handX, handY - 4 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Tricep highlight
    if (progress > 0.2) {
      drawMuscleHighlight(
          canvas,
          Offset(elbowX + 3 * scale, elbowY - 6 * scale),
          10 * scale,
          primaryColor);
    }

    // Hand flat on ground
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(handX, handY - 2 * scale),
          width: 14 * scale,
          height: 8 * scale),
      Paint()..color = skinColor,
    );
    // Fingers
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(handX - 5 * scale + i * 3.5 * scale, handY - 2 * scale),
        Offset(handX - 6 * scale + i * 3.5 * scale, handY + 4 * scale),
        Paint()
          ..color = skinColor
          ..strokeWidth = 2.5 * scale
          ..strokeCap = StrokeCap.round,
      );
    }

    // === GYM SHORTS ===
    drawGymShorts(canvas, Offset(hipX - 8 * scale, hipY + 2 * scale),
        28 * scale, 16 * scale, scale);

    // === LEG (extending from hip with knee bent DOWN, toes toward head) ===
    // Glute
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hipX + 5 * scale, hipY + 5 * scale),
          width: 18 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );

    // Thigh (going back and DOWN toward knee)
    final kneeX = hipX + 25 * scale;
    final kneeY = hipY + 25 * scale; // Knee bends significantly DOWN
    canvas.drawLine(
      Offset(hipX + 8 * scale, hipY + 8 * scale),
      Offset(kneeX, kneeY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 16 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Knee
    canvas.drawCircle(
        Offset(kneeX, kneeY), 7 * scale, Paint()..color = skinColor);

    // Lower leg/calf (from knee back UP toward foot position)
    final ankleX = feetX;
    final ankleY = feetY - 3 * scale;
    canvas.drawLine(
      Offset(kneeX, kneeY),
      Offset(ankleX, ankleY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Foot/shoe pointing toward HEAD (LEFT direction)
    // Toe area on left, heel on right
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(feetX - 8 * scale, feetY + 2 * scale),
          width: 18 * scale,
          height: 10 * scale),
      Paint()..color = const Color(0xFF1A1A2E),
    );
    // Toe tip pointing left toward head
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(feetX - 16 * scale, feetY + 3 * scale),
          width: 8 * scale,
          height: 7 * scale),
      Paint()..color = const Color(0xFF1A1A2E),
    );
    // Shoe highlight on top
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(feetX - 10 * scale, feetY),
          width: 10 * scale,
          height: 4 * scale),
      Paint()..color = Colors.white.withOpacity(0.3),
    );
    // Heel area
    canvas.drawCircle(Offset(feetX + 2 * scale, feetY + 2 * scale), 5 * scale,
        Paint()..color = const Color(0xFF1A1A2E));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DipsPainter extends ExercisePainterBase {
  DipsPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Dip bars with metallic look
    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[300]!, Colors.grey[600]!, Colors.grey[300]!],
      ).createShader(Rect.fromLTWH(
          centerX - 43 * scale, centerY - 10 * scale, 6 * scale, 70 * scale))
      ..strokeWidth = 6 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX - 40 * scale, centerY - 10 * scale),
        Offset(centerX - 40 * scale, centerY + 60 * scale), barPaint);
    canvas.drawLine(Offset(centerX + 40 * scale, centerY - 10 * scale),
        Offset(centerX + 40 * scale, centerY + 60 * scale), barPaint);

    // Horizontal bar connections
    canvas.drawLine(
        Offset(centerX - 40 * scale, centerY - 10 * scale),
        Offset(centerX - 40 * scale - 15 * scale, centerY - 10 * scale),
        barPaint);
    canvas.drawLine(
        Offset(centerX + 40 * scale, centerY - 10 * scale),
        Offset(centerX + 40 * scale + 15 * scale, centerY - 10 * scale),
        barPaint);

    // Body dips down
    final dipOffset = progress * 25 * scale;
    final bodyY = centerY - 30 * scale + dipOffset;

    // Head with detailed features
    drawCompleteHead(canvas, Offset(centerX, bodyY - 25 * scale), scale,
        rotation: 0);

    // Chest highlight (leaning forward)
    drawMuscleHighlight(canvas, Offset(centerX + 5 * scale, bodyY - 5 * scale),
        18 * scale, primaryColor);

    // Tank top torso (slight forward lean)
    drawTankTop(canvas, Offset(centerX + 2 * scale, bodyY + 8 * scale),
        45 * scale, 50 * scale, scale);

    // Gym shorts
    drawGymShorts(canvas, Offset(centerX + 5 * scale, bodyY + 25 * scale),
        38 * scale, 24 * scale, scale);

    // Muscular arms on bars
    final elbowBend = dipOffset * 0.8;
    drawMuscularArm(
        canvas,
        Offset(centerX - 12 * scale, bodyY - 5 * scale),
        Offset(centerX - 30 * scale, bodyY + elbowBend),
        Offset(centerX - 40 * scale, centerY - 10 * scale),
        9 * scale,
        0.4 + progress * 0.4);

    drawMuscularArm(
        canvas,
        Offset(centerX + 12 * scale, bodyY - 5 * scale),
        Offset(centerX + 30 * scale, bodyY + elbowBend),
        Offset(centerX + 40 * scale, centerY - 10 * scale),
        9 * scale,
        0.4 + progress * 0.4);

    // Hands gripping bars
    drawCompleteHand(canvas, Offset(centerX - 40 * scale, centerY - 12 * scale),
        5 * scale, 0,
        gripping: true);
    drawCompleteHand(canvas, Offset(centerX + 40 * scale, centerY - 12 * scale),
        5 * scale, 0,
        gripping: true);

    // Muscular legs (bent back)
    drawMuscularLeg(
        canvas,
        Offset(centerX + 5 * scale, bodyY + 30 * scale),
        Offset(centerX - 10 * scale, bodyY + 50 * scale),
        Offset(centerX - 25 * scale, bodyY + 42 * scale),
        10 * scale);
    drawMuscularLeg(
        canvas,
        Offset(centerX + 5 * scale, bodyY + 30 * scale),
        Offset(centerX + 5 * scale, bodyY + 52 * scale),
        Offset(centerX - 8 * scale, bodyY + 48 * scale),
        10 * scale);

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 25 * scale, bodyY + 42 * scale),
        Offset(centerX - 15 * scale, bodyY + 45 * scale), 6 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== BACK EXERCISES ====================

class DeadliftPainter extends ExercisePainterBase {
  DeadliftPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Gym floor with rubber mat texture
    final groundY = centerY + 72 * scale;
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[850]!, Colors.grey[900]!],
      ).createShader(Rect.fromLTWH(0, groundY, size.width, 30 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, groundY, size.width, 30 * scale), floorPaint);

    // Weight plate shadow on floor
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX, groundY + 5 * scale),
          width: 140 * scale,
          height: 10 * scale),
      shadowPaint,
    );

    // === ANIMATED DEADLIFT MOTION ===
    final liftProgress = progress;
    final torsoAngle =
        (1 - liftProgress) * 0.75; // Bent at bottom, straight at top

    // Hip position changes through lift
    final hipY = centerY + 28 * scale - (liftProgress * 22 * scale);
    final hipX = centerX + (1 - liftProgress) * 5 * scale;

    // === MUSCULAR FIGURE WITH GYM CLOTHES ===

    // Head position (follows torso angle)
    final torsoLen = 52 * scale;
    final headX = hipX - math.sin(torsoAngle) * torsoLen;
    final headY = hipY - math.cos(torsoAngle) * torsoLen - 12 * scale;

    // Head rotation - counter-rotate slightly so head looks more forward
    // When bent (torsoAngle=0.75), head should tilt up to look ahead
    // When standing (torsoAngle=0), head is neutral
    final headRotation = torsoAngle * 0.4; // Head rotates less than torso

    // Draw head with detailed features
    drawCompleteHead(canvas, Offset(headX, headY), scale * 1.0,
        rotation: headRotation);

    // === TORSO WITH TANK TOP ===
    canvas.save();
    canvas.translate(hipX, hipY);
    canvas.rotate(-torsoAngle);

    // Muscular back/torso shape with tank top
    final torsoWidth = 48 * scale;
    final torsoHeight = 55 * scale;

    final torsoPath = Path();
    // Start from bottom center
    torsoPath.moveTo(-torsoWidth * 0.22, 0);
    // Left hip
    torsoPath.quadraticBezierTo(-torsoWidth * 0.28, -torsoHeight * 0.1,
        -torsoWidth * 0.35, -torsoHeight * 0.25);
    // Left lat (back width)
    torsoPath.quadraticBezierTo(-torsoWidth * 0.55, -torsoHeight * 0.5,
        -torsoWidth * 0.5, -torsoHeight * 0.75);
    // Left shoulder
    torsoPath.quadraticBezierTo(-torsoWidth * 0.52, -torsoHeight * 0.9,
        -torsoWidth * 0.38, -torsoHeight);
    // Trap/neck area
    torsoPath.lineTo(torsoWidth * 0.38, -torsoHeight);
    // Right shoulder
    torsoPath.quadraticBezierTo(torsoWidth * 0.52, -torsoHeight * 0.9,
        torsoWidth * 0.5, -torsoHeight * 0.75);
    // Right lat
    torsoPath.quadraticBezierTo(torsoWidth * 0.55, -torsoHeight * 0.5,
        torsoWidth * 0.35, -torsoHeight * 0.25);
    // Right hip
    torsoPath.quadraticBezierTo(
        torsoWidth * 0.28, -torsoHeight * 0.1, torsoWidth * 0.22, 0);
    torsoPath.close();

    // Tank top colors
    const jerseyColor = Color(0xFF1A1A2E);
    const jerseyHighlight = Color(0xFF2D3A4F);

    final jerseyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [jerseyHighlight, jerseyColor, jerseyColor],
      ).createShader(Rect.fromLTRB(
          -torsoWidth * 0.55, -torsoHeight, torsoWidth * 0.55, 0));
    canvas.drawPath(torsoPath, jerseyPaint);

    // Tank top neck showing skin
    final neckPath = Path();
    neckPath.moveTo(-10 * scale, -torsoHeight);
    neckPath.quadraticBezierTo(
        0, -torsoHeight + 12 * scale, 10 * scale, -torsoHeight);
    canvas.drawPath(neckPath, Paint()..color = skinColor);

    // Arm holes showing shoulders
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-torsoWidth * 0.45, -torsoHeight * 0.88),
        width: 12 * scale,
        height: 16 * scale,
      ),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(torsoWidth * 0.45, -torsoHeight * 0.88),
        width: 12 * scale,
        height: 16 * scale,
      ),
      Paint()..color = skinColor,
    );

    // Jersey brand stripe
    canvas.drawLine(
      Offset(-5 * scale, -torsoHeight * 0.9),
      Offset(-5 * scale, -5 * scale),
      Paint()
        ..color = const Color(0xFFE94560)
        ..strokeWidth = 2 * scale,
    );

    // Back muscle definition visible through tank top
    final backDefPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Spinal erectors
    canvas.drawLine(Offset(-4 * scale, -torsoHeight * 0.15),
        Offset(-3 * scale, -torsoHeight * 0.85), backDefPaint);
    canvas.drawLine(Offset(4 * scale, -torsoHeight * 0.15),
        Offset(3 * scale, -torsoHeight * 0.85), backDefPaint);

    // Lat insertions
    canvas.drawLine(Offset(-12 * scale, -torsoHeight * 0.4),
        Offset(-16 * scale, -torsoHeight * 0.65), backDefPaint);
    canvas.drawLine(Offset(12 * scale, -torsoHeight * 0.4),
        Offset(16 * scale, -torsoHeight * 0.65), backDefPaint);

    // Trap muscles at top
    final trapBulge = liftProgress * 0.3;
    final trapPaint = Paint()..color = Colors.black.withOpacity(0.12);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, -torsoHeight * 0.95),
          width: 22 * scale * (1 + trapBulge),
          height: 10 * scale * (1 + trapBulge)),
      trapPaint,
    );

    canvas.restore();

    // === GYM SHORTS ===
    drawGymShorts(
        canvas, Offset(hipX, hipY - 5 * scale), 42 * scale, 26 * scale, scale);

    // === MUSCULAR LEGS ===
    final kneeY = hipY + 25 * scale + (liftProgress * 8 * scale);
    final legSpread = 18 * scale;

    // Glute/hamstring highlight
    drawMuscleHighlight(canvas, Offset(hipX, hipY + 8 * scale),
        20 * scale * (0.7 + (1 - liftProgress) * 0.4), primaryColor);

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(hipX - 10 * scale, hipY + 5 * scale),
      Offset(hipX - legSpread, kneeY),
      Offset(hipX - legSpread * 0.85, groundY - 2 * scale),
      13 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(hipX + 10 * scale, hipY + 5 * scale),
      Offset(hipX + legSpread, kneeY),
      Offset(hipX + legSpread * 0.85, groundY - 2 * scale),
      13 * scale,
    );

    // Gym shoes
    drawGymShoe(
        canvas,
        Offset(hipX - legSpread * 0.85, groundY - 2 * scale),
        Offset(hipX - legSpread * 0.85 + 15 * scale, groundY + 3 * scale),
        8 * scale);
    drawGymShoe(
        canvas,
        Offset(hipX + legSpread * 0.85, groundY - 2 * scale),
        Offset(hipX + legSpread * 0.85 + 15 * scale, groundY + 3 * scale),
        8 * scale);

    // === BARBELL (moves up with lift) ===
    final barbellY = groundY - 12 * scale - (liftProgress * 55 * scale);

    // Back highlight when lifting
    drawMuscleHighlight(canvas, Offset(headX + 5 * scale, headY + 35 * scale),
        28 * scale * (0.6 + (1 - liftProgress) * 0.5), primaryColor);

    // Shoulder positions (on the torso, follow body position)
    final shoulderOffset = torsoLen * 0.88;
    final leftShoulderX = hipX - math.sin(torsoAngle) * shoulderOffset - 20 * scale * math.cos(torsoAngle);
    final leftShoulderY = hipY - math.cos(torsoAngle) * shoulderOffset + 20 * scale * math.sin(torsoAngle);
    final rightShoulderX = hipX - math.sin(torsoAngle) * shoulderOffset + 20 * scale * math.cos(torsoAngle);
    final rightShoulderY = hipY - math.cos(torsoAngle) * shoulderOffset - 20 * scale * math.sin(torsoAngle);

    // Hand positions on barbell - shoulder width apart, centered on bar
    final handLeftX = centerX - 18 * scale;
    final handRightX = centerX + 18 * scale;
    final handY = barbellY + 2 * scale;

    // Arms hang straight down from shoulders to the bar
    // At bottom of lift (progress=0): arms are more forward, body is bent
    // At top of lift (progress=1): arms hang straight down

    // Left arm - straight from shoulder to bar
    final leftElbowX = leftShoulderX + (handLeftX - leftShoulderX) * 0.55;
    final leftElbowY = leftShoulderY + (handY - leftShoulderY) * 0.5;
    
    drawMuscularArm(
      canvas,
      Offset(leftShoulderX, leftShoulderY),
      Offset(leftElbowX, leftElbowY),
      Offset(handLeftX, handY),
      10 * scale,
      0.15,
      showBicep: false,
    );

    // Right arm - straight from shoulder to bar
    final rightElbowX = rightShoulderX + (handRightX - rightShoulderX) * 0.55;
    final rightElbowY = rightShoulderY + (handY - rightShoulderY) * 0.5;
    
    drawMuscularArm(
      canvas,
      Offset(rightShoulderX, rightShoulderY),
      Offset(rightElbowX, rightElbowY),
      Offset(handRightX, handY),
      10 * scale,
      0.15,
      showBicep: false,
    );

    // Heavy barbell with multiple plates
    drawBarbell(
      canvas,
      Offset(centerX - 70 * scale, barbellY),
      Offset(centerX + 70 * scale, barbellY),
      20 * scale,
    );

    // Extra plates for heavy look
    _drawWeightPlate(
        canvas, Offset(centerX - 60 * scale, barbellY), 16 * scale);
    _drawWeightPlate(
        canvas, Offset(centerX + 60 * scale, barbellY), 16 * scale);

    // Complete hands gripping with fingers
    drawCompleteHand(canvas, Offset(handLeftX, handY), 6 * scale, math.pi / 2,
        gripping: true);
    drawCompleteHand(canvas, Offset(handRightX, handY), 6 * scale, -math.pi / 2,
        gripping: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PullUpPainter extends ExercisePainterBase {
  PullUpPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === PULL-UP BAR FRAME ===
    final barY = centerY - 65 * scale;

    // Bar supports (frame)
    final framePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF404040), Color(0xFF606060), Color(0xFF404040)],
      ).createShader(Rect.fromLTWH(
          centerX - 70 * scale, barY - 25 * scale, 140 * scale, 30 * scale));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 68 * scale, barY - 25 * scale, 8 * scale, 30 * scale),
        Radius.circular(2 * scale),
      ),
      framePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX + 60 * scale, barY - 25 * scale, 8 * scale, 30 * scale),
        Radius.circular(2 * scale),
      ),
      framePaint,
    );

    // Pull-up bar with metallic gradient
    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[300]!, Colors.grey[600]!, Colors.grey[300]!],
      ).createShader(Rect.fromLTWH(
          centerX - 65 * scale, barY - 4 * scale, 130 * scale, 8 * scale))
      ..strokeWidth = 7 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX - 62 * scale, barY),
      Offset(centerX + 62 * scale, barY),
      barPaint,
    );

    // Bar texture rings
    final ringPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 1.5;
    for (double x = centerX - 55 * scale;
        x <= centerX + 55 * scale;
        x += 15 * scale) {
      canvas.drawLine(
          Offset(x, barY - 3 * scale), Offset(x, barY + 3 * scale), ringPaint);
    }

    // === ANIMATED BODY PULLING UP ===
    final pullProgress = progress;
    final pullOffset = pullProgress * 45 * scale;
    final bodyY = centerY + 25 * scale - pullOffset;

    // Lat spread increases at top of movement
    final latSpread = 1.0 + pullProgress * 0.25;

    // === HEAD WITH DETAILED FEATURES ===
    drawCompleteHead(canvas, Offset(centerX, bodyY - 35 * scale), scale * 1.0,
        rotation: 0);

    // === MUSCULAR TORSO WITH TANK TOP AND LAT SPREAD ===
    final torsoTop = bodyY - 22 * scale;
    final torsoHeight = 50 * scale;
    final torsoWidth = 50 * scale * latSpread;

    // V-taper back shape with tank top
    final torsoPath = Path();
    torsoPath.moveTo(centerX - torsoWidth * 0.25, torsoTop);
    // Left shoulder (spreads with pull)
    torsoPath.quadraticBezierTo(
        centerX - torsoWidth * 0.55,
        torsoTop + 5 * scale,
        centerX - torsoWidth * 0.52,
        torsoTop + torsoHeight * 0.2);
    // Left lat (major spread)
    torsoPath.quadraticBezierTo(
        centerX - torsoWidth * 0.58,
        torsoTop + torsoHeight * 0.5,
        centerX - torsoWidth * 0.35,
        torsoTop + torsoHeight * 0.8);
    // Left waist taper
    torsoPath.quadraticBezierTo(
        centerX - torsoWidth * 0.25,
        torsoTop + torsoHeight * 0.95,
        centerX - torsoWidth * 0.2,
        torsoTop + torsoHeight);
    // Waist
    torsoPath.lineTo(centerX + torsoWidth * 0.2, torsoTop + torsoHeight);
    // Right waist taper
    torsoPath.quadraticBezierTo(
        centerX + torsoWidth * 0.25,
        torsoTop + torsoHeight * 0.95,
        centerX + torsoWidth * 0.35,
        torsoTop + torsoHeight * 0.8);
    // Right lat
    torsoPath.quadraticBezierTo(
        centerX + torsoWidth * 0.58,
        torsoTop + torsoHeight * 0.5,
        centerX + torsoWidth * 0.52,
        torsoTop + torsoHeight * 0.2);
    // Right shoulder
    torsoPath.quadraticBezierTo(centerX + torsoWidth * 0.55,
        torsoTop + 5 * scale, centerX + torsoWidth * 0.25, torsoTop);
    torsoPath.close();

    // Tank top colors
    const jerseyColor = Color(0xFF1A1A2E);
    const jerseyHighlight = Color(0xFF2D3A4F);

    final jerseyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [jerseyHighlight, jerseyColor, jerseyColor],
      ).createShader(Rect.fromLTRB(centerX - torsoWidth * 0.6, torsoTop,
          centerX + torsoWidth * 0.6, torsoTop + torsoHeight));
    canvas.drawPath(torsoPath, jerseyPaint);

    // Tank top neckline showing chest
    final neckPath = Path();
    neckPath.moveTo(centerX - 10 * scale, torsoTop);
    neckPath.quadraticBezierTo(
        centerX, torsoTop + 12 * scale, centerX + 10 * scale, torsoTop);
    canvas.drawPath(neckPath, Paint()..color = skinColor);

    // Arm holes showing shoulders
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - torsoWidth * 0.48, torsoTop + 8 * scale),
        width: 12 * scale,
        height: 16 * scale,
      ),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + torsoWidth * 0.48, torsoTop + 8 * scale),
        width: 12 * scale,
        height: 16 * scale,
      ),
      Paint()..color = skinColor,
    );

    // Jersey brand stripe
    canvas.drawLine(
      Offset(centerX - 5 * scale, torsoTop + 5 * scale),
      Offset(centerX - 5 * scale, torsoTop + torsoHeight - 5 * scale),
      Paint()
        ..color = const Color(0xFFE94560)
        ..strokeWidth = 2 * scale,
    );

    // Lat/Back muscle highlight (glowing during pull)
    drawMuscleHighlight(canvas, Offset(centerX, torsoTop + torsoHeight * 0.35),
        30 * scale * (0.7 + pullProgress * 0.4), primaryColor);

    // Back muscle definition visible through tank top
    final backDefPaint = Paint()
      ..color = Colors.black.withOpacity(0.15 + pullProgress * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Spinal groove
    canvas.drawLine(
      Offset(centerX, torsoTop + 5 * scale),
      Offset(centerX, torsoTop + torsoHeight - 8 * scale),
      backDefPaint,
    );

    // Lat insertions (more visible during contraction)
    canvas.drawLine(
      Offset(centerX - 8 * scale, torsoTop + torsoHeight * 0.3),
      Offset(centerX - torsoWidth * 0.38, torsoTop + torsoHeight * 0.15),
      backDefPaint,
    );
    canvas.drawLine(
      Offset(centerX + 8 * scale, torsoTop + torsoHeight * 0.3),
      Offset(centerX + torsoWidth * 0.38, torsoTop + torsoHeight * 0.15),
      backDefPaint,
    );

    // === ARMS REACHING UP TO BAR ===
    final shoulderY = torsoTop + 5 * scale;
    final handGripSpread = 38 * scale;

    // Arm angles change during pull
    final elbowOutward = 30 * scale + pullProgress * 15 * scale;
    final elbowY = barY + 20 * scale + pullProgress * 25 * scale;

    // Bicep flex increases during pull
    final armFlex = 0.3 + pullProgress * 0.7;

    // Left arm
    drawMuscularArm(
      canvas,
      Offset(centerX - torsoWidth * 0.42, shoulderY),
      Offset(centerX - elbowOutward, elbowY),
      Offset(centerX - handGripSpread, barY + 3 * scale),
      10 * scale,
      armFlex,
      showBicep: true,
    );

    // Right arm
    drawMuscularArm(
      canvas,
      Offset(centerX + torsoWidth * 0.42, shoulderY),
      Offset(centerX + elbowOutward, elbowY),
      Offset(centerX + handGripSpread, barY + 3 * scale),
      10 * scale,
      armFlex,
      showBicep: true,
    );

    // Complete hands gripping bar with fingers
    drawCompleteHand(
        canvas, Offset(centerX - handGripSpread, barY), 5 * scale, math.pi,
        gripping: true);
    drawCompleteHand(
        canvas, Offset(centerX + handGripSpread, barY), 5 * scale, math.pi,
        gripping: true);

    // === GYM SHORTS ===
    final hipY = torsoTop + torsoHeight;
    drawGymShorts(canvas, Offset(centerX, hipY - 8 * scale), 38 * scale,
        24 * scale, scale);

    // === LEGS (slightly bent and crossed) ===
    final legLen = 60 * scale;

    // Left leg (crosses behind)
    drawMuscularLeg(
      canvas,
      Offset(centerX - 8 * scale, hipY),
      Offset(centerX - 5 * scale, hipY + legLen * 0.55),
      Offset(centerX + 2 * scale, hipY + legLen),
      11 * scale,
    );

    // Right leg (in front)
    drawMuscularLeg(
      canvas,
      Offset(centerX + 8 * scale, hipY),
      Offset(centerX + 12 * scale, hipY + legLen * 0.55),
      Offset(centerX + 8 * scale, hipY + legLen),
      11 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX + 2 * scale, hipY + legLen),
        Offset(centerX + 10 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 8 * scale, hipY + legLen),
        Offset(centerX + 16 * scale, hipY + legLen + 5 * scale), 7 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarbellRowPainter extends ExercisePainterBase {
  BarbellRowPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 55 * scale, size.width, 45 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 55 * scale, size.width, 45 * scale),
        floorPaint);

    // Bent over position - figure bends forward at about 45 degrees
    final hipX = centerX + 15 * scale;
    final hipY = centerY + 10 * scale;
    final groundY = centerY + 60 * scale;

    // === HEAD (bent forward looking down) ===
    drawCompleteHead(
        canvas, Offset(centerX - 30 * scale, centerY - 20 * scale), scale * 0.9,
        rotation: 0.7);

    // === TANK TOP (bent torso) ===
    // Draw bent-over torso with tank top
    const jerseyColor = Color(0xFF1A1A2E);
    const jerseyHighlight = Color(0xFF2D3A4F);

    final torsoPath = Path();
    // Shoulder area (near head)
    torsoPath.moveTo(centerX - 35 * scale, centerY - 12 * scale);
    torsoPath.lineTo(centerX - 20 * scale, centerY - 18 * scale);
    // Upper back
    torsoPath.quadraticBezierTo(
      centerX - 5 * scale,
      centerY - 8 * scale,
      hipX - 5 * scale,
      hipY - 8 * scale,
    );
    // Right hip
    torsoPath.lineTo(hipX + 10 * scale, hipY);
    // Lower back
    torsoPath.lineTo(hipX - 20 * scale, hipY + 5 * scale);
    // Left side
    torsoPath.quadraticBezierTo(
      centerX - 30 * scale,
      centerY,
      centerX - 38 * scale,
      centerY - 8 * scale,
    );
    torsoPath.close();

    canvas.drawPath(torsoPath, Paint()..color = jerseyColor);
    canvas.drawPath(
        torsoPath,
        Paint()
          ..color = jerseyHighlight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Back muscle highlight
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 5 * scale, centerY - 2 * scale),
        18 * scale,
        primaryColor);

    // === GYM SHORTS ===
    drawGymShorts(
        canvas, Offset(hipX, hipY - 5 * scale), 32 * scale, 20 * scale, scale);

    // === LEGS (slightly bent for stability) ===
    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(hipX - 8 * scale, hipY + 10 * scale),
      Offset(hipX - 12 * scale, hipY + 32 * scale),
      Offset(hipX - 8 * scale, groundY),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(hipX + 8 * scale, hipY + 10 * scale),
      Offset(hipX + 12 * scale, hipY + 32 * scale),
      Offset(hipX + 8 * scale, groundY),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(hipX - 8 * scale, groundY),
        Offset(hipX - 18 * scale, groundY + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(hipX + 8 * scale, groundY),
        Offset(hipX + 18 * scale, groundY + 5 * scale), 7 * scale);

    // === BARBELL ROW MOTION ===
    final rowY = centerY + 25 * scale - (progress * 30 * scale);

    // === MUSCULAR ARMS ===
    final shoulderL = Offset(centerX - 32 * scale, centerY - 10 * scale);
    final shoulderR = Offset(centerX - 18 * scale, centerY - 5 * scale);
    final elbowL = Offset(centerX - 38 * scale, rowY + 12 * scale);
    final elbowR = Offset(centerX - 5 * scale, rowY + 10 * scale);
    final handL = Offset(centerX - 35 * scale, rowY);
    final handR = Offset(centerX + 5 * scale, rowY);

    // Arm flex based on row position
    final armFlex = 0.4 + (progress * 0.5);

    drawMuscularArm(canvas, shoulderL, elbowL, handL, 9 * scale, armFlex);
    drawMuscularArm(canvas, shoulderR, elbowR, handR, 9 * scale, armFlex);

    // Hands gripping barbell
    drawCompleteHand(canvas, handL, 7 * scale, 0.3, gripping: true);
    drawCompleteHand(canvas, handR, 7 * scale, 0.3, gripping: true);

    // === BARBELL ===
    drawBarbell(
      canvas,
      Offset(centerX - 55 * scale, rowY),
      Offset(centerX + 45 * scale, rowY),
      12 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LatPulldownPainter extends ExercisePainterBase {
  LatPulldownPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === LAT PULLDOWN MACHINE FRAME ===
    final metalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.grey[700]!, Colors.grey[300]!, Colors.grey[600]!],
      ).createShader(
          Rect.fromLTWH(centerX - 50 * scale, 0, 100 * scale, centerY));

    // Vertical support
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 5 * scale, 5 * scale, 10 * scale, centerY - 50 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );

    // Top crossbar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 45 * scale, 5 * scale, 90 * scale, 8 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );

    // Pulley wheel
    canvas.drawCircle(
      Offset(centerX, 20 * scale),
      8 * scale,
      Paint()..color = Colors.grey[800]!,
    );
    canvas.drawCircle(
      Offset(centerX, 20 * scale),
      4 * scale,
      Paint()..color = Colors.grey[500]!,
    );

    // === CABLE AND LAT BAR ===
    final barY = centerY - 40 * scale + (progress * 35 * scale);

    // Cable from pulley to bar
    drawCable(canvas, Offset(centerX, 20 * scale),
        Offset(centerX, barY - 8 * scale), 2 * scale);

    // Lat pulldown bar (curved)
    final latBarPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;

    // Main bar
    canvas.drawLine(
      Offset(centerX - 40 * scale, barY),
      Offset(centerX + 40 * scale, barY),
      latBarPaint,
    );

    // Curved ends
    final barPath = Path();
    barPath.moveTo(centerX - 40 * scale, barY);
    barPath.quadraticBezierTo(centerX - 50 * scale, barY + 15 * scale,
        centerX - 45 * scale, barY + 25 * scale);
    barPath.moveTo(centerX + 40 * scale, barY);
    barPath.quadraticBezierTo(centerX + 50 * scale, barY + 15 * scale,
        centerX + 45 * scale, barY + 25 * scale);
    canvas.drawPath(barPath, latBarPaint..style = PaintingStyle.stroke);

    // Grip ends
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX - 45 * scale, barY + 25 * scale),
            width: 10 * scale,
            height: 6 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.black,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(centerX + 45 * scale, barY + 25 * scale),
            width: 10 * scale,
            height: 6 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.black,
    );

    // === SEAT AND LEG PAD ===
    final seatY = centerY + 45 * scale;

    // Seat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 28 * scale, seatY, 56 * scale, 10 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.grey[850] ?? Colors.grey[800]!,
    );

    // Seat cushion
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 25 * scale, seatY + 2 * scale, 50 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );

    // Thigh pad
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 22 * scale, seatY - 10 * scale, 44 * scale, 8 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );

    // === SEATED MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(canvas, Offset(centerX, centerY - 8 * scale), scale * 0.95,
        rotation: 0);

    // Lat muscle highlight (showing the target muscle)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 18 * scale, centerY + 12 * scale),
        15 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 18 * scale, centerY + 12 * scale),
        15 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY + 5 * scale), 44 * scale,
        42 * scale, scale);

    // === GYM SHORTS (visible below tank) ===
    drawGymShorts(canvas, Offset(centerX, seatY - 8 * scale), 36 * scale,
        18 * scale, scale);

    // === ARMS PULLING BAR DOWN ===
    final elbowSpread = 28 * scale - (progress * 12 * scale);
    final armFlex = 0.3 + (progress * 0.5);

    // Left arm
    final leftShoulder = Offset(centerX - 18 * scale, centerY + 2 * scale);
    final leftElbow = Offset(centerX - elbowSpread, barY + 8 * scale);
    final leftHand = Offset(centerX - 42 * scale, barY + 25 * scale);

    drawMuscularArm(
        canvas, leftShoulder, leftElbow, leftHand, 8 * scale, armFlex);
    drawCompleteHand(canvas, leftHand, 6 * scale, -0.3, gripping: true);

    // Right arm
    final rightShoulder = Offset(centerX + 18 * scale, centerY + 2 * scale);
    final rightElbow = Offset(centerX + elbowSpread, barY + 8 * scale);
    final rightHand = Offset(centerX + 42 * scale, barY + 25 * scale);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 8 * scale, armFlex);
    drawCompleteHand(canvas, rightHand, 6 * scale, 0.3, gripping: true);

    // === LEGS (seated, under thigh pad) ===
    final kneeY = seatY + 25 * scale;
    final ankleY = seatY + 55 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 12 * scale, seatY + 5 * scale),
      Offset(centerX - 18 * scale, kneeY),
      Offset(centerX - 15 * scale, ankleY),
      9 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 12 * scale, seatY + 5 * scale),
      Offset(centerX + 18 * scale, kneeY),
      Offset(centerX + 15 * scale, ankleY),
      9 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 15 * scale, ankleY),
        Offset(centerX - 25 * scale, ankleY + 5 * scale), 6 * scale);
    drawGymShoe(canvas, Offset(centerX + 15 * scale, ankleY),
        Offset(centerX + 25 * scale, ankleY + 5 * scale), 6 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== SHOULDER EXERCISES ====================

class OverheadPressPainter extends ExercisePainterBase {
  OverheadPressPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // === STANDING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(canvas, Offset(centerX, centerY - 50 * scale), scale,
        rotation: 0);

    // Shoulder/delt highlights (target muscle)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 22 * scale, centerY - 30 * scale),
        14 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 22 * scale, centerY - 30 * scale),
        14 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 8 * scale), 48 * scale,
        55 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 22 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY), 38 * scale, 24 * scale, scale);

    // === LEGS ===
    final legLen = 55 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 12 * scale),
      Offset(centerX - 13 * scale, hipY + legLen * 0.5),
      Offset(centerX - 12 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 12 * scale),
      Offset(centerX + 13 * scale, hipY + legLen * 0.5),
      Offset(centerX + 12 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 12 * scale, hipY + legLen),
        Offset(centerX - 22 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 12 * scale, hipY + legLen),
        Offset(centerX + 22 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === BARBELL OVERHEAD PRESS MOTION ===
    final pressY = centerY - 55 * scale - (progress * 35 * scale);
    final elbowY = centerY - 32 * scale - (progress * 22 * scale);
    final armFlex = 0.4 + (progress * 0.4);

    // Left arm
    final leftShoulder = Offset(centerX - 20 * scale, centerY - 28 * scale);
    final leftElbow = Offset(centerX - 30 * scale, elbowY);
    final leftHand = Offset(centerX - 38 * scale, pressY);

    drawMuscularArm(
        canvas, leftShoulder, leftElbow, leftHand, 9 * scale, armFlex);
    drawCompleteHand(canvas, leftHand, 6 * scale, -math.pi / 2, gripping: true);

    // Right arm
    final rightShoulder = Offset(centerX + 20 * scale, centerY - 28 * scale);
    final rightElbow = Offset(centerX + 30 * scale, elbowY);
    final rightHand = Offset(centerX + 38 * scale, pressY);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 9 * scale, armFlex);
    drawCompleteHand(canvas, rightHand, 6 * scale, math.pi / 2, gripping: true);

    // === BARBELL ===
    drawBarbell(
      canvas,
      Offset(centerX - 60 * scale, pressY),
      Offset(centerX + 60 * scale, pressY),
      12 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LateralRaisePainter extends ExercisePainterBase {
  LateralRaisePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // === STANDING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(canvas, Offset(centerX, centerY - 50 * scale), scale,
        rotation: 0);

    // Shoulder/delt highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 22 * scale, centerY - 30 * scale),
        14 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 22 * scale, centerY - 30 * scale),
        14 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 8 * scale), 48 * scale,
        55 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 22 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY), 38 * scale, 24 * scale, scale);

    // === LEGS ===
    final legLen = 55 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 12 * scale),
      Offset(centerX - 12 * scale, hipY + legLen * 0.5),
      Offset(centerX - 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 12 * scale),
      Offset(centerX + 12 * scale, hipY + legLen * 0.5),
      Offset(centerX + 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 10 * scale, hipY + legLen),
        Offset(centerX - 20 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 10 * scale, hipY + legLen),
        Offset(centerX + 20 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === ARMS RAISING TO SIDES ===
    final raiseAngle = progress * (math.pi / 2.5);
    final armLength = 45 * scale;

    // Calculate arm end positions
    final leftArmEndX =
        centerX - 18 * scale - (math.cos(math.pi - raiseAngle) * armLength);
    final leftArmEndY =
        centerY - 28 * scale + (math.sin(math.pi - raiseAngle) * armLength);
    final rightArmEndX =
        centerX + 18 * scale + (math.cos(raiseAngle) * armLength);
    final rightArmEndY =
        centerY - 28 * scale - (math.sin(raiseAngle) * armLength);

    // Elbow positions (slight bend)
    final leftElbow = Offset(
      centerX - 18 * scale - (math.cos(math.pi - raiseAngle) * armLength * 0.5),
      centerY -
          28 * scale +
          (math.sin(math.pi - raiseAngle) * armLength * 0.5) +
          3 * scale,
    );
    final rightElbow = Offset(
      centerX + 18 * scale + (math.cos(raiseAngle) * armLength * 0.5),
      centerY -
          28 * scale -
          (math.sin(raiseAngle) * armLength * 0.5) +
          3 * scale,
    );

    // Draw arms
    drawMuscularArm(canvas, Offset(centerX - 20 * scale, centerY - 28 * scale),
        leftElbow, Offset(leftArmEndX, leftArmEndY), 8 * scale, 0.3);
    drawMuscularArm(canvas, Offset(centerX + 20 * scale, centerY - 28 * scale),
        rightElbow, Offset(rightArmEndX, rightArmEndY), 8 * scale, 0.3);

    // Hands and dumbbells
    drawCompleteHand(canvas, Offset(leftArmEndX, leftArmEndY), 6 * scale,
        raiseAngle - math.pi / 2,
        gripping: true);
    drawCompleteHand(canvas, Offset(rightArmEndX, rightArmEndY), 6 * scale,
        -raiseAngle + math.pi / 2,
        gripping: true);

    drawDumbbell(canvas, Offset(leftArmEndX, leftArmEndY), 20 * scale,
        6 * scale, raiseAngle);
    drawDumbbell(canvas, Offset(rightArmEndX, rightArmEndY), 20 * scale,
        6 * scale, -raiseAngle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FrontRaisePainter extends ExercisePainterBase {
  FrontRaisePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // === STANDING MUSCULAR FIGURE (side view) ===

    // Head
    drawCompleteHead(canvas, Offset(centerX, centerY - 50 * scale), scale,
        rotation: 0);

    // Front delt highlight (target muscle)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 18 * scale, centerY - 30 * scale),
        13 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 8 * scale), 46 * scale,
        55 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 22 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY), 36 * scale, 24 * scale, scale);

    // === LEGS ===
    final legLen = 55 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 8 * scale, hipY + 12 * scale),
      Offset(centerX - 10 * scale, hipY + legLen * 0.5),
      Offset(centerX - 8 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 8 * scale, hipY + 12 * scale),
      Offset(centerX + 10 * scale, hipY + legLen * 0.5),
      Offset(centerX + 8 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 8 * scale, hipY + legLen),
        Offset(centerX - 18 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 8 * scale, hipY + legLen),
        Offset(centerX + 18 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === ARMS - FRONT RAISE ===
    final raiseY = centerY - 28 * scale - (progress * 50 * scale);

    // Front arm (raising) - left arm doing the work
    final leftShoulder = Offset(centerX - 18 * scale, centerY - 28 * scale);
    final leftElbow =
        Offset(centerX - 28 * scale, (centerY - 28 * scale + raiseY) / 2);
    final leftHand = Offset(centerX - 32 * scale, raiseY);

    drawMuscularArm(canvas, leftShoulder, leftElbow, leftHand, 8 * scale,
        0.3 + progress * 0.3);
    drawCompleteHand(canvas, leftHand, 6 * scale, math.pi / 2, gripping: true);
    drawDumbbell(canvas, leftHand, 22 * scale, 7 * scale, math.pi / 2);

    // Back arm (at side) - right arm resting
    final rightShoulder = Offset(centerX + 12 * scale, centerY - 28 * scale);
    final rightElbow = Offset(centerX + 18 * scale, centerY - 5 * scale);
    final rightHand = Offset(centerX + 20 * scale, centerY + 15 * scale);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 8 * scale, 0.2);
    drawCompleteHand(canvas, rightHand, 6 * scale, 0, gripping: true);
    drawDumbbell(canvas, rightHand, 22 * scale, 7 * scale, 0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShrugPainter extends ExercisePainterBase {
  ShrugPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // Shoulder/shrug raise offset
    final shrugOffset = progress * 10 * scale;

    // === STANDING MUSCULAR FIGURE ===

    // Head (moves up with shrug)
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 50 * scale - shrugOffset), scale,
        rotation: 0);

    // Trap muscle highlights (target muscles - move with shrug)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 15 * scale, centerY - 38 * scale - shrugOffset),
        12 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 15 * scale, centerY - 38 * scale - shrugOffset),
        12 * scale,
        primaryColor);

    // === TANK TOP (shoulders rise with shrug) ===
    final shoulderY = centerY - 35 * scale - shrugOffset;

    // Custom tank top for shrug (shoulders elevated)
    const jerseyColor = Color(0xFF1A1A2E);
    const jerseyHighlight = Color(0xFF2D3A4F);

    final torsoPath = Path();
    // Left shoulder (elevated)
    torsoPath.moveTo(centerX - 22 * scale, shoulderY);
    torsoPath.quadraticBezierTo(
      centerX - 26 * scale,
      shoulderY + 8 * scale,
      centerX - 24 * scale,
      centerY + 5 * scale,
    );
    // Left side
    torsoPath.lineTo(centerX - 18 * scale, centerY + 25 * scale);
    // Bottom
    torsoPath.lineTo(centerX + 18 * scale, centerY + 25 * scale);
    // Right side
    torsoPath.lineTo(centerX + 24 * scale, centerY + 5 * scale);
    // Right shoulder (elevated)
    torsoPath.quadraticBezierTo(
      centerX + 26 * scale,
      shoulderY + 8 * scale,
      centerX + 22 * scale,
      shoulderY,
    );
    // Neck
    torsoPath.quadraticBezierTo(
        centerX, shoulderY - 5 * scale, centerX - 22 * scale, shoulderY);
    torsoPath.close();

    canvas.drawPath(torsoPath, Paint()..color = jerseyColor);
    canvas.drawPath(
        torsoPath,
        Paint()
          ..color = jerseyHighlight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // === GYM SHORTS ===
    final hipY = centerY + 22 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY), 38 * scale, 24 * scale, scale);

    // === LEGS ===
    final legLen = 55 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 12 * scale),
      Offset(centerX - 12 * scale, hipY + legLen * 0.5),
      Offset(centerX - 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 12 * scale),
      Offset(centerX + 12 * scale, hipY + legLen * 0.5),
      Offset(centerX + 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 10 * scale, hipY + legLen),
        Offset(centerX - 20 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 10 * scale, hipY + legLen),
        Offset(centerX + 20 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === ARMS HOLDING DUMBBELLS AT SIDES ===
    final handY = centerY + 18 * scale;

    // Left arm
    final leftShoulder = Offset(centerX - 24 * scale, shoulderY + 5 * scale);
    final leftElbow = Offset(centerX - 28 * scale, centerY - 5 * scale);
    final leftHand = Offset(centerX - 30 * scale, handY);

    drawMuscularArm(canvas, leftShoulder, leftElbow, leftHand, 8 * scale, 0.25);
    drawCompleteHand(canvas, leftHand, 6 * scale, 0, gripping: true);

    // Right arm
    final rightShoulder = Offset(centerX + 24 * scale, shoulderY + 5 * scale);
    final rightElbow = Offset(centerX + 28 * scale, centerY - 5 * scale);
    final rightHand = Offset(centerX + 30 * scale, handY);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 8 * scale, 0.25);
    drawCompleteHand(canvas, rightHand, 6 * scale, 0, gripping: true);

    // === DUMBBELLS ===
    drawDumbbell(canvas, Offset(leftHand.dx, handY + 5 * scale), 24 * scale,
        8 * scale, 0);
    drawDumbbell(canvas, Offset(rightHand.dx, handY + 5 * scale), 24 * scale,
        8 * scale, 0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== ARM EXERCISES ====================

class BicepCurlPainter extends ExercisePainterBase {
  BicepCurlPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Gym floor
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 68 * scale, size.width, 32 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 68 * scale, size.width, 32 * scale),
        floorPaint);

    // === MUSCULAR STANDING FIGURE WITH GYM CLOTHES ===

    // Head with detailed features
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 52 * scale), scale * 1.05,
        rotation: 0);

    // Muscular torso with tank top
    final torsoTop = centerY - 35 * scale;
    final torsoHeight = 60 * scale;
    final torsoWidth = 48 * scale;

    // Draw V-taper torso shape with tank top
    final torsoPath = Path();
    torsoPath.moveTo(centerX - torsoWidth * 0.35, torsoTop);
    // Left shoulder/delt
    torsoPath.quadraticBezierTo(
        centerX - torsoWidth * 0.55,
        torsoTop + 8 * scale,
        centerX - torsoWidth * 0.52,
        torsoTop + torsoHeight * 0.2);
    // Left lat spread
    torsoPath.quadraticBezierTo(
        centerX - torsoWidth * 0.55,
        torsoTop + torsoHeight * 0.45,
        centerX - torsoWidth * 0.35,
        torsoTop + torsoHeight * 0.75);
    // Left oblique taper
    torsoPath.quadraticBezierTo(
        centerX - torsoWidth * 0.28,
        torsoTop + torsoHeight * 0.9,
        centerX - torsoWidth * 0.22,
        torsoTop + torsoHeight);
    // Waist
    torsoPath.lineTo(centerX + torsoWidth * 0.22, torsoTop + torsoHeight);
    // Right oblique
    torsoPath.quadraticBezierTo(
        centerX + torsoWidth * 0.28,
        torsoTop + torsoHeight * 0.9,
        centerX + torsoWidth * 0.35,
        torsoTop + torsoHeight * 0.75);
    // Right lat
    torsoPath.quadraticBezierTo(
        centerX + torsoWidth * 0.55,
        torsoTop + torsoHeight * 0.45,
        centerX + torsoWidth * 0.52,
        torsoTop + torsoHeight * 0.2);
    // Right shoulder
    torsoPath.quadraticBezierTo(centerX + torsoWidth * 0.55,
        torsoTop + 8 * scale, centerX + torsoWidth * 0.35, torsoTop);
    torsoPath.close();

    // Tank top colors
    const jerseyColor = Color(0xFF1A1A2E);
    const jerseyHighlight = Color(0xFF2D3A4F);

    final jerseyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [jerseyHighlight, jerseyColor, jerseyColor],
      ).createShader(Rect.fromLTRB(centerX - torsoWidth * 0.55, torsoTop,
          centerX + torsoWidth * 0.55, torsoTop + torsoHeight));
    canvas.drawPath(torsoPath, jerseyPaint);

    // Tank top V-neck showing chest
    final neckPath = Path();
    neckPath.moveTo(centerX - 12 * scale, torsoTop);
    neckPath.quadraticBezierTo(
        centerX, torsoTop + 15 * scale, centerX + 12 * scale, torsoTop);
    canvas.drawPath(neckPath, Paint()..color = skinColor);

    // Arm holes showing shoulders
    canvas.drawOval(
      Rect.fromCenter(
        center:
            Offset(centerX - torsoWidth * 0.48, torsoTop + torsoHeight * 0.12),
        width: 14 * scale,
        height: 20 * scale,
      ),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center:
            Offset(centerX + torsoWidth * 0.48, torsoTop + torsoHeight * 0.12),
        width: 14 * scale,
        height: 20 * scale,
      ),
      Paint()..color = skinColor,
    );

    // Jersey brand stripe
    canvas.drawLine(
      Offset(centerX - 6 * scale, torsoTop + 5 * scale),
      Offset(centerX - 6 * scale, torsoTop + torsoHeight - 5 * scale),
      Paint()
        ..color = const Color(0xFFE94560)
        ..strokeWidth = 2 * scale,
    );

    // Muscle definition visible through tank top
    final muscleOutline = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX - 10 * scale, torsoTop + 15 * scale),
          width: 18 * scale,
          height: 12 * scale),
      muscleOutline,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 10 * scale, torsoTop + 15 * scale),
          width: 18 * scale,
          height: 12 * scale),
      muscleOutline,
    );

    // === LEGS WITH GYM SHORTS ===
    final hipY = torsoTop + torsoHeight;
    final footY = centerY + 70 * scale;

    // Draw gym shorts
    drawGymShorts(canvas, Offset(centerX, hipY - 8 * scale), 40 * scale,
        25 * scale, scale);

    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY),
      Offset(centerX - 14 * scale, hipY + 35 * scale),
      Offset(centerX - 12 * scale, footY),
      12 * scale,
    );
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY),
      Offset(centerX + 14 * scale, hipY + 35 * scale),
      Offset(centerX + 12 * scale, footY),
      12 * scale,
    );

    // Gym shoes
    drawGymShoe(
        canvas,
        Offset(centerX - 12 * scale, footY),
        Offset(centerX - 12 * scale + 14 * scale, footY + 5 * scale),
        7 * scale);
    drawGymShoe(
        canvas,
        Offset(centerX + 12 * scale, footY),
        Offset(centerX + 12 * scale + 14 * scale, footY + 5 * scale),
        7 * scale);

    // === ANIMATED CURLING ARMS ===
    final curlAngle = progress * (math.pi * 0.75);
    final bicepFlex = progress;

    // Shoulder positions
    final leftShoulderX = centerX - 22 * scale;
    final rightShoulderX = centerX + 22 * scale;
    final shoulderY = torsoTop + 8 * scale;

    // Elbow positions (upper arms at sides)
    final leftElbowX = centerX - 24 * scale;
    final rightElbowX = centerX + 24 * scale;
    final elbowY = torsoTop + 40 * scale;

    // Forearm end positions (curling)
    final forearmLen = 32 * scale;
    final leftHandX = leftElbowX - math.sin(curlAngle) * forearmLen;
    final leftHandY = elbowY - math.cos(curlAngle) * forearmLen;
    final rightHandX = rightElbowX + math.sin(curlAngle) * forearmLen;
    final rightHandY = elbowY - math.cos(curlAngle) * forearmLen;

    // Bicep muscle highlight (grows with curl)
    drawMuscleHighlight(
        canvas,
        Offset(leftElbowX - 5 * scale, elbowY - 15 * scale),
        18 * scale * (0.6 + bicepFlex * 0.5),
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(rightElbowX + 5 * scale, elbowY - 15 * scale),
        18 * scale * (0.6 + bicepFlex * 0.5),
        primaryColor);

    // Draw muscular arms with flex
    drawMuscularArm(
      canvas,
      Offset(leftShoulderX, shoulderY),
      Offset(leftElbowX, elbowY),
      Offset(leftHandX, leftHandY),
      10 * scale,
      bicepFlex,
      showBicep: true,
    );
    drawMuscularArm(
      canvas,
      Offset(rightShoulderX, shoulderY),
      Offset(rightElbowX, elbowY),
      Offset(rightHandX, rightHandY),
      10 * scale,
      bicepFlex,
      showBicep: true,
    );

    // Barbell (EZ curl bar effect)
    drawBarbell(
      canvas,
      Offset(leftHandX - 22 * scale, leftHandY),
      Offset(rightHandX + 22 * scale, rightHandY),
      14 * scale,
    );

    // Complete hands gripping with fingers
    drawCompleteHand(
        canvas, Offset(leftHandX, leftHandY), 5 * scale, -curlAngle,
        gripping: true);
    drawCompleteHand(
        canvas, Offset(rightHandX, rightHandY), 5 * scale, curlAngle,
        gripping: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HammerCurlPainter extends ExercisePainterBase {
  HammerCurlPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  // Easing function for smooth curl motion
  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // === STANDING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(canvas, Offset(centerX, centerY - 50 * scale), scale,
        rotation: 0);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 8 * scale), 48 * scale,
        55 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 22 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY), 38 * scale, 24 * scale, scale);

    // === LEGS ===
    final legLen = 55 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 12 * scale),
      Offset(centerX - 12 * scale, hipY + legLen * 0.5),
      Offset(centerX - 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 12 * scale),
      Offset(centerX + 12 * scale, hipY + legLen * 0.5),
      Offset(centerX + 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 10 * scale, hipY + legLen),
        Offset(centerX - 20 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 10 * scale, hipY + legLen),
        Offset(centerX + 20 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === TRUE ALTERNATING HAMMER CURL ===
    // Animation now uses reverse: false, so progress goes 0→1 continuously
    // progress 0-0.5: left arm does the curl (up at 0.25, down at 0.5)
    // progress 0.5-1: right arm does the curl (up at 0.75, down at 1)
    // Then loops back to 0 for clean repetition

    double leftProgress;
    double rightProgress;

    // Left arm active in first half (0 to 0.5)
    if (progress <= 0.5) {
      // Triangle wave: 0->0.25 goes 0->1, 0.25->0.5 goes 1->0
      if (progress <= 0.25) {
        leftProgress = progress * 4; // 0 to 1
      } else {
        leftProgress = (0.5 - progress) * 4; // 1 to 0
      }
      rightProgress = 0.0;
    } else {
      // Right arm active in second half (0.5 to 1)
      leftProgress = 0.0;
      // Triangle wave: 0.5->0.75 goes 0->1, 0.75->1.0 goes 1->0
      if (progress <= 0.75) {
        rightProgress = (progress - 0.5) * 4; // 0 to 1
      } else {
        rightProgress = (1.0 - progress) * 4; // 1 to 0
      }
    }

    // Apply easing for smooth motion
    leftProgress = _easeInOut(leftProgress);
    rightProgress = _easeInOut(rightProgress);

    final leftCurlAngle = leftProgress * (math.pi * 0.65);
    final rightCurlAngle = rightProgress * (math.pi * 0.65);

    // Forearm/bicep highlight on active arm
    if (leftProgress > rightProgress) {
      drawMuscleHighlight(
          canvas,
          Offset(centerX - 26 * scale, centerY - 8 * scale),
          12 * scale * (0.8 + leftProgress * 0.3),
          primaryColor);
    } else {
      drawMuscleHighlight(
          canvas,
          Offset(centerX + 26 * scale, centerY - 8 * scale),
          12 * scale * (0.8 + rightProgress * 0.3),
          primaryColor);
    }

    // LEFT ARM
    final leftShoulder = Offset(centerX - 20 * scale, centerY - 28 * scale);
    final leftElbow = Offset(centerX - 24 * scale, centerY - 2 * scale);
    final leftForearmLen = 32 * scale;
    // When curling, forearm rotates up from elbow
    final leftHandX = leftElbow.dx - math.sin(leftCurlAngle) * 5 * scale;
    final leftHand = Offset(
        leftHandX, leftElbow.dy - math.sin(leftCurlAngle) * leftForearmLen);

    drawMuscularArm(canvas, leftShoulder, leftElbow, leftHand, 8 * scale,
        0.25 + leftProgress * 0.5);
    drawCompleteHand(
        canvas, leftHand, 5 * scale, math.pi / 2 - leftCurlAngle * 0.3,
        gripping: true);
    drawDumbbell(canvas, Offset(leftHand.dx, leftHand.dy + 3 * scale),
        20 * scale, 7 * scale, math.pi / 2);

    // RIGHT ARM
    final rightShoulder = Offset(centerX + 20 * scale, centerY - 28 * scale);
    final rightElbow = Offset(centerX + 24 * scale, centerY - 2 * scale);
    final rightForearmLen = 32 * scale;
    final rightHandX = rightElbow.dx + math.sin(rightCurlAngle) * 5 * scale;
    final rightHand = Offset(
        rightHandX, rightElbow.dy - math.sin(rightCurlAngle) * rightForearmLen);

    drawMuscularArm(canvas, rightShoulder, rightElbow, rightHand, 8 * scale,
        0.25 + rightProgress * 0.5);
    drawCompleteHand(
        canvas, rightHand, 5 * scale, math.pi / 2 + rightCurlAngle * 0.3,
        gripping: true);
    drawDumbbell(canvas, Offset(rightHand.dx, rightHand.dy + 3 * scale),
        20 * scale, 7 * scale, math.pi / 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TricepPushdownPainter extends ExercisePainterBase {
  TricepPushdownPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === CABLE MACHINE FRAME ===
    final metalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.grey[700]!, Colors.grey[300]!, Colors.grey[600]!],
      ).createShader(Rect.fromLTWH(
          centerX - 10 * scale, 0, 20 * scale, centerY - 40 * scale));

    // Vertical support
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 5 * scale, 5 * scale, 10 * scale, centerY - 50 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );

    // Weight stack
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(centerX - 15 * scale, 15 * scale + i * 8 * scale,
            30 * scale, 6 * scale),
        Paint()..color = i < 3 ? Colors.grey[700]! : Colors.grey[500]!,
      );
    }

    // Pulley
    canvas.drawCircle(Offset(centerX, centerY - 48 * scale), 6 * scale,
        Paint()..color = Colors.grey[600]!);

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // === STANDING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 38 * scale), scale * 0.95,
        rotation: 0);

    // Tricep highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 22 * scale, centerY - 12 * scale),
        10 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 22 * scale, centerY - 12 * scale),
        10 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 2 * scale), 46 * scale,
        50 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 25 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY), 36 * scale, 22 * scale, scale);

    // === LEGS ===
    final legLen = 52 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 10 * scale),
      Offset(centerX - 12 * scale, hipY + legLen * 0.5),
      Offset(centerX - 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 10 * scale),
      Offset(centerX + 12 * scale, hipY + legLen * 0.5),
      Offset(centerX + 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 10 * scale, hipY + legLen),
        Offset(centerX - 20 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 10 * scale, hipY + legLen),
        Offset(centerX + 20 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === TRICEP PUSHDOWN MOTION ===
    final pushY = centerY - 8 * scale + (progress * 35 * scale);

    // Cable from pulley to handle
    drawCable(canvas, Offset(centerX, centerY - 48 * scale),
        Offset(centerX, pushY - 8 * scale), 2 * scale);

    // V-bar handle
    final handlePaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX - 22 * scale, pushY),
        Offset(centerX, pushY - 8 * scale), handlePaint);
    canvas.drawLine(Offset(centerX + 22 * scale, pushY),
        Offset(centerX, pushY - 8 * scale), handlePaint);

    // Grip ends
    drawCableHandle(canvas, Offset(centerX - 22 * scale, pushY), 5 * scale, 0);
    drawCableHandle(canvas, Offset(centerX + 22 * scale, pushY), 5 * scale, 0);

    // === ARMS ===
    final armFlex = 0.3 + (progress * 0.4);

    // Upper arms fixed against body, forearms moving
    // Left arm
    final leftShoulder = Offset(centerX - 18 * scale, centerY - 18 * scale);
    final leftElbow = Offset(centerX - 18 * scale, centerY - 2 * scale);
    final leftHand = Offset(centerX - 22 * scale, pushY);

    drawMuscularArm(
        canvas, leftShoulder, leftElbow, leftHand, 8 * scale, armFlex);
    drawCompleteHand(canvas, leftHand, 5 * scale, 0.2, gripping: true);

    // Right arm
    final rightShoulder = Offset(centerX + 18 * scale, centerY - 18 * scale);
    final rightElbow = Offset(centerX + 18 * scale, centerY - 2 * scale);
    final rightHand = Offset(centerX + 22 * scale, pushY);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 8 * scale, armFlex);
    drawCompleteHand(canvas, rightHand, 5 * scale, -0.2, gripping: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SkullCrusherPainter extends ExercisePainterBase {
  SkullCrusherPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 45 * scale, size.width, 55 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 45 * scale, size.width, 55 * scale),
        floorPaint);

    // === FLAT BENCH ===
    // Bench legs
    canvas.drawRect(
      Rect.fromLTWH(
          centerX - 55 * scale, centerY + 30 * scale, 8 * scale, 25 * scale),
      Paint()..color = Colors.grey[700]!,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          centerX + 45 * scale, centerY + 30 * scale, 8 * scale, 25 * scale),
      Paint()..color = Colors.grey[700]!,
    );

    // Bench pad
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 65 * scale, centerY + 15 * scale, 130 * scale,
            16 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );
    // Bench frame
    canvas.drawRect(
      Rect.fromLTWH(
          centerX - 65 * scale, centerY + 28 * scale, 130 * scale, 6 * scale),
      Paint()..color = Colors.grey[800]!,
    );

    // === LYING FIGURE ===
    final bodyY = centerY + 10 * scale;

    // Head at left end of bench
    drawCompleteHead(
        canvas, Offset(centerX - 48 * scale, bodyY - 5 * scale), scale * 0.9,
        rotation: math.pi / 2);

    // Tricep highlights (target muscles)
    drawMuscleHighlight(canvas, Offset(centerX - 8 * scale, bodyY - 18 * scale),
        10 * scale, primaryColor);

    // === HORIZONTAL TANK TOP (lying down) ===
    const jerseyColor = Color(0xFF1A1A2E);

    final torsoPath = Path();
    // Lying horizontally
    torsoPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(
          centerX - 35 * scale, bodyY - 15 * scale, 70 * scale, 28 * scale),
      Radius.circular(5 * scale),
    ));
    canvas.drawPath(torsoPath, Paint()..color = jerseyColor);

    // Chest visible
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX - 15 * scale, bodyY - 5 * scale),
          width: 18 * scale,
          height: 12 * scale),
      Paint()..color = Colors.black.withOpacity(0.1),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 5 * scale, bodyY - 5 * scale),
          width: 18 * scale,
          height: 12 * scale),
      Paint()..color = Colors.black.withOpacity(0.1),
    );

    // === GYM SHORTS ===
    drawGymShorts(canvas, Offset(centerX + 40 * scale, bodyY), 28 * scale,
        22 * scale, scale);

    // === LEGS (bent at end of bench) ===
    // Upper leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 48 * scale, bodyY + 5 * scale),
      Offset(centerX + 55 * scale, bodyY + 30 * scale),
      Offset(centerX + 50 * scale, centerY + 50 * scale),
      10 * scale,
    );

    // Gym shoe
    drawGymShoe(canvas, Offset(centerX + 50 * scale, centerY + 50 * scale),
        Offset(centerX + 58 * scale, centerY + 55 * scale), 7 * scale);

    // === SKULL CRUSHER MOTION ===
    final barAngle = progress * 0.8;
    final barY = bodyY - 32 * scale - (math.sin(barAngle) * 22 * scale);
    final barX = centerX - 8 * scale - (math.cos(barAngle) * 12 * scale);

    // === ARMS ===
    final armFlex = 0.4 + (progress * 0.4);

    // Left arm
    final leftShoulder = Offset(centerX - 18 * scale, bodyY - 8 * scale);
    final leftElbow = Offset(centerX - 22 * scale, bodyY - 28 * scale);
    final leftHand = Offset(barX - 10 * scale, barY);

    drawMuscularArm(
        canvas, leftShoulder, leftElbow, leftHand, 7 * scale, armFlex);
    drawCompleteHand(canvas, leftHand, 5 * scale, -math.pi / 4, gripping: true);

    // Right arm
    final rightShoulder = Offset(centerX + 8 * scale, bodyY - 8 * scale);
    final rightElbow = Offset(centerX + 5 * scale, bodyY - 28 * scale);
    final rightHand = Offset(barX + 22 * scale, barY);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 7 * scale, armFlex);
    drawCompleteHand(canvas, rightHand, 5 * scale, -math.pi / 4,
        gripping: true);

    // === EZ BAR ===
    drawBarbell(
      canvas,
      Offset(barX - 28 * scale, barY),
      Offset(barX + 38 * scale, barY),
      9 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== LEG EXERCISES ====================

class SquatPainter extends ExercisePainterBase {
  SquatPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // Gym floor
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 65 * scale, size.width, 35 * scale),
        floorPaint);

    // Squat depth animation
    final squatDepth = progress * 35 * scale;
    final headY = centerY - 55 * scale + squatDepth;

    // Body forward lean during squat
    final torsoLean = progress * 0.25;

    // Hip position
    final hipY = headY + 70 * scale;
    final hipX = centerX + (progress * 8 * scale);

    // === MUSCULAR STANDING/SQUATTING FIGURE WITH GYM CLOTHES ===

    // Draw head with detailed features
    drawCompleteHead(canvas, Offset(centerX, headY), scale * 1.1, rotation: 0);

    // Draw muscular torso with tank top and forward lean
    canvas.save();
    canvas.translate(centerX, headY + 25 * scale);
    canvas.rotate(torsoLean);

    // Torso shape with tank top
    final torsoWidth = 50 * scale;
    final torsoHeight = 55 * scale;

    final torsoPath = Path();
    torsoPath.moveTo(-torsoWidth * 0.4, 0);
    // Left shoulder/delt
    torsoPath.quadraticBezierTo(-torsoWidth * 0.55, torsoHeight * 0.1,
        -torsoWidth * 0.5, torsoHeight * 0.25);
    // Left lat
    torsoPath.quadraticBezierTo(-torsoWidth * 0.55, torsoHeight * 0.5,
        -torsoWidth * 0.35, torsoHeight * 0.8);
    // Left oblique to waist
    torsoPath.quadraticBezierTo(
        -torsoWidth * 0.3, torsoHeight * 0.95, -torsoWidth * 0.25, torsoHeight);
    // Waist
    torsoPath.lineTo(torsoWidth * 0.25, torsoHeight);
    // Right oblique
    torsoPath.quadraticBezierTo(torsoWidth * 0.3, torsoHeight * 0.95,
        torsoWidth * 0.35, torsoHeight * 0.8);
    // Right lat
    torsoPath.quadraticBezierTo(torsoWidth * 0.55, torsoHeight * 0.5,
        torsoWidth * 0.5, torsoHeight * 0.25);
    // Right shoulder
    torsoPath.quadraticBezierTo(
        torsoWidth * 0.55, torsoHeight * 0.1, torsoWidth * 0.4, 0);
    torsoPath.close();

    // Tank top colors
    const jerseyColor = Color(0xFF1A1A2E);
    const jerseyHighlight = Color(0xFF2D3A4F);

    final jerseyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [jerseyHighlight, jerseyColor, jerseyColor],
      ).createShader(
          Rect.fromLTRB(-torsoWidth * 0.55, 0, torsoWidth * 0.55, torsoHeight));
    canvas.drawPath(torsoPath, jerseyPaint);

    // Tank top V-neck showing chest
    final neckPath = Path();
    neckPath.moveTo(-12 * scale, 0);
    neckPath.quadraticBezierTo(0, 15 * scale, 12 * scale, 0);
    canvas.drawPath(neckPath, Paint()..color = skinColor);

    // Arm holes showing shoulders
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-torsoWidth * 0.45, torsoHeight * 0.15),
        width: 14 * scale,
        height: 18 * scale,
      ),
      Paint()..color = skinColor,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(torsoWidth * 0.45, torsoHeight * 0.15),
        width: 14 * scale,
        height: 18 * scale,
      ),
      Paint()..color = skinColor,
    );

    // Jersey brand stripe
    canvas.drawLine(
      Offset(-6 * scale, 5 * scale),
      Offset(-6 * scale, torsoHeight - 5 * scale),
      Paint()
        ..color = const Color(0xFFE94560)
        ..strokeWidth = 2 * scale,
    );

    // Muscle definition visible through tight tank top
    final muscleOutline = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Pecs outline
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-10 * scale, torsoHeight * 0.18),
          width: 16 * scale,
          height: 11 * scale),
      muscleOutline,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(10 * scale, torsoHeight * 0.18),
          width: 16 * scale,
          height: 11 * scale),
      muscleOutline,
    );

    canvas.restore();

    // Draw gym shorts on hips area
    drawGymShorts(
        canvas, Offset(hipX, hipY - 10 * scale), 44 * scale, 28 * scale, scale);

    // === BARBELL ON SHOULDERS ===
    final barbellY = headY + 12 * scale;
    drawBarbell(
      canvas,
      Offset(centerX - 55 * scale, barbellY),
      Offset(centerX + 55 * scale, barbellY),
      16 * scale,
    );

    // Arms holding bar on shoulders
    final shoulderY = headY + 28 * scale;
    drawMuscularArm(
      canvas,
      Offset(centerX - 18 * scale, shoulderY),
      Offset(centerX - 30 * scale, barbellY + 8 * scale),
      Offset(centerX - 40 * scale, barbellY),
      8 * scale,
      0.3,
    );
    drawMuscularArm(
      canvas,
      Offset(centerX + 18 * scale, shoulderY),
      Offset(centerX + 30 * scale, barbellY + 8 * scale),
      Offset(centerX + 40 * scale, barbellY),
      8 * scale,
      0.3,
    );

    // === MUSCULAR LEGS IN SQUAT POSITION ===
    final kneeY = hipY + 30 * scale - (progress * 15 * scale);
    final footY = centerY + 68 * scale;
    final legSpread = 20 * scale + (progress * 8 * scale);

    // Quad highlight during squat
    final quadFlex = 0.5 + progress * 0.5;
    drawMuscleHighlight(
        canvas,
        Offset(centerX - legSpread * 0.7, kneeY - 10 * scale),
        22 * scale * quadFlex,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + legSpread * 0.7, kneeY - 10 * scale),
        22 * scale * quadFlex,
        primaryColor);

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(hipX - 12 * scale, hipY),
      Offset(centerX - legSpread, kneeY),
      Offset(centerX - legSpread * 0.9, footY),
      14 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(hipX + 12 * scale, hipY),
      Offset(centerX + legSpread, kneeY),
      Offset(centerX + legSpread * 0.9, footY),
      14 * scale,
    );

    // Gym shoes
    drawGymShoe(
        canvas,
        Offset(centerX - legSpread * 0.9, footY),
        Offset(centerX - legSpread * 0.9 + 14 * scale, footY + 5 * scale),
        8 * scale);
    drawGymShoe(
        canvas,
        Offset(centerX + legSpread * 0.9, footY),
        Offset(centerX + legSpread * 0.9 + 14 * scale, footY + 5 * scale),
        8 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LegPressPainter extends ExercisePainterBase {
  LegPressPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === LEG PRESS MACHINE FRAME ===
    final metalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey[600]!, Colors.grey[300]!, Colors.grey[500]!],
      ).createShader(Rect.fromLTWH(centerX - 60 * scale, centerY - 60 * scale,
          130 * scale, 130 * scale));

    // Main angled rails of the machine (flipped - going from right to left)
    canvas.save();
    canvas.translate(centerX + 30 * scale, centerY + 55 * scale);
    canvas.rotate(0.65);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-110 * scale, 0, 110 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-110 * scale, -10 * scale, 110 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );
    canvas.restore();

    // === SEAT (reclined at bottom RIGHT) ===
    // Seat base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX + 25 * scale, centerY + 25 * scale, 45 * scale, 12 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );

    // Back rest (reclined angle - flipped)
    canvas.save();
    canvas.translate(centerX + 70 * scale, centerY + 25 * scale);
    canvas.rotate(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-6 * scale, -40 * scale, 14 * scale, 45 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );
    canvas.restore();

    // === WOMAN SITTING ON MACHINE ===
    // Head at RIGHT side, feet pressing LEFT toward the plate
    
    // === HEAD (reclined position, facing LEFT toward legs) ===
    final headX = centerX + 58 * scale;
    final headY = centerY - 8 * scale;
    
    // Head shape
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX, headY),
          width: 18 * scale,
          height: 20 * scale),
      Paint()..color = skinColor,
    );
    
    // Hair (ponytail style - going RIGHT, away from legs)
    const hairColor = Color(0xFF4A3728);
    // Top hair
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(headX, headY - 5 * scale),
          width: 20 * scale,
          height: 16 * scale),
      -math.pi * 0.9,
      math.pi * 1.8,
      true,
      Paint()..color = hairColor,
    );
    // Ponytail going back (RIGHT side, away from legs)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 12 * scale, headY + 2 * scale),
          width: 12 * scale,
          height: 8 * scale),
      Paint()..color = hairColor,
    );
    
    // Eye (on LEFT side, looking toward legs/plate)
    canvas.drawCircle(Offset(headX - 5 * scale, headY - 1 * scale), 2 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(headX - 6 * scale, headY - 1 * scale), 1 * scale,
        Paint()..color = Colors.brown[800]!);
    
    // Ear (on RIGHT side)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 8 * scale, headY),
          width: 4 * scale,
          height: 6 * scale),
      Paint()..color = skinColor,
    );

    // === NECK (connecting to torso on LEFT side) ===
    canvas.drawLine(
      Offset(headX - 7 * scale, headY + 6 * scale),
      Offset(headX - 15 * scale, headY + 12 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 8 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Quad highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 5 * scale, centerY + 5 * scale),
        16 * scale,
        primaryColor);

    // === SPORTS BRA / TOP ===
    const topColor = Color(0xFF1A1A2E);
    
    // Torso (reclined, angled toward left)
    canvas.save();
    canvas.translate(headX - 18 * scale, headY + 15 * scale);
    canvas.rotate(-0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-27 * scale, -8 * scale, 35 * scale, 22 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = topColor,
    );
    canvas.restore();

    // === GYM SHORTS ===
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX + 5 * scale, centerY + 18 * scale, 25 * scale, 16 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = const Color(0xFF2D3436),
    );

    // === LEG PRESS MOTION ===
    // Legs extend LEFT to press the plate
    final pressExtension = progress * 20 * scale;
    
    // Hip position (on right side)
    final hipX = centerX + 22 * scale;
    final hipY = centerY + 25 * scale;
    
    // Knee position (bends during press, moving left)
    final kneeX = centerX - 5 * scale - (progress * 8 * scale);
    final kneeY = centerY + 5 * scale - (progress * 8 * scale);
    
    // Foot/ankle position (on the plate, left side)
    final footX = centerX - 30 * scale - pressExtension;
    final footY = centerY - 25 * scale - pressExtension * 0.5;

    // === MUSCULAR LEGS (both visible) ===
    // Right leg (front)
    // Thigh
    canvas.drawLine(
      Offset(hipX - 5 * scale, hipY),
      Offset(kneeX, kneeY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Calf
    canvas.drawLine(
      Offset(kneeX, kneeY),
      Offset(footX + 8 * scale, footY + 5 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );
    
    // Left leg (back, slightly offset)
    // Thigh
    canvas.drawLine(
      Offset(hipX, hipY + 3 * scale),
      Offset(kneeX + 5 * scale, kneeY + 5 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 13 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Calf
    canvas.drawLine(
      Offset(kneeX + 5 * scale, kneeY + 5 * scale),
      Offset(footX + 12 * scale, footY + 10 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 11 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === SHOES ON FOOT PLATE ===
    // Right shoe (front foot)
    final rightShoeX = footX + 5 * scale;
    final rightShoeY = footY + 3 * scale;
    
    // Shoe body (flipped orientation)
    final rightShoePath = Path();
    rightShoePath.moveTo(rightShoeX + 8 * scale, rightShoeY + 5 * scale);
    rightShoePath.lineTo(rightShoeX - 8 * scale, rightShoeY - 3 * scale);
    rightShoePath.lineTo(rightShoeX - 12 * scale, rightShoeY + 2 * scale);
    rightShoePath.lineTo(rightShoeX - 5 * scale, rightShoeY + 10 * scale);
    rightShoePath.lineTo(rightShoeX + 5 * scale, rightShoeY + 12 * scale);
    rightShoePath.close();
    canvas.drawPath(rightShoePath, Paint()..color = Colors.pink[400]!);
    
    // Shoe sole
    canvas.drawLine(
      Offset(rightShoeX - 8 * scale, rightShoeY - 2 * scale),
      Offset(rightShoeX - 12 * scale, rightShoeY + 3 * scale),
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 3 * scale
        ..strokeCap = StrokeCap.round,
    );
    
    // Left shoe (back foot)
    final leftShoeX = footX + 10 * scale;
    final leftShoeY = footY + 10 * scale;
    
    final leftShoePath = Path();
    leftShoePath.moveTo(leftShoeX + 8 * scale, leftShoeY + 5 * scale);
    leftShoePath.lineTo(leftShoeX - 6 * scale, leftShoeY - 2 * scale);
    leftShoePath.lineTo(leftShoeX - 10 * scale, leftShoeY + 3 * scale);
    leftShoePath.lineTo(leftShoeX - 4 * scale, leftShoeY + 10 * scale);
    leftShoePath.lineTo(leftShoeX + 5 * scale, leftShoeY + 11 * scale);
    leftShoePath.close();
    canvas.drawPath(leftShoePath, Paint()..color = Colors.pink[400]!);
    
    // Shoe sole
    canvas.drawLine(
      Offset(leftShoeX - 6 * scale, leftShoeY - 1 * scale),
      Offset(leftShoeX - 10 * scale, leftShoeY + 4 * scale),
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 3 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === FOOT PLATE (angled, where feet press - on LEFT side) ===
    canvas.save();
    canvas.translate(footX - 15 * scale, footY);
    canvas.rotate(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2 * scale, -20 * scale, 10 * scale, 40 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.grey[600]!,
    );
    // Foot plate surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6 * scale, -18 * scale, 6 * scale, 36 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.grey[800]!,
    );
    canvas.restore();

    // === ARMS (holding side handles on RIGHT) ===
    final shoulderX = headX - 22 * scale;
    final shoulderY = headY + 18 * scale;
    
    // Right arm holding handle
    final rightHandleX = centerX + 58 * scale;
    final rightHandleY = centerY + 15 * scale;
    
    canvas.drawLine(
      Offset(shoulderX, shoulderY),
      Offset(shoulderX + 10 * scale, shoulderY + 8 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 7 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(shoulderX + 10 * scale, shoulderY + 8 * scale),
      Offset(rightHandleX, rightHandleY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 6 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Hand gripping handle
    canvas.drawCircle(
        Offset(rightHandleX, rightHandleY), 5 * scale, Paint()..color = skinColor);
    
    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            rightHandleX - 3 * scale, rightHandleY - 8 * scale, 6 * scale, 16 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.grey[700]!,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LungePainter extends ExercisePainterBase {
  LungePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 60 * scale, size.width, 40 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 60 * scale, size.width, 40 * scale),
        floorPaint);

    final groundY = centerY + 60 * scale;
    final lungeDepth = progress * 18 * scale;

    // === STANDING/LUNGING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 42 * scale + lungeDepth), scale,
        rotation: 0);

    // Quad/glute highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 12 * scale, centerY + 8 * scale),
        14 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 8 * scale + lungeDepth),
        44 * scale, 48 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 18 * scale + lungeDepth;
    drawGymShorts(canvas, Offset(centerX, hipY - 5 * scale), 36 * scale,
        22 * scale, scale);

    // === FRONT LEG (bent in lunge) ===
    final frontKneeY = centerY + 28 * scale + lungeDepth;
    drawMuscularLeg(
      canvas,
      Offset(centerX - 5 * scale, hipY + 5 * scale),
      Offset(centerX - 18 * scale, frontKneeY),
      Offset(centerX - 22 * scale, groundY),
      10 * scale,
    );
    drawGymShoe(canvas, Offset(centerX - 22 * scale, groundY),
        Offset(centerX - 32 * scale, groundY + 5 * scale), 7 * scale);

    // === BACK LEG (extended back) ===
    drawMuscularLeg(
      canvas,
      Offset(centerX + 5 * scale, hipY + 5 * scale),
      Offset(centerX + 28 * scale, centerY + 32 * scale),
      Offset(centerX + 42 * scale, groundY - 8 * scale),
      9 * scale,
    );
    drawGymShoe(canvas, Offset(centerX + 42 * scale, groundY - 8 * scale),
        Offset(centerX + 50 * scale, groundY - 5 * scale), 6 * scale);

    // === ARMS HOLDING DUMBBELLS ===
    final leftShoulder =
        Offset(centerX - 18 * scale, centerY - 22 * scale + lungeDepth);
    final leftElbow =
        Offset(centerX - 22 * scale, centerY + 5 * scale + lungeDepth);
    final leftHand =
        Offset(centerX - 22 * scale, centerY + 18 * scale + lungeDepth);

    drawMuscularArm(canvas, leftShoulder, leftElbow, leftHand, 7 * scale, 0.2);
    drawCompleteHand(canvas, leftHand, 5 * scale, 0, gripping: true);

    final rightShoulder =
        Offset(centerX + 18 * scale, centerY - 22 * scale + lungeDepth);
    final rightElbow =
        Offset(centerX + 22 * scale, centerY + 5 * scale + lungeDepth);
    final rightHand =
        Offset(centerX + 22 * scale, centerY + 18 * scale + lungeDepth);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 7 * scale, 0.2);
    drawCompleteHand(canvas, rightHand, 5 * scale, 0, gripping: true);

    // === DUMBBELLS ===
    drawDumbbell(canvas, Offset(leftHand.dx, leftHand.dy + 5 * scale),
        18 * scale, 6 * scale, 0);
    drawDumbbell(canvas, Offset(rightHand.dx, rightHand.dy + 5 * scale),
        18 * scale, 6 * scale, 0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LegCurlPainter extends ExercisePainterBase {
  LegCurlPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 40 * scale, size.width, 60 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 40 * scale, size.width, 60 * scale),
        floorPaint);

    final groundY = centerY + 40 * scale;

    // === LEG CURL MACHINE ===
    final metalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey[600]!, Colors.grey[300]!, Colors.grey[500]!],
      ).createShader(Rect.fromLTWH(centerX - 70 * scale, centerY - 40 * scale,
          140 * scale, 100 * scale));

    // Machine base frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 70 * scale, groundY - 5 * scale, 140 * scale, 8 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );

    // Front leg support
    canvas.drawRect(
      Rect.fromLTWH(
          centerX - 65 * scale, centerY + 15 * scale, 8 * scale, 30 * scale),
      metalPaint,
    );

    // Rear vertical post (weight stack side)
    canvas.drawRect(
      Rect.fromLTWH(
          centerX + 55 * scale, centerY - 35 * scale, 10 * scale, 80 * scale),
      metalPaint,
    );

    // === WEIGHT STACK ===
    for (int i = 0; i < 6; i++) {
      final stackY = centerY - 30 * scale + (i * 10 * scale);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              centerX + 58 * scale, stackY, 15 * scale, 8 * scale),
          Radius.circular(1 * scale),
        ),
        Paint()..color = i < 3 ? Colors.grey[700]! : Colors.grey[500]!,
      );
    }

    // Weight guide rod
    canvas.drawLine(
      Offset(centerX + 75 * scale, centerY - 35 * scale),
      Offset(centerX + 75 * scale, centerY + 35 * scale),
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 2 * scale,
    );

    // === BENCH PAD (lying surface) ===
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 65 * scale, centerY + 5 * scale, 100 * scale, 14 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );

    // Thigh pad / support
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 65 * scale, centerY - 5 * scale, 30 * scale, 12 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.red[800]!,
    );

    // === LEVER ARM MECHANISM ===
    final curlAngle = progress * (math.pi * 0.55);
    
    // Pivot point at end of bench
    final pivotX = centerX + 35 * scale;
    final pivotY = centerY + 12 * scale;
    
    // Lever arm (rotates with curl)
    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(-curlAngle);
    
    // Lever arm bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -3 * scale, 40 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );
    
    // Ankle roller pad at end of lever
    canvas.drawCircle(
        Offset(38 * scale, 0), 8 * scale, Paint()..color = Colors.grey[600]!);
    canvas.drawCircle(
        Offset(38 * scale, 0), 5 * scale, Paint()..color = Colors.black);
    
    canvas.restore();

    // Cable from weight stack to lever
    final cableEndX = pivotX + math.cos(-curlAngle + 0.3) * 25 * scale;
    final cableEndY = pivotY + math.sin(-curlAngle + 0.3) * 25 * scale;
    canvas.drawLine(
      Offset(centerX + 60 * scale, centerY + 30 * scale),
      Offset(cableEndX, cableEndY),
      Paint()
        ..color = Colors.grey[800]!
        ..strokeWidth = 2 * scale,
    );

    // === LYING FACE DOWN FIGURE ===
    final bodyY = centerY + 2 * scale;

    // === HEAD (face down, resting on bench) ===
    final headX = centerX - 48 * scale;
    final headY = bodyY + 2 * scale;
    
    // Head (profile, facing down)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX, headY),
          width: 18 * scale,
          height: 20 * scale),
      Paint()..color = skinColor,
    );
    
    // Hair
    const hairColor = Color(0xFF2C1810);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(headX, headY - 5 * scale),
          width: 20 * scale,
          height: 14 * scale),
      -math.pi * 0.9,
      math.pi * 1.8,
      true,
      Paint()..color = hairColor,
    );
    
    // Ear
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 8 * scale, headY),
          width: 4 * scale,
          height: 6 * scale),
      Paint()..color = skinColor,
    );

    // Hamstring highlights (target muscles)
    drawMuscleHighlight(canvas, Offset(centerX + 20 * scale, bodyY - 8 * scale),
        14 * scale, primaryColor);

    // === TANK TOP (lying prone on bench) ===
    const jerseyColor = Color(0xFF1A1A2E);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 35 * scale, bodyY - 10 * scale, 50 * scale, 20 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = jerseyColor,
    );

    // Neck
    canvas.drawLine(
      Offset(headX + 8 * scale, headY),
      Offset(centerX - 35 * scale, bodyY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 8 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === GYM SHORTS ===
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX + 10 * scale, bodyY - 8 * scale, 22 * scale, 16 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = const Color(0xFF2D3436),
    );

    // === ARMS (resting, gripping front handles) ===
    // Handle bars at front
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 60 * scale, centerY + 20 * scale, 6 * scale, 15 * scale),
        Radius.circular(2 * scale),
      ),
      metalPaint,
    );

    // Left arm gripping handle
    canvas.drawLine(
      Offset(centerX - 32 * scale, bodyY + 5 * scale),
      Offset(centerX - 45 * scale, bodyY + 15 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 7 * scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(centerX - 45 * scale, bodyY + 15 * scale),
      Offset(centerX - 57 * scale, centerY + 25 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 6 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Hand
    canvas.drawCircle(
        Offset(centerX - 57 * scale, centerY + 25 * scale), 5 * scale, 
        Paint()..color = skinColor);

    // === THIGHS (on bench, stationary) ===
    // Upper legs lying on bench
    canvas.drawLine(
      Offset(centerX + 15 * scale, bodyY + 2 * scale),
      Offset(centerX + 32 * scale, bodyY + 5 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === LOWER LEGS (curling with the lever) ===
    // Lower legs follow the lever arm rotation
    final kneeX = centerX + 32 * scale;
    final kneeY = bodyY + 5 * scale;
    
    // Calculate foot position based on curl angle
    final footX = kneeX + math.cos(-curlAngle - 0.2) * 30 * scale;
    final footY = kneeY + math.sin(-curlAngle - 0.2) * 30 * scale;
    
    // Lower leg (calf)
    canvas.drawLine(
      Offset(kneeX, kneeY),
      Offset(footX, footY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 12 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === GYM SHOES (on ankle pad) ===
    // Right shoe
    final shoeAngle = -curlAngle - 0.2;
    canvas.save();
    canvas.translate(footX, footY);
    canvas.rotate(shoeAngle);
    
    // Shoe body
    final shoePath = Path();
    shoePath.moveTo(-4 * scale, -6 * scale);
    shoePath.lineTo(12 * scale, -6 * scale);
    shoePath.lineTo(14 * scale, 0);
    shoePath.lineTo(12 * scale, 6 * scale);
    shoePath.lineTo(-4 * scale, 6 * scale);
    shoePath.close();
    canvas.drawPath(shoePath, Paint()..color = Colors.red[700]!);
    
    // Shoe sole
    canvas.drawLine(
      Offset(12 * scale, -5 * scale),
      Offset(14 * scale, 5 * scale),
      Paint()
        ..color = Colors.grey[900]!
        ..strokeWidth = 3 * scale,
    );
    
    // Shoe laces area
    canvas.drawLine(
      Offset(2 * scale, -4 * scale),
      Offset(8 * scale, -4 * scale),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2 * scale,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LegExtensionPainter extends ExercisePainterBase {
  LegExtensionPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 55 * scale, size.width, 45 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 55 * scale, size.width, 45 * scale),
        floorPaint);

    // === LEG EXTENSION MACHINE ===
    // Back rest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 48 * scale, centerY - 40 * scale, 14 * scale, 55 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );

    // Seat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 42 * scale, centerY + 12 * scale, 58 * scale, 14 * scale),
        Radius.circular(3 * scale),
      ),
      Paint()..color = Colors.red[900]!,
    );

    // Frame/support
    canvas.drawRect(
      Rect.fromLTWH(
          centerX - 52 * scale, centerY + 20 * scale, 8 * scale, 40 * scale),
      Paint()..color = Colors.grey[700]!,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          centerX + 12 * scale, centerY + 20 * scale, 8 * scale, 40 * scale),
      Paint()..color = Colors.grey[700]!,
    );

    // === SEATED MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(canvas, Offset(centerX - 22 * scale, centerY - 48 * scale),
        scale * 0.95,
        rotation: 0);

    // Quad highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 8 * scale, centerY + 5 * scale),
        14 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX - 18 * scale, centerY - 15 * scale),
        40 * scale, 45 * scale, scale);

    // === GYM SHORTS ===
    drawGymShorts(canvas, Offset(centerX - 8 * scale, centerY + 12 * scale),
        34 * scale, 18 * scale, scale);

    // === ARMS (holding side handles) ===
    final leftShoulder = Offset(centerX - 32 * scale, centerY - 28 * scale);
    final leftHand = Offset(centerX - 40 * scale, centerY + 2 * scale);
    drawMuscularArm(
        canvas,
        leftShoulder,
        Offset(centerX - 38 * scale, centerY - 12 * scale),
        leftHand,
        6 * scale,
        0.2);
    drawCompleteHand(canvas, leftHand, 5 * scale, 0.4, gripping: true);

    // === LEG EXTENSION MOTION ===
    final extensionAngle = progress * (math.pi * 0.45);

    // Thighs (on seat)
    drawMuscularLeg(
      canvas,
      Offset(centerX - 8 * scale, centerY + 18 * scale),
      Offset(centerX + 15 * scale, centerY + 16 * scale),
      Offset(centerX + 25 * scale, centerY + 14 * scale),
      10 * scale,
    );

    // Lower legs (extending)
    final footX =
        centerX + 25 * scale + (math.cos(extensionAngle) * 38 * scale);
    final footY =
        centerY + 14 * scale - (math.sin(extensionAngle) * 38 * scale);

    drawMuscularLeg(
      canvas,
      Offset(centerX + 25 * scale, centerY + 14 * scale),
      Offset((centerX + 25 * scale + footX) / 2,
          (centerY + 14 * scale + footY) / 2 - 3 * scale),
      Offset(footX, footY),
      9 * scale,
    );

    // Ankle roller
    canvas.drawCircle(Offset(footX, footY + 5 * scale), 7 * scale,
        Paint()..color = Colors.grey[600]!);
    canvas.drawCircle(Offset(footX, footY + 5 * scale), 4 * scale,
        Paint()..color = Colors.grey[300]!);

    // Gym shoe
    drawGymShoe(canvas, Offset(footX, footY),
        Offset(footX + 10 * scale, footY - 3 * scale), 6 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CalfRaisePainter extends ExercisePainterBase {
  CalfRaisePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 62 * scale, size.width, 38 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 62 * scale, size.width, 38 * scale),
        floorPaint);

    // === CALF RAISE PLATFORM ===
    // Elevated platform/step
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 32 * scale, centerY + 55 * scale, 64 * scale, 12 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.grey[700]!,
    );
    // Platform top surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 32 * scale, centerY + 53 * scale, 64 * scale, 5 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.grey[500]!,
    );

    // Raise height animation
    final raiseHeight = progress * 12 * scale;

    // === STANDING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 48 * scale - raiseHeight), scale,
        rotation: 0);

    // Calf highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 10 * scale, centerY + 38 * scale - raiseHeight),
        10 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 10 * scale, centerY + 38 * scale - raiseHeight),
        10 * scale,
        primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 12 * scale - raiseHeight),
        46 * scale, 52 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 18 * scale - raiseHeight;
    drawGymShorts(canvas, Offset(centerX, hipY), 38 * scale, 24 * scale, scale);

    // === ARMS (holding rail for balance) ===
    // Support rail/bar
    canvas.drawRect(
      Rect.fromLTWH(
          centerX - 45 * scale, centerY - 20 * scale, 5 * scale, 60 * scale),
      Paint()..color = Colors.grey[600]!,
    );

    final leftShoulder =
        Offset(centerX - 18 * scale, centerY - 28 * scale - raiseHeight);
    final leftHand = Offset(centerX - 42 * scale, centerY - 15 * scale);
    drawMuscularArm(
        canvas,
        leftShoulder,
        Offset(centerX - 32 * scale, centerY - 22 * scale - raiseHeight / 2),
        leftHand,
        7 * scale,
        0.25);
    drawCompleteHand(canvas, leftHand, 5 * scale, 0.3, gripping: true);

    // Right arm at side
    final rightShoulder =
        Offset(centerX + 18 * scale, centerY - 28 * scale - raiseHeight);
    final rightElbow =
        Offset(centerX + 22 * scale, centerY - 8 * scale - raiseHeight);
    final rightHand =
        Offset(centerX + 24 * scale, centerY + 12 * scale - raiseHeight);
    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 7 * scale, 0.2);
    drawCompleteHand(canvas, rightHand, 5 * scale, 0, gripping: false);

    // === MUSCULAR LEGS ===
    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 12 * scale),
      Offset(centerX - 10 * scale, centerY + 38 * scale - raiseHeight),
      Offset(centerX - 10 * scale, centerY + 52 * scale - raiseHeight * 0.3),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 12 * scale),
      Offset(centerX + 10 * scale, centerY + 38 * scale - raiseHeight),
      Offset(centerX + 10 * scale, centerY + 52 * scale - raiseHeight * 0.3),
      10 * scale,
    );

    // === GYM SHOES (on balls of feet) ===
    // Feet on platform - balls of feet on edge
    drawGymShoe(
        canvas,
        Offset(centerX - 10 * scale, centerY + 52 * scale - raiseHeight * 0.3),
        Offset(centerX - 18 * scale, centerY + 55 * scale),
        6 * scale);
    drawGymShoe(
        canvas,
        Offset(centerX + 10 * scale, centerY + 52 * scale - raiseHeight * 0.3),
        Offset(centerX + 18 * scale, centerY + 55 * scale),
        6 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== CORE EXERCISES ====================

class PlankPainter extends ExercisePainterBase {
  PlankPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 40 * scale, size.width, 60 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 40 * scale, size.width, 60 * scale),
        floorPaint);

    // Yoga mat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 80 * scale, centerY + 37 * scale, 160 * scale, 8 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.purple[900]!,
    );

    final groundY = centerY + 40 * scale;

    // Up and down movement for animation (core engagement)
    final wobble = math.sin(progress * math.pi * 2) * 6 * scale;

    // === PROPER PLANK POSITION ===
    // Side view: Head on right, toes on left, body horizontal

    // Body is mostly horizontal with slight angle
    final bodyY = centerY - 5 * scale + wobble;

    // === HEAD (at right side, looking down at ground) ===
    final headX = centerX + 60 * scale;
    final headY = bodyY - 8 * scale;
    
    // Head (profile view looking down)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX, headY),
          width: 20 * scale,
          height: 22 * scale),
      Paint()..color = skinColor,
    );
    
    // === HAIR (short sporty style) ===
    const hairColor = Color(0xFF2C1810);
    // Top of head hair
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(headX + 2 * scale, headY - 6 * scale),
          width: 20 * scale,
          height: 16 * scale),
      -math.pi * 0.9,
      math.pi * 1.8,
      true,
      Paint()..color = hairColor,
    );
    // Side hair strands
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi * 0.5 + (i * 0.3);
      final startX = headX + 2 * scale + math.cos(angle) * 8 * scale;
      final startY = headY - 6 * scale + math.sin(angle) * 6 * scale;
      final endX = startX + math.cos(angle) * 4 * scale;
      final endY = startY + math.sin(angle) * 3 * scale;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = hairColor
          ..strokeWidth = 2 * scale
          ..strokeCap = StrokeCap.round,
      );
    }
    // Back of head hair
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 8 * scale, headY - 2 * scale),
          width: 8 * scale,
          height: 12 * scale),
      Paint()..color = hairColor,
    );
    
    // Eye (looking down)
    canvas.drawCircle(Offset(headX - 5 * scale, headY + 2 * scale), 2 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(headX - 5 * scale, headY + 3 * scale), 1 * scale,
        Paint()..color = Colors.brown[800]!);
    
    // Ear
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 8 * scale, headY + 2 * scale),
          width: 5 * scale,
          height: 7 * scale),
      Paint()..color = skinColor,
    );

    // === NECK ===
    canvas.drawLine(
      Offset(headX - 8 * scale, headY + 8 * scale),
      Offset(headX - 18 * scale, bodyY + 5 * scale),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Core highlights (target muscles)
    drawMuscleHighlight(
        canvas, Offset(centerX - 5 * scale, bodyY + 5 * scale), 18 * scale, primaryColor);

    // === TANK TOP (horizontal torso) ===
    const jerseyColor = Color(0xFF1A1A2E);

    // Torso - horizontal plank
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 35 * scale, bodyY - 8 * scale, 75 * scale, 22 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = jerseyColor,
    );

    // Chest visible at neckline
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX + 35 * scale, bodyY + 2 * scale),
          width: 12 * scale,
          height: 14 * scale),
      Paint()..color = skinColor,
    );

    // Muscle definition line
    canvas.drawLine(
      Offset(centerX + 5 * scale, bodyY - 5 * scale),
      Offset(centerX + 5 * scale, bodyY + 10 * scale),
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..strokeWidth = 1,
    );

    // === GYM SHORTS ===
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 50 * scale, bodyY - 6 * scale, 20 * scale, 18 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = const Color(0xFF2D3436),
    );

    // === ARMS (forearms on ground for plank) ===
    final elbowY = groundY - 6 * scale;

    // Left arm (front arm - closer to head)
    final leftShoulderX = centerX + 35 * scale;
    final leftElbowX = centerX + 50 * scale;
    final leftHandX = centerX + 65 * scale;

    // Upper arm going down
    canvas.drawLine(
      Offset(leftShoulderX, bodyY + 8 * scale),
      Offset(leftElbowX, elbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Forearm flat on ground
    canvas.drawLine(
      Offset(leftElbowX, elbowY),
      Offset(leftHandX, elbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 9 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Hand/fist
    canvas.drawCircle(
        Offset(leftHandX, elbowY), 5 * scale, Paint()..color = skinColor);

    // Right arm (back arm - partially visible)
    final rightShoulderX = centerX + 20 * scale;
    final rightElbowX = centerX + 32 * scale;

    // Upper arm going down
    canvas.drawLine(
      Offset(rightShoulderX, bodyY + 8 * scale),
      Offset(rightElbowX, elbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );
    // Forearm flat on ground
    canvas.drawLine(
      Offset(rightElbowX, elbowY),
      Offset(rightElbowX + 12 * scale, elbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 9 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === LEGS (straight line from hip to toes on ground) ===
    final hipX = centerX - 45 * scale;
    final toeY = groundY - 3 * scale;

    // Leg goes in a straight diagonal line from hip down to toes
    // Knees should be lower, not at body level
    final kneeX = centerX - 58 * scale;
    final kneeY = bodyY + 22 * scale; // Knee is lower than hip

    // Thigh (from hip going down toward knee)
    canvas.drawLine(
      Offset(hipX, bodyY + 8 * scale),
      Offset(kneeX, kneeY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 16 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Lower leg (from knee continuing down to ankle near ground)
    final ankleX = centerX - 70 * scale;
    final ankleY = toeY - 6 * scale;
    
    canvas.drawLine(
      Offset(kneeX, kneeY),
      Offset(ankleX, ankleY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === SHOE ON GROUND (toes touching floor) ===
    // Shoe base
    final shoeX = ankleX - 2 * scale;
    final shoeY = toeY;
    
    // Shoe body (athletic shoe, toes pointing down)
    final shoePath = Path();
    shoePath.moveTo(shoeX + 5 * scale, shoeY - 12 * scale); // ankle
    shoePath.lineTo(shoeX - 8 * scale, shoeY - 5 * scale); // toe top
    shoePath.lineTo(shoeX - 10 * scale, shoeY); // toe tip on ground
    shoePath.lineTo(shoeX + 8 * scale, shoeY); // heel on ground
    shoePath.lineTo(shoeX + 8 * scale, shoeY - 10 * scale); // back of heel
    shoePath.close();
    canvas.drawPath(shoePath, Paint()..color = Colors.red[700]!);
    
    // Shoe sole
    canvas.drawLine(
      Offset(shoeX - 10 * scale, shoeY),
      Offset(shoeX + 8 * scale, shoeY),
      Paint()
        ..color = Colors.grey[900]!
        ..strokeWidth = 3 * scale
        ..strokeCap = StrokeCap.round,
    );
    
    // Shoe details (laces area)
    canvas.drawLine(
      Offset(shoeX - 2 * scale, shoeY - 8 * scale),
      Offset(shoeX + 3 * scale, shoeY - 10 * scale),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2 * scale,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CrunchPainter extends ExercisePainterBase {
  CrunchPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 32 * scale, size.width, 68 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 32 * scale, size.width, 68 * scale),
        floorPaint);

    // Yoga mat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 68 * scale, centerY + 28 * scale, 136 * scale, 8 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.blue[900]!,
    );

    final groundY = centerY + 32 * scale;

    // Crunch motion - small angle to keep head above floor
    final crunchAngle = progress * 0.3;

    // Abs highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 8 * scale, centerY + 2 * scale),
        16 * scale,
        primaryColor);

    // === LOWER BODY (on mat) ===

    // === GYM SHORTS (hips on mat) ===
    drawGymShorts(canvas, Offset(centerX - 15 * scale, groundY - 10 * scale),
        28 * scale, 18 * scale, scale);

    // === BENT LEGS ===
    // Right leg (bent, knee up)
    drawMuscularLeg(
      canvas,
      Offset(centerX + 5 * scale, groundY - 8 * scale),
      Offset(centerX + 45 * scale, centerY - 5 * scale),
      Offset(centerX + 55 * scale, groundY - 2 * scale),
      9 * scale,
    );
    drawGymShoe(canvas, Offset(centerX + 55 * scale, groundY - 2 * scale),
        Offset(centerX + 65 * scale, groundY), 6 * scale);

    // Left leg (similar position)
    drawMuscularLeg(
      canvas,
      Offset(centerX - 5 * scale, groundY - 8 * scale),
      Offset(centerX + 35 * scale, centerY - 8 * scale),
      Offset(centerX + 48 * scale, groundY - 2 * scale),
      9 * scale,
    );

    // === UPPER BODY (crunching up) ===
    canvas.save();
    // Pivot point higher up at mid-back to prevent head going through floor
    canvas.translate(centerX - 10 * scale, groundY - 18 * scale);
    canvas.rotate(-crunchAngle);

    // Tank top (torso crunching)
    const jerseyColor = Color(0xFF1A1A2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-35 * scale, -10 * scale, 42 * scale, 20 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = jerseyColor,
    );

    // === NECK connecting torso to head ===
    const skinColor = Color(0xFFD4A574);
    final neckStartX = -35 * scale;
    final neckStartY = -4 * scale;
    final neckEndX = -42 * scale;
    final neckEndY = -10 * scale;
    
    // Draw neck
    canvas.drawLine(
      Offset(neckStartX, neckStartY),
      Offset(neckEndX, neckEndY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 10 * scale
        ..strokeCap = StrokeCap.round,
    );

    // === HEAD (positioned higher to stay above floor) ===
    final headX = neckEndX - 6 * scale;
    final headY = neckEndY - 6 * scale;
    
    // Head shape (oval)
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX, headY),
          width: 20 * scale,
          height: 22 * scale),
      Paint()..color = skinColor,
    );
    
    // Hair (short style)
    const hairColor = Color(0xFF2C1810);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(headX - 2 * scale, headY - 6 * scale),
          width: 20 * scale,
          height: 14 * scale),
      -math.pi * 0.8,
      math.pi * 1.6,
      true,
      Paint()..color = hairColor,
    );
    
    // Ear
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headX + 9 * scale, headY),
          width: 5 * scale,
          height: 7 * scale),
      Paint()..color = skinColor,
    );
    
    // Eye (looking forward/down during crunch)
    canvas.drawCircle(Offset(headX - 3 * scale, headY - 1 * scale), 2.5 * scale,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(headX - 3 * scale, headY), 1.2 * scale,
        Paint()..color = Colors.brown[800]!);

    // === ARMS wrapped around head (classic crunch position) ===
    // Arms go from shoulders, elbows out wide, hands behind head
    final shoulderX = -30 * scale;
    final shoulderY = -6 * scale;
    
    // === LEFT ARM (front arm, more visible) ===
    // Upper arm: shoulder to elbow (elbow pointing outward but higher)
    final leftElbowX = headX + 15 * scale;
    final leftElbowY = headY - 2 * scale;
    canvas.drawLine(
      Offset(shoulderX, shoulderY),
      Offset(leftElbowX, leftElbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 8 * scale
        ..strokeCap = StrokeCap.round,
    );
    
    // Forearm: elbow to hand behind head
    final leftHandX = headX + 3 * scale;
    final leftHandY = headY - 8 * scale;
    canvas.drawLine(
      Offset(leftElbowX, leftElbowY),
      Offset(leftHandX, leftHandY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 7 * scale
        ..strokeCap = StrokeCap.round,
    );
    
    // Hand cupping back of head
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(leftHandX, leftHandY),
          width: 8 * scale,
          height: 10 * scale),
      Paint()..color = skinColor,
    );
    
    // Fingers visible on back of head
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(leftHandX - 2 * scale + i * 2 * scale, leftHandY - 4 * scale),
        Offset(leftHandX - 2 * scale + i * 2 * scale, leftHandY + 2 * scale),
        Paint()
          ..color = skinColor
          ..strokeWidth = 2 * scale
          ..strokeCap = StrokeCap.round,
      );
    }
    
    // === RIGHT ARM (back arm, partially visible) ===
    // Upper arm: shoulder to elbow (elbow pointing out on other side, higher)
    final rightElbowX = headX - 10 * scale;
    final rightElbowY = headY - 4 * scale;
    canvas.drawLine(
      Offset(shoulderX + 3 * scale, shoulderY + 2 * scale),
      Offset(rightElbowX, rightElbowY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 7 * scale
        ..strokeCap = StrokeCap.round,
    );
    
    // Forearm: elbow to hand behind head (overlapping with left hand)
    final rightHandX = headX + 1 * scale;
    final rightHandY = headY - 10 * scale;
    canvas.drawLine(
      Offset(rightElbowX, rightElbowY),
      Offset(rightHandX, rightHandY),
      Paint()
        ..color = skinColor
        ..strokeWidth = 6 * scale
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LegRaisePainter extends ExercisePainterBase {
  LegRaisePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 25 * scale, size.width, 75 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 25 * scale, size.width, 75 * scale),
        floorPaint);

    // Yoga mat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 58 * scale, centerY + 20 * scale, 116 * scale, 8 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.teal[900]!,
    );

    final groundY = centerY + 22 * scale;

    // Lower abs highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 8 * scale, centerY - 2 * scale),
        16 * scale,
        primaryColor);

    // === LYING FIGURE ===
    final bodyY = groundY - 8 * scale;

    // Head (at left side)
    drawCompleteHead(
        canvas, Offset(centerX - 42 * scale, bodyY - 2 * scale), scale * 0.85,
        rotation: math.pi / 2);

    // === TANK TOP (lying flat) ===
    const jerseyColor = Color(0xFF1A1A2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 30 * scale, bodyY - 12 * scale, 48 * scale, 22 * scale),
        Radius.circular(4 * scale),
      ),
      Paint()..color = jerseyColor,
    );

    // === GYM SHORTS ===
    drawGymShorts(canvas, Offset(centerX + 18 * scale, bodyY), 24 * scale,
        16 * scale, scale);

    // === ARMS (at sides, hands under hips for support) ===
    final leftHand = Offset(centerX - 48 * scale, bodyY + 8 * scale);
    drawMuscularArm(
      canvas,
      Offset(centerX - 32 * scale, bodyY),
      Offset(centerX - 42 * scale, bodyY + 5 * scale),
      leftHand,
      6 * scale,
      0.15,
    );
    drawCompleteHand(canvas, leftHand, 5 * scale, 0.5, gripping: false);

    // === LEG RAISE MOTION ===
    final raiseAngle = progress * (math.pi * 0.45);
    final legLength = 48 * scale;

    final legEndX =
        centerX + 22 * scale + (math.cos(math.pi / 2 - raiseAngle) * legLength);
    final legEndY = bodyY - (math.sin(math.pi / 2 - raiseAngle) * legLength);

    // === MUSCULAR LEGS (raising together) ===
    drawMuscularLeg(
      canvas,
      Offset(centerX + 22 * scale, bodyY + 2 * scale),
      Offset((centerX + 22 * scale + legEndX) / 2, (bodyY + legEndY) / 2),
      Offset(legEndX, legEndY),
      10 * scale,
    );

    // Gym shoes (feet together)
    drawGymShoe(canvas, Offset(legEndX, legEndY),
        Offset(legEndX + 10 * scale, legEndY - 3 * scale), 6 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RussianTwistPainter extends ExercisePainterBase {
  RussianTwistPainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 45 * scale, size.width, 55 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 45 * scale, size.width, 55 * scale),
        floorPaint);

    // Yoga mat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 50 * scale, centerY + 42 * scale, 100 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      Paint()..color = Colors.orange[900]!,
    );

    // Obliques highlights (target muscles)
    drawMuscleHighlight(
        canvas,
        Offset(centerX - 18 * scale, centerY - 5 * scale),
        13 * scale,
        primaryColor);
    drawMuscleHighlight(
        canvas,
        Offset(centerX + 18 * scale, centerY - 5 * scale),
        13 * scale,
        primaryColor);

    // === SEATED V POSITION FIGURE ===

    // Head
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 38 * scale), scale * 0.95,
        rotation: 0);

    // === TANK TOP (V-sit position, leaned back) ===
    const jerseyColor = Color(0xFF1A1A2E);

    // Torso leaned back
    final torsoPath = Path();
    torsoPath.moveTo(centerX - 18 * scale, centerY - 25 * scale);
    torsoPath.lineTo(centerX - 15 * scale, centerY + 12 * scale);
    torsoPath.lineTo(centerX + 15 * scale, centerY + 12 * scale);
    torsoPath.lineTo(centerX + 18 * scale, centerY - 25 * scale);
    torsoPath.close();
    canvas.drawPath(torsoPath, Paint()..color = jerseyColor);

    // === GYM SHORTS ===
    drawGymShorts(canvas, Offset(centerX, centerY + 15 * scale), 32 * scale,
        18 * scale, scale);

    // === TWIST MOTION ===
    final twistOffset = math.sin(progress * math.pi * 2) * 28 * scale;

    // === ARMS WITH MEDICINE BALL ===
    final ballX = centerX + twistOffset;
    final ballY = centerY - 8 * scale;

    // Left arm
    drawMuscularArm(
      canvas,
      Offset(centerX - 15 * scale, centerY - 15 * scale),
      Offset(centerX - 8 * scale + twistOffset * 0.3, centerY - 12 * scale),
      Offset(ballX - 10 * scale, ballY),
      7 * scale,
      0.3,
    );
    drawCompleteHand(canvas, Offset(ballX - 10 * scale, ballY), 5 * scale, 0.3,
        gripping: true);

    // Right arm
    drawMuscularArm(
      canvas,
      Offset(centerX + 15 * scale, centerY - 15 * scale),
      Offset(centerX + 8 * scale + twistOffset * 0.3, centerY - 12 * scale),
      Offset(ballX + 10 * scale, ballY),
      7 * scale,
      0.3,
    );
    drawCompleteHand(canvas, Offset(ballX + 10 * scale, ballY), 5 * scale, -0.3,
        gripping: true);

    // Medicine ball
    final ballPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [Colors.red[600]!, Colors.red[900]!],
      ).createShader(
          Rect.fromCircle(center: Offset(ballX, ballY), radius: 12 * scale));
    canvas.drawCircle(Offset(ballX, ballY), 12 * scale, ballPaint);
    // Ball grip lines
    canvas.drawArc(
      Rect.fromCircle(center: Offset(ballX, ballY), radius: 10 * scale),
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.red[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );

    // === LEGS (raised, knees bent) ===
    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, centerY + 22 * scale),
      Offset(centerX - 22 * scale, centerY + 35 * scale),
      Offset(centerX - 32 * scale, centerY + 22 * scale),
      8 * scale,
    );
    drawGymShoe(canvas, Offset(centerX - 32 * scale, centerY + 22 * scale),
        Offset(centerX - 40 * scale, centerY + 20 * scale), 5 * scale);

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, centerY + 22 * scale),
      Offset(centerX + 22 * scale, centerY + 35 * scale),
      Offset(centerX + 32 * scale, centerY + 22 * scale),
      8 * scale,
    );
    drawGymShoe(canvas, Offset(centerX + 32 * scale, centerY + 22 * scale),
        Offset(centerX + 40 * scale, centerY + 20 * scale), 5 * scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== DEFAULT FALLBACK ====================

class DefaultExercisePainter extends ExercisePainterBase {
  final String exerciseName;

  DefaultExercisePainter({
    required super.progress,
    required super.primaryColor,
    required super.secondaryColor,
    required this.exerciseName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 200;

    // === GYM FLOOR ===
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[800]!, Colors.grey[900]!],
      ).createShader(
          Rect.fromLTWH(0, centerY + 62 * scale, size.width, 38 * scale));
    canvas.drawRect(
        Rect.fromLTWH(0, centerY + 62 * scale, size.width, 38 * scale),
        floorPaint);

    // Generic bob animation
    final bobOffset = math.sin(progress * math.pi * 2) * 3 * scale;

    // === STANDING MUSCULAR FIGURE ===

    // Head
    drawCompleteHead(
        canvas, Offset(centerX, centerY - 48 * scale + bobOffset), scale,
        rotation: 0);

    // Generic muscle highlight
    drawMuscleHighlight(canvas, Offset(centerX, centerY - 12 * scale),
        22 * scale, primaryColor);

    // === TANK TOP ===
    drawTankTop(canvas, Offset(centerX, centerY - 8 * scale + bobOffset),
        48 * scale, 55 * scale, scale);

    // === GYM SHORTS ===
    final hipY = centerY + 22 * scale;
    drawGymShorts(canvas, Offset(centerX, hipY + bobOffset * 0.5), 38 * scale,
        24 * scale, scale);

    // === LEGS ===
    final legLen = 52 * scale;

    // Left leg
    drawMuscularLeg(
      canvas,
      Offset(centerX - 10 * scale, hipY + 12 * scale),
      Offset(centerX - 12 * scale, hipY + legLen * 0.5),
      Offset(centerX - 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Right leg
    drawMuscularLeg(
      canvas,
      Offset(centerX + 10 * scale, hipY + 12 * scale),
      Offset(centerX + 12 * scale, hipY + legLen * 0.5),
      Offset(centerX + 10 * scale, hipY + legLen),
      10 * scale,
    );

    // Gym shoes
    drawGymShoe(canvas, Offset(centerX - 10 * scale, hipY + legLen),
        Offset(centerX - 20 * scale, hipY + legLen + 5 * scale), 7 * scale);
    drawGymShoe(canvas, Offset(centerX + 10 * scale, hipY + legLen),
        Offset(centerX + 20 * scale, hipY + legLen + 5 * scale), 7 * scale);

    // === ARMS WITH DUMBBELLS ===
    final leftShoulder =
        Offset(centerX - 20 * scale, centerY - 28 * scale + bobOffset);
    final leftElbow =
        Offset(centerX - 28 * scale, centerY - 5 * scale + bobOffset);
    final leftHand =
        Offset(centerX - 32 * scale, centerY + 5 * scale + bobOffset);

    drawMuscularArm(canvas, leftShoulder, leftElbow, leftHand, 8 * scale, 0.25);
    drawCompleteHand(canvas, leftHand, 6 * scale, 0, gripping: true);
    drawDumbbell(canvas, Offset(leftHand.dx, leftHand.dy + 8 * scale),
        22 * scale, 7 * scale, 0);

    final rightShoulder =
        Offset(centerX + 20 * scale, centerY - 28 * scale + bobOffset);
    final rightElbow =
        Offset(centerX + 28 * scale, centerY - 5 * scale + bobOffset);
    final rightHand =
        Offset(centerX + 32 * scale, centerY + 5 * scale + bobOffset);

    drawMuscularArm(
        canvas, rightShoulder, rightElbow, rightHand, 8 * scale, 0.25);
    drawCompleteHand(canvas, rightHand, 6 * scale, 0, gripping: true);
    drawDumbbell(canvas, Offset(rightHand.dx, rightHand.dy + 8 * scale),
        22 * scale, 7 * scale, 0);

    // Exercise icon in corner
    final iconPaint = Paint()
      ..color = secondaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width - 22 * scale, 22 * scale), 16 * scale, iconPaint);

    // Dumbbell icon
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(size.width - 22 * scale, 22 * scale),
          width: 18 * scale,
          height: 5 * scale),
      Paint()..color = secondaryColor,
    );
    canvas.drawCircle(Offset(size.width - 32 * scale, 22 * scale), 5 * scale,
        Paint()..color = secondaryColor);
    canvas.drawCircle(Offset(size.width - 12 * scale, 22 * scale), 5 * scale,
        Paint()..color = secondaryColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
