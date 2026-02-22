import 'package:flutter/material.dart';
import 'dart:math';

/// Animated fitness woman widget lifting dumbbells
///
/// Renders a beautiful, centered, feminine figure performing dumbbell curls.
/// Uses CustomPainter with elegant proportions, long flowing hair,
/// hourglass body, sports bra, leggings, and animated arm movement.
/// Designed as a background decoration.
class BodybuilderAnimation extends StatefulWidget {
  final double opacity;

  const BodybuilderAnimation({super.key, this.opacity = 0.18});

  @override
  State<BodybuilderAnimation> createState() => _BodybuilderAnimationState();
}

class _BodybuilderAnimationState extends State<BodybuilderAnimation>
    with TickerProviderStateMixin {
  late AnimationController _liftController;
  late AnimationController _breatheController;
  late Animation<double> _liftAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    _liftController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _liftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _liftController, curve: Curves.easeInOut),
    );
    _liftController.repeat(reverse: true);

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3800),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    _breatheController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _liftController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_liftAnimation, _breatheAnimation]),
      builder: (context, child) {
        return CustomPaint(
          painter: _FitnessWomanPainter(
            liftProgress: _liftAnimation.value,
            breatheProgress: _breatheAnimation.value,
            baseColor: const Color(0xFFFF6B35),
            opacity: widget.opacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FitnessWomanPainter extends CustomPainter {
  final double liftProgress;
  final double breatheProgress;
  final Color baseColor;
  final double opacity;

  _FitnessWomanPainter({
    required this.liftProgress,
    required this.breatheProgress,
    required this.baseColor,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.47;
    final s = min(size.width, size.height) * 0.003;

    // ── Color palette ──
    final body = baseColor.withOpacity(opacity);
    final bodyDark = baseColor.withOpacity(opacity * 0.45);
    final bodyLight = baseColor.withOpacity(min(opacity * 1.5, 1.0));
    final highlight = baseColor.withOpacity(min(opacity * 1.9, 1.0));
    final shadow = baseColor.withOpacity(opacity * 0.25);
    final hairMain = const Color(0xFF2C1810).withOpacity(min(opacity * 1.8, 1.0));
    final hairHighlight = const Color(0xFF5C3A28).withOpacity(min(opacity * 1.4, 1.0));
    final hairDark = const Color(0xFF1A0E08).withOpacity(min(opacity * 1.6, 1.0));
    final lipCol = const Color(0xFFE8305A).withOpacity(min(opacity * 1.8, 1.0));
    final lipDark = const Color(0xFFAA1838).withOpacity(min(opacity * 1.5, 1.0));
    final eyeCol = const Color(0xFF2E7D32).withOpacity(min(opacity * 2.2, 1.0));
    final glowCol = baseColor.withOpacity(opacity * 0.15);
    final clothDark = const Color(0xFF1A1A2E).withOpacity(min(opacity * 1.4, 1.0));
    final clothLight = const Color(0xFF2D2D44).withOpacity(min(opacity * 1.2, 1.0));
    final clothAccent = const Color(0xFFE91E63).withOpacity(min(opacity * 1.5, 1.0));

    final breathe = breatheProgress * 2 * s;
    final curl = liftProgress;

    final fill = Paint()..color = body..style = PaintingStyle.fill;
    final outline = Paint()..color = bodyLight..style = PaintingStyle.stroke..strokeWidth = 1.8 * s;
    final shadowFill = Paint()..color = shadow..style = PaintingStyle.fill;

    // ── SOFT GLOW ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 260 * s, height: 300 * s),
      Paint()..color = glowCol..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );

    // ── KEY POSITIONS ──
    final headR = 21 * s;
    final headY = cy - 115 * s;
    final neckBot = cy - 80 * s;
    final shoulderW = (40 + breathe) * s;
    final shoulderY = cy - 66 * s;
    final bustY = cy - 46 * s;
    final waistW = 20 * s;
    final waistY = cy + 10 * s;
    final hipW = 36 * s;
    final hipY = cy + 42 * s;

    // ════════════════════════════════
    // LAYER 1: HAIR BEHIND BODY
    // ════════════════════════════════

    // Main hair mass - flowing & voluminous
    final hairBehindPath = Path()
      ..moveTo(cx - headR - 10 * s, headY - 2 * s)
      ..cubicTo(cx - headR - 16 * s, headY + 30 * s,
          cx - headR - 12 * s, cy - 20 * s,
          cx - headR - 6 * s, cy + 20 * s + breathe * 4)
      ..cubicTo(cx - headR, cy + 40 * s + breathe * 5,
          cx - 12 * s, cy + 35 * s + breathe * 5,
          cx - 6 * s, cy + 30 * s + breathe * 4)
      ..lineTo(cx + 6 * s, cy + 30 * s + breathe * 4)
      ..cubicTo(cx + 12 * s, cy + 35 * s + breathe * 5,
          cx + headR, cy + 40 * s + breathe * 5,
          cx + headR + 6 * s, cy + 20 * s + breathe * 4)
      ..cubicTo(cx + headR + 12 * s, cy - 20 * s,
          cx + headR + 16 * s, headY + 30 * s,
          cx + headR + 10 * s, headY - 2 * s)
      ..quadraticBezierTo(cx, headY - headR - 6 * s,
          cx - headR - 10 * s, headY - 2 * s)
      ..close();
    canvas.drawPath(hairBehindPath, Paint()..color = hairMain..style = PaintingStyle.fill);

    // Hair depth/shadow layer
    final hairShadow = Path()
      ..moveTo(cx - headR - 6 * s, headY + 15 * s)
      ..cubicTo(cx - headR - 10 * s, headY + 50 * s,
          cx - headR - 6 * s, cy, cx - headR + 2 * s, cy + 25 * s + breathe * 4)
      ..lineTo(cx - 8 * s, cy + 22 * s + breathe * 3)
      ..cubicTo(cx - headR + 5 * s, cy - 10 * s,
          cx - headR - 4 * s, headY + 40 * s, cx - headR - 6 * s, headY + 15 * s)
      ..close();
    canvas.drawPath(hairShadow, Paint()..color = hairDark..style = PaintingStyle.fill);

    // Hair strand details (wavy lines)
    final strandP = Paint()..color = hairHighlight..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * s..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final xOff = -20 * s + i * 5.5 * s;
      final waveFactor = sin(i * 0.9 + breatheProgress * pi) * 3 * s;
      final strandPath = Path()
        ..moveTo(cx + xOff, headY + headR)
        ..cubicTo(
            cx + xOff + waveFactor, headY + headR + 30 * s,
            cx + xOff - waveFactor, cy - 10 * s,
            cx + xOff + waveFactor * 0.5, cy + 18 * s + breathe * 3);
      canvas.drawPath(strandPath, strandP);
    }

    // ── PONYTAIL (dynamic sway) ──
    final sway = sin(breatheProgress * pi * 2) * 10 * s;
    final ptPath = Path()
      ..moveTo(cx + headR * 0.4, headY - headR + 2 * s)
      ..cubicTo(
          cx + headR + 22 * s + sway, headY - headR - 18 * s,
          cx + headR + 28 * s + sway * 1.5, headY + 10 * s,
          cx + headR + 22 * s + sway * 1.8, headY + 50 * s)
      ..cubicTo(
          cx + headR + 18 * s + sway * 2, headY + 80 * s,
          cx + headR + 10 * s + sway * 1.5, headY + 100 * s + breathe * 5,
          cx + headR + 6 * s + sway, headY + 110 * s + breathe * 6)
      ..quadraticBezierTo(
          cx + headR + 4 * s, headY + 70 * s,
          cx + headR + 2 * s, headY + 20 * s)
      ..quadraticBezierTo(
          cx + headR, headY - headR + 5 * s,
          cx + headR * 0.4, headY - headR + 2 * s)
      ..close();
    canvas.drawPath(ptPath, Paint()..color = hairMain..style = PaintingStyle.fill);
    // Ponytail highlight
    final ptHighlight = Path()
      ..moveTo(cx + headR + 10 * s + sway * 0.5, headY - headR - 5 * s)
      ..cubicTo(
          cx + headR + 18 * s + sway, headY + 15 * s,
          cx + headR + 14 * s + sway * 1.2, headY + 55 * s,
          cx + headR + 10 * s + sway, headY + 85 * s + breathe * 4);
    canvas.drawPath(ptHighlight, Paint()..color = hairHighlight..style = PaintingStyle.stroke..strokeWidth = 2 * s);

    // Scrunchie / hair tie
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + headR + 5 * s + sway * 0.3, headY - headR - 1 * s),
        width: 10 * s, height: 7 * s),
      Paint()..color = clothAccent..style = PaintingStyle.fill);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + headR + 5 * s + sway * 0.3, headY - headR - 1 * s),
        width: 10 * s, height: 7 * s),
      Paint()..color = clothAccent.withOpacity(min(opacity * 2.5, 1.0))..style = PaintingStyle.stroke..strokeWidth = 1.2 * s);

    // ════════════════════════════════
    // LAYER 2: BODY SHADOW
    // ════════════════════════════════
    final bodyShadow = Path()
      ..moveTo(cx - shoulderW + 2 * s, shoulderY + 3 * s)
      ..cubicTo(cx - shoulderW, shoulderY + 18 * s,
          cx - shoulderW - 2 * s, bustY, cx - shoulderW + 2 * s, bustY + 8 * s)
      ..cubicTo(cx - shoulderW + 8 * s, cy - 15 * s,
          cx - waistW - 4 * s, waistY - 8 * s, cx - waistW - 1 * s, waistY + 2 * s)
      ..cubicTo(cx - waistW - 4 * s, waistY + 15 * s,
          cx - hipW - 2 * s, hipY - 8 * s, cx - hipW - 1 * s, hipY + 2 * s)
      ..lineTo(cx - hipW + 8 * s, hipY + 2 * s)
      ..cubicTo(cx - hipW + 4 * s, hipY - 6 * s,
          cx - waistW + 2 * s, waistY + 10 * s, cx - waistW + 5 * s, waistY)
      ..cubicTo(cx - waistW + 2 * s, waistY - 10 * s,
          cx - shoulderW + 12 * s, cy - 18 * s, cx - shoulderW + 6 * s, shoulderY + 3 * s)
      ..close();
    canvas.drawPath(bodyShadow, shadowFill);

    // ════════════════════════════════
    // LAYER 3: HEAD & FACE
    // ════════════════════════════════

    // Head - oval shape
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headY), width: headR * 2, height: headR * 2.2),
      fill);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headY), width: headR * 2, height: headR * 2.2),
      outline);

    // Face shadow (left side)
    final faceShadow = Path()
      ..moveTo(cx + 4 * s, headY - headR * 1.05)
      ..quadraticBezierTo(cx + headR + 2 * s, headY, cx + 4 * s, headY + headR * 1.05)
      ..quadraticBezierTo(cx + headR - 4 * s, headY, cx + 4 * s, headY - headR * 1.05)
      ..close();
    canvas.drawPath(faceShadow, Paint()..color = shadow..style = PaintingStyle.fill);

    // Front bangs
    final bangs = Path()
      ..moveTo(cx - headR - 4 * s, headY - 3 * s)
      ..cubicTo(cx - headR * 0.7, headY - headR - 15 * s,
          cx + headR * 0.3, headY - headR - 18 * s,
          cx + headR + 4 * s, headY - 3 * s)
      ..quadraticBezierTo(cx + headR + 1 * s, headY - headR + 2 * s,
          cx + 3 * s, headY - headR + 4 * s)
      ..quadraticBezierTo(cx - headR - 1 * s, headY - headR + 2 * s,
          cx - headR - 4 * s, headY - 3 * s)
      ..close();
    canvas.drawPath(bangs, Paint()..color = hairMain..style = PaintingStyle.fill);
    canvas.drawPath(bangs, Paint()..color = hairDark..style = PaintingStyle.stroke..strokeWidth = 1.2 * s);

    // Bang highlight streak
    final bangHL = Path()
      ..moveTo(cx - 6 * s, headY - headR + 5 * s)
      ..quadraticBezierTo(cx - 10 * s, headY - headR - 8 * s, cx - headR - 1 * s, headY - 1 * s);
    canvas.drawPath(bangHL, Paint()..color = hairHighlight..style = PaintingStyle.stroke..strokeWidth = 1.8 * s);
    final bangHL2 = Path()
      ..moveTo(cx - 2 * s, headY - headR + 5 * s)
      ..quadraticBezierTo(cx - 5 * s, headY - headR - 6 * s, cx - headR + 3 * s, headY + 1 * s);
    canvas.drawPath(bangHL2, Paint()..color = hairHighlight..style = PaintingStyle.stroke..strokeWidth = 1.0 * s);

    // ── EYES ──
    final eyeY = headY - 1 * s;
    final eyeSpacing = 8.5 * s;

    for (int side = -1; side <= 1; side += 2) {
      final ex = cx + side * eyeSpacing;

      // Eye shadow above lid
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, eyeY - 2 * s), width: 12 * s, height: 5 * s),
        Paint()..color = shadow..style = PaintingStyle.fill);

      // Eye white
      final eyePath = Path()
        ..moveTo(ex - 6 * s, eyeY)
        ..quadraticBezierTo(ex, eyeY - 5.5 * s, ex + 6 * s, eyeY)
        ..quadraticBezierTo(ex, eyeY + 2.5 * s, ex - 6 * s, eyeY);
      canvas.drawPath(eyePath, Paint()..color = body.withOpacity(min(opacity * 2.5, 1.0))..style = PaintingStyle.fill);
      canvas.drawPath(eyePath, Paint()..color = bodyDark..style = PaintingStyle.stroke..strokeWidth = 1.2 * s);

      // Iris
      canvas.drawCircle(Offset(ex, eyeY - 0.5 * s), 3.2 * s,
        Paint()..color = eyeCol..style = PaintingStyle.fill);
      // Pupil
      canvas.drawCircle(Offset(ex, eyeY - 0.5 * s), 1.6 * s,
        Paint()..color = hairDark..style = PaintingStyle.fill);
      // Eye sparkle
      canvas.drawCircle(Offset(ex + 1 * s, eyeY - 2 * s), 1.0 * s,
        Paint()..color = highlight..style = PaintingStyle.fill);

      // Upper eyeliner (thicker)
      final linerPath = Path()
        ..moveTo(ex - 6.5 * s, eyeY + 0.5 * s)
        ..quadraticBezierTo(ex, eyeY - 6 * s, ex + 6.5 * s, eyeY + 0.5 * s);
      canvas.drawPath(linerPath, Paint()..color = hairDark..style = PaintingStyle.stroke..strokeWidth = 1.8 * s);

      // Eyelashes (more, fanned out)
      final lashP = Paint()..color = hairDark..strokeWidth = 1.0 * s..strokeCap = StrokeCap.round;
      for (int j = 0; j < 5; j++) {
        final t = j / 4.0;
        final lx = ex - 5 * s + t * 10 * s;
        final baseY2 = eyeY - 4 * s + (t - 0.5).abs() * 3 * s;
        final tipAngle = -pi / 2 + (t - 0.5) * 0.8;
        canvas.drawLine(
          Offset(lx, baseY2),
          Offset(lx + cos(tipAngle) * 3.5 * s, baseY2 + sin(tipAngle) * 3.5 * s),
          lashP);
      }

      // Lower lash line (subtle)
      canvas.drawArc(
        Rect.fromCenter(center: Offset(ex, eyeY + 1 * s), width: 10 * s, height: 4 * s),
        0.2, pi - 0.4, false,
        Paint()..color = bodyDark.withOpacity(opacity * 0.3)..style = PaintingStyle.stroke..strokeWidth = 0.6 * s);
    }

    // ── EYEBROWS (arched, feminine) ──
    final browP = Paint()..color = hairMain..style = PaintingStyle.stroke..strokeWidth = 1.8 * s..strokeCap = StrokeCap.round;
    final lBrow = Path()
      ..moveTo(cx - 14 * s, headY - 5 * s)
      ..quadraticBezierTo(cx - 9 * s, headY - 11 * s, cx - 3 * s, headY - 7 * s);
    final rBrow = Path()
      ..moveTo(cx + 3 * s, headY - 7 * s)
      ..quadraticBezierTo(cx + 9 * s, headY - 11 * s, cx + 14 * s, headY - 5 * s);
    canvas.drawPath(lBrow, browP);
    canvas.drawPath(rBrow, browP);

    // ── NOSE (delicate) ──
    final noseP = Paint()..color = bodyDark..style = PaintingStyle.stroke..strokeWidth = 0.9 * s..strokeCap = StrokeCap.round;
    final nosePath = Path()
      ..moveTo(cx - 1 * s, headY + 2 * s)
      ..cubicTo(cx - 3 * s, headY + 6 * s, cx - 3.5 * s, headY + 8 * s, cx - 1 * s, headY + 8.5 * s)
      ..quadraticBezierTo(cx, headY + 9 * s, cx + 1 * s, headY + 8.5 * s);
    canvas.drawPath(nosePath, noseP);
    // Nose highlight
    canvas.drawLine(
      Offset(cx + 0.5 * s, headY + 3 * s), Offset(cx + 0.5 * s, headY + 7 * s),
      Paint()..color = highlight..strokeWidth = 0.7 * s..strokeCap = StrokeCap.round);

    // ── LIPS (full, glossy) ──
    // Upper lip (cupid's bow)
    final upperLip = Path()
      ..moveTo(cx - 8 * s, headY + 13 * s)
      ..cubicTo(cx - 5 * s, headY + 11 * s, cx - 2 * s, headY + 11.5 * s, cx, headY + 12.5 * s)
      ..cubicTo(cx + 2 * s, headY + 11.5 * s, cx + 5 * s, headY + 11 * s, cx + 8 * s, headY + 13 * s)
      ..quadraticBezierTo(cx, headY + 14.5 * s, cx - 8 * s, headY + 13 * s)
      ..close();
    canvas.drawPath(upperLip, Paint()..color = lipCol..style = PaintingStyle.fill);
    // Lower lip
    final lowerLip = Path()
      ..moveTo(cx - 7 * s, headY + 13 * s)
      ..cubicTo(cx - 4 * s, headY + 18.5 * s, cx + 4 * s, headY + 18.5 * s, cx + 7 * s, headY + 13 * s)
      ..quadraticBezierTo(cx, headY + 14 * s, cx - 7 * s, headY + 13 * s)
      ..close();
    canvas.drawPath(lowerLip, Paint()..color = lipDark..style = PaintingStyle.fill);
    // Lip line
    canvas.drawLine(Offset(cx - 8 * s, headY + 13 * s), Offset(cx + 8 * s, headY + 13 * s),
      Paint()..color = lipDark..strokeWidth = 0.8 * s);
    // Lip gloss highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2 * s, headY + 12.5 * s), width: 4 * s, height: 2 * s),
      Paint()..color = highlight.withOpacity(min(opacity * 2.5, 1.0))..style = PaintingStyle.fill);

    // Soft smile line
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, headY + 15 * s), width: 10 * s, height: 5 * s),
      0.3, pi - 0.6, false,
      Paint()..color = bodyDark.withOpacity(opacity * 0.2)..style = PaintingStyle.stroke..strokeWidth = 0.6 * s);

    // ════════════════════════════════
    // LAYER 4: NECK & BODY
    // ════════════════════════════════

    // Slender neck
    final neckTop = headY + headR + 3 * s;
    final neckW = 8.5 * s;
    final neckPath = Path()
      ..moveTo(cx - neckW, neckTop)
      ..cubicTo(cx - neckW - 1 * s, neckTop + 10 * s,
          cx - neckW - 2.5 * s, neckBot - 5 * s, cx - neckW - 2.5 * s, neckBot)
      ..lineTo(cx + neckW + 2.5 * s, neckBot)
      ..cubicTo(cx + neckW + 2.5 * s, neckBot - 5 * s,
          cx + neckW + 1 * s, neckTop + 10 * s, cx + neckW, neckTop)
      ..close();
    canvas.drawPath(neckPath, fill);
    canvas.drawPath(neckPath, outline);

    // Neck tendon lines
    canvas.drawLine(Offset(cx - 4 * s, neckTop + 5 * s), Offset(cx - 6 * s, neckBot),
      Paint()..color = shadow..strokeWidth = 0.7 * s..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + 4 * s, neckTop + 5 * s), Offset(cx + 6 * s, neckBot),
      Paint()..color = shadow..strokeWidth = 0.7 * s..strokeCap = StrokeCap.round);

    // Necklace chain
    final chainP = Paint()..color = highlight..style = PaintingStyle.stroke..strokeWidth = 1.2 * s;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, neckBot + 3 * s), width: 24 * s, height: 14 * s),
      0.12, pi - 0.24, false, chainP);
    // Pendant (heart shape)
    final pendY = neckBot + 10 * s;
    final heartP = Paint()..color = clothAccent..style = PaintingStyle.fill;
    final heartPath = Path()
      ..moveTo(cx, pendY + 4 * s)
      ..cubicTo(cx - 5 * s, pendY + 1 * s, cx - 5 * s, pendY - 3 * s, cx, pendY - 1 * s)
      ..cubicTo(cx + 5 * s, pendY - 3 * s, cx + 5 * s, pendY + 1 * s, cx, pendY + 4 * s)
      ..close();
    canvas.drawPath(heartPath, heartP);

    // ── COLLARBONES ──
    final cbP = Paint()..color = bodyDark.withOpacity(opacity * 0.4)..strokeWidth = 1.0 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 5 * s, neckBot + 2 * s), Offset(cx - shoulderW + 5 * s, shoulderY + 6 * s), cbP);
    canvas.drawLine(Offset(cx + 5 * s, neckBot + 2 * s), Offset(cx + shoulderW - 5 * s, shoulderY + 6 * s), cbP);

    // ── SHOULDERS (soft, round) ──
    for (int side = -1; side <= 1; side += 2) {
      final dx = cx + side * shoulderW;
      canvas.drawCircle(Offset(dx, shoulderY + 4 * s), 11 * s, fill);
      canvas.drawCircle(Offset(dx, shoulderY + 4 * s), 11 * s, outline);
    }

    // ── HOURGLASS TORSO ──
    final bustW2 = shoulderW + 4 * s;
    final torso = Path()
      ..moveTo(cx - shoulderW, shoulderY)
      ..cubicTo(cx - shoulderW - 3 * s, shoulderY + 14 * s,
          cx - bustW2, bustY - 8 * s, cx - bustW2 + 2 * s, bustY + 6 * s)
      ..cubicTo(cx - bustW2 + 8 * s, cy - 18 * s,
          cx - waistW - 3 * s, waistY - 10 * s, cx - waistW, waistY)
      ..cubicTo(cx - waistW - 4 * s, waistY + 14 * s,
          cx - hipW - 1 * s, hipY - 8 * s, cx - hipW, hipY)
      ..lineTo(cx + hipW, hipY)
      ..cubicTo(cx + hipW + 1 * s, hipY - 8 * s,
          cx + waistW + 4 * s, waistY + 14 * s, cx + waistW, waistY)
      ..cubicTo(cx + waistW + 3 * s, waistY - 10 * s,
          cx + bustW2 - 8 * s, cy - 18 * s, cx + bustW2 - 2 * s, bustY + 6 * s)
      ..cubicTo(cx + bustW2, bustY - 8 * s,
          cx + shoulderW + 3 * s, shoulderY + 14 * s, cx + shoulderW, shoulderY)
      ..close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, outline);

    // ── SPORTS BRA (fitted) ──
    final braPath = Path()
      ..moveTo(cx - shoulderW + 6 * s, shoulderY + 4 * s)
      ..lineTo(cx - bustW2 + 5 * s, bustY + 8 * s)
      ..cubicTo(cx - bustW2 + 14 * s, bustY + 20 * s + breathe,
          cx - 4 * s, bustY + 16 * s, cx, bustY + 15 * s)
      ..cubicTo(cx + 4 * s, bustY + 16 * s,
          cx + bustW2 - 14 * s, bustY + 20 * s + breathe, cx + bustW2 - 5 * s, bustY + 8 * s)
      ..lineTo(cx + shoulderW - 6 * s, shoulderY + 4 * s)
      ..lineTo(cx + shoulderW - 4 * s, shoulderY + 1 * s)
      ..lineTo(cx - shoulderW + 4 * s, shoulderY + 1 * s)
      ..close();
    canvas.drawPath(braPath, Paint()..color = clothDark..style = PaintingStyle.fill);
    canvas.drawPath(braPath, Paint()..color = clothLight..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);

    // Bra strap details (thin lines over shoulders)
    final strapP = Paint()..color = clothLight..strokeWidth = 2 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - shoulderW + 12 * s, shoulderY + 1 * s), Offset(cx - neckW - 1 * s, neckBot + 2 * s), strapP);
    canvas.drawLine(Offset(cx + shoulderW - 12 * s, shoulderY + 1 * s), Offset(cx + neckW + 1 * s, neckBot + 2 * s), strapP);

    // Center seam
    canvas.drawLine(Offset(cx, shoulderY + 3 * s), Offset(cx, bustY + 15 * s),
      Paint()..color = clothLight..strokeWidth = 1.0 * s);
    // Accent line at bottom of bra
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, bustY + 15 * s), width: bustW2 * 1.6, height: 6 * s),
      0.15, pi - 0.3, false,
      Paint()..color = clothAccent..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);

    // Bust shading curves
    final bustShade = Paint()..color = bodyDark.withOpacity(opacity * 0.35)..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * s..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 15 * s, bustY + 8 * s), width: 22 * s, height: 14 * s + breathe),
      0.3, pi - 0.6, false, bustShade);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 15 * s, bustY + 8 * s), width: 22 * s, height: 14 * s + breathe),
      0.3, pi - 0.6, false, bustShade);

    // ── TONED MIDRIFF ──
    final mPaint = Paint()..color = bodyDark.withOpacity(opacity * 0.3)..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * s..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, bustY + 20 * s), Offset(cx, waistY - 2 * s), mPaint);
    for (int i = 0; i < 2; i++) {
      final y = bustY + 28 * s + i * 12 * s;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, y), width: 16 * s, height: 5 * s),
        0.2, pi - 0.4, false, mPaint);
    }
    // Belly button
    canvas.drawCircle(Offset(cx, waistY - 3 * s), 1.3 * s,
      Paint()..color = bodyDark..style = PaintingStyle.fill);

    // ── LEGGINGS WAISTBAND ──
    final wbPath = Path()
      ..moveTo(cx - waistW - 3 * s, waistY)
      ..quadraticBezierTo(cx, waistY + 4 * s, cx + waistW + 3 * s, waistY)
      ..lineTo(cx + waistW + 3 * s, waistY + 5 * s)
      ..quadraticBezierTo(cx, waistY + 9 * s, cx - waistW - 3 * s, waistY + 5 * s)
      ..close();
    canvas.drawPath(wbPath, Paint()..color = clothDark..style = PaintingStyle.fill);
    canvas.drawPath(wbPath, Paint()..color = clothLight..style = PaintingStyle.stroke..strokeWidth = 1.2 * s);

    // ════════════════════════════════
    // LAYER 5: ARMS (animated curl)
    // ════════════════════════════════
    final uLen = 42 * s;
    final fLen = 36 * s;
    final armW = 7 * s + curl * 1.5 * s;
    final foreW = 5.5 * s + curl * 1 * s;
    final uAngle = pi / 2 + 0.22 - curl * 0.35;
    final fAngle = pi * 0.1 + curl * pi * 0.7;

    for (int side = -1; side <= 1; side += 2) {
      final sh = Offset(cx + side * shoulderW, shoulderY + 8 * s);
      final elb = Offset(
        sh.dx + side * (-uLen * cos(uAngle)),
        sh.dy + uLen * sin(uAngle));
      final hand = Offset(
        elb.dx + side * (-fLen * cos(fAngle) * 0.3),
        elb.dy - fLen * sin(fAngle));

      // Upper arm
      canvas.drawLine(sh, elb, Paint()..color = bodyLight..style = PaintingStyle.stroke..strokeWidth = armW + 2.5 * s..strokeCap = StrokeCap.round);
      canvas.drawLine(sh, elb, Paint()..color = body..style = PaintingStyle.stroke..strokeWidth = armW..strokeCap = StrokeCap.round);
      // Forearm
      canvas.drawLine(elb, hand, Paint()..color = bodyLight..style = PaintingStyle.stroke..strokeWidth = foreW + 2.5 * s..strokeCap = StrokeCap.round);
      canvas.drawLine(elb, hand, Paint()..color = body..style = PaintingStyle.stroke..strokeWidth = foreW..strokeCap = StrokeCap.round);

      // Subtle bicep when curling
      if (curl > 0.2) {
        final bi = Offset((sh.dx + elb.dx) / 2 + side * (-3 * s), (sh.dy + elb.dy) / 2);
        final bSz = 6 * s * curl;
        canvas.drawOval(
          Rect.fromCenter(center: bi, width: bSz * 1.3, height: bSz * 0.8),
          Paint()..color = highlight.withOpacity(opacity * curl * 0.5)..style = PaintingStyle.fill);
      }

      // ── HAND (feminine, gripping) ──
      canvas.drawOval(
        Rect.fromCenter(center: hand, width: 11 * s, height: 7.5 * s),
        Paint()..color = body..style = PaintingStyle.fill);
      canvas.drawOval(
        Rect.fromCenter(center: hand, width: 11 * s, height: 7.5 * s),
        Paint()..color = bodyLight..style = PaintingStyle.stroke..strokeWidth = 1.3 * s);
      // Fingers
      for (int f = 0; f < 4; f++) {
        final fx = hand.dx - 4 * s + f * 2.8 * s;
        canvas.drawLine(Offset(fx, hand.dy - 2 * s), Offset(fx, hand.dy + 2 * s),
          Paint()..color = bodyDark..strokeWidth = 0.5 * s);
      }

      // ── DUMBBELL ──
      final dbHalf = 14 * s;
      final hP = Paint()..color = highlight..strokeWidth = 2.2 * s..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(hand.dx - dbHalf, hand.dy), Offset(hand.dx + dbHalf, hand.dy), hP);
      _drawPlate(canvas, Offset(hand.dx - dbHalf, hand.dy), 4 * s, 12 * s, 2 * s,
        Paint()..color = body..style = PaintingStyle.fill,
        Paint()..color = bodyLight..style = PaintingStyle.stroke..strokeWidth = 2 * s);
      _drawPlate(canvas, Offset(hand.dx + dbHalf, hand.dy), 4 * s, 12 * s, 2 * s,
        Paint()..color = body..style = PaintingStyle.fill,
        Paint()..color = bodyLight..style = PaintingStyle.stroke..strokeWidth = 2 * s);
    }

    // ════════════════════════════════
    // LAYER 6: LEGS (toned, shaped)
    // ════════════════════════════════
    final legY = hipY + 4 * s;
    final stance = 18 * s;
    final squat = curl * 3 * s;
    final thTopW = 13 * s;
    final thBotW = 8.5 * s;
    final cTopW = 8.5 * s;
    final cBotW = 5 * s;
    final thLen = 54 * s;
    final cLen = 48 * s;

    for (int side = -1; side <= 1; side += 2) {
      final hipPt = Offset(cx + side * (hipW - 10 * s), legY);
      final knee = Offset(cx + side * (stance + 4 * s), legY + thLen - squat * 0.3);
      final ankle = Offset(cx + side * (stance + 6 * s), knee.dy + cLen + squat * 0.3);

      // Thigh
      _drawFeminineLimb(canvas, hipPt, knee, thTopW, thBotW, body, bodyLight, s);
      // Legging seam on thigh (side line)
      canvas.drawLine(Offset(hipPt.dx + side * 4 * s, hipPt.dy + 6 * s), Offset(knee.dx + side * 2 * s, knee.dy - 4 * s),
        Paint()..color = clothLight.withOpacity(opacity * 0.5)..strokeWidth = 0.7 * s..strokeCap = StrokeCap.round);

      // Calf
      _drawFeminineLimb(canvas, knee, ankle, cTopW, cBotW, body, bodyLight, s);

      // Knee (subtle)
      canvas.drawCircle(knee, 3 * s,
        Paint()..color = bodyDark.withOpacity(opacity * 0.25)..style = PaintingStyle.stroke..strokeWidth = 0.8 * s);

      // Calf curve
      final calfMid = Offset((knee.dx + ankle.dx) / 2 + side * 2 * s, (knee.dy + ankle.dy) / 2 - 5 * s);
      canvas.drawOval(
        Rect.fromCenter(center: calfMid, width: 6 * s, height: 12 * s),
        Paint()..color = bodyDark.withOpacity(opacity * 0.3)..style = PaintingStyle.stroke..strokeWidth = 0.8 * s);

      // ── SNEAKER ──
      final shoeX = side == -1 ? ankle.dx - 12 * s : ankle.dx - 8 * s;
      final shoeRR = RRect.fromRectAndRadius(
        Rect.fromLTWH(shoeX, ankle.dy - 2 * s, 20 * s, 9 * s),
        Radius.circular(3.5 * s));
      canvas.drawRRect(shoeRR, Paint()..color = clothDark..style = PaintingStyle.fill);
      canvas.drawRRect(shoeRR, Paint()..color = clothLight..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);
      // Sole
      canvas.drawLine(
        Offset(shoeX, ankle.dy + 5.5 * s),
        Offset(shoeX + 20 * s, ankle.dy + 5.5 * s),
        Paint()..color = bodyDark..strokeWidth = 2 * s..strokeCap = StrokeCap.round);
      // Swoosh accent
      final swoosh = Path()
        ..moveTo(shoeX + 4 * s, ankle.dy + 4 * s)
        ..quadraticBezierTo(shoeX + 10 * s, ankle.dy - 1 * s, shoeX + 17 * s, ankle.dy + 3 * s);
      canvas.drawPath(swoosh, Paint()..color = clothAccent..style = PaintingStyle.stroke..strokeWidth = 1.2 * s);
    }

    // ════════════════════════════════
    // LAYER 7: SPARKLE EFFECTS
    // ════════════════════════════════
    if (curl > 0.4) {
      final intensity = (curl - 0.4) / 0.6;
      final sparkleCol = const Color(0xFFFF69B4).withOpacity(opacity * intensity * 1.5);
      final goldCol = const Color(0xFFFFD700).withOpacity(opacity * intensity * 2);

      // Pink sparkle dots
      canvas.drawCircle(Offset(cx - headR - 10 * s, headY - headR + intensity * 15 * s), 2.5 * s, Paint()..color = sparkleCol);
      canvas.drawCircle(Offset(cx + headR + 14 * s, headY - headR + 8 * s + intensity * 10 * s), 1.8 * s, Paint()..color = sparkleCol);
      canvas.drawCircle(Offset(cx - headR - 15 * s, headY + 10 * s), 1.5 * s, Paint()..color = sparkleCol);

      // Gold star sparkles
      if (curl > 0.65) {
        final si = (curl - 0.65) / 0.35;
        for (int i = 0; i < 2; i++) {
          final sx = cx + (i == 0 ? -1 : 1) * (headR + 18 * s);
          final sy = headY - 15 * s + i * 25 * s;
          final sz = 4 * s * si;
          final sP = Paint()..color = goldCol..strokeWidth = 1.2 * s..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset(sx - sz, sy), Offset(sx + sz, sy), sP);
          canvas.drawLine(Offset(sx, sy - sz), Offset(sx, sy + sz), sP);
          canvas.drawLine(Offset(sx - sz * 0.6, sy - sz * 0.6), Offset(sx + sz * 0.6, sy + sz * 0.6), sP);
          canvas.drawLine(Offset(sx + sz * 0.6, sy - sz * 0.6), Offset(sx - sz * 0.6, sy + sz * 0.6), sP);
        }
      }
    }
  }

  /// Draw a smoothly tapered feminine limb
  void _drawFeminineLimb(Canvas canvas, Offset start, Offset end,
      double startThick, double endThick, Color fill, Color stroke, double s) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final px = -dy / len;
    final py = dx / len;

    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final bulgeThick = max(startThick, endThick) * 1.12;

    final path = Path()
      ..moveTo(start.dx + px * startThick / 2, start.dy + py * startThick / 2)
      ..quadraticBezierTo(
          mid.dx + px * bulgeThick / 2, mid.dy + py * bulgeThick / 2,
          end.dx + px * endThick / 2, end.dy + py * endThick / 2)
      ..lineTo(end.dx - px * endThick / 2, end.dy - py * endThick / 2)
      ..quadraticBezierTo(
          mid.dx - px * bulgeThick / 2, mid.dy - py * bulgeThick / 2,
          start.dx - px * startThick / 2, start.dy - py * startThick / 2)
      ..close();

    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 1.8 * s);
  }

  void _drawPlate(Canvas canvas, Offset center, double w, double h, double r, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));
    canvas.drawRRect(rr, fill);
    canvas.drawRRect(rr, stroke);
  }

  @override
  bool shouldRepaint(covariant _FitnessWomanPainter oldDelegate) {
    return oldDelegate.liftProgress != liftProgress ||
        oldDelegate.breatheProgress != breatheProgress;
  }
}
