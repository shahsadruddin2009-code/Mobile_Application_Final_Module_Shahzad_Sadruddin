// ============================================================================
// IRON FORGE - Statistics Card Widgets
// ============================================================================
//
// File: stat_card.dart
// Description: Reusable cards for displaying statistics and metrics
//
// Widgets Included:
// 1. StatCard - Static statistics display with icon, value, and label
// 2. AnimatedStatCard - Same as StatCard but with entrance animation
//
// Usage Examples:
//
// StatCard:
// ```dart
// StatCard(
//   icon: Icons.fitness_center,
//   value: '42',
//   label: 'Workouts',
//   gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
// )
// ```
//
// AnimatedStatCard:
// ```dart
// AnimatedStatCard(
//   icon: Icons.timer,
//   value: '120h',
//   label: 'Total Time',
//   gradient: [Color(0xFF00D9FF), Color(0xFF00B4D8)],
//   animationDelay: 200, // milliseconds
// )
// ```
//
// Layout:
// - Icon on left with gradient background circle
// - Value (large, bold) stacked above label (smaller, grey)
// - Dark card background with colored border accent
// - Subtle shadow for depth
//
// Common Use Cases:
// - Workout count display
// - Total time tracked
// - Calories burned
// - Achievement counts
// - Progress metrics
// ============================================================================

import 'package:flutter/material.dart';

/// A card widget for displaying statistics with an icon
///
/// Displays a metric with:
/// - Gradient-colored icon on the left
/// - Large value text
/// - Smaller label text below
///
/// Parameters:
/// - [icon]: The IconData for the statistic type
/// - [value]: The metric value to display (e.g., "42", "120h")
/// - [label]: Description of the metric (e.g., "Workouts")
/// - [gradient]: Two-color gradient for the icon background
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;
  final int animationDelay;

  const AnimatedStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: StatCard(
              icon: widget.icon,
              value: widget.value,
              label: widget.label,
              gradient: widget.gradient,
            ),
          ),
        );
      },
    );
  }
}

class CircularStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double progress;

  const CircularStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.progress = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const MiniStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
