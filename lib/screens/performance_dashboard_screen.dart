// ============================================================================
// MUSCLE POWER - Performance Dashboard Screen
// ============================================================================
//
// File: performance_dashboard_screen.dart
// Description: Visual dashboard for app performance metrics and SLOs
//
// Displays:
// - Startup times (cold/warm) with SLO indicators
// - Frame rendering stats (FPS, jank rate, build/raster times)
// - Network latency (avg, p50, p95) and error rates
// - Real-time frame timing chart
// - SLO compliance overview with color-coded status
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/performance_service.dart';
import '../services/health_dashboard_service.dart';
import 'dart:async';

/// Performance & Health Dashboard Screen
///
/// Provides a comprehensive view of app performance metrics,
/// health SLOs, and alert status in a scrollable dashboard layout.
class PerformanceDashboardScreen extends StatefulWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  State<PerformanceDashboardScreen> createState() =>
      _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState
    extends State<PerformanceDashboardScreen> {
  final PerformanceService _perfService = PerformanceService();
  final HealthDashboardService _healthService = HealthDashboardService();

  PerformanceSummary? _perfSummary;
  HealthDashboard? _healthDashboard;

  StreamSubscription? _perfSub;
  StreamSubscription? _healthSub;

  @override
  void initState() {
    super.initState();
    _loadData();

    _perfSub = _perfService.summaryStream.listen((summary) {
      if (mounted) setState(() => _perfSummary = summary);
    });

    _healthSub = _healthService.dashboardStream.listen((dashboard) {
      if (mounted) setState(() => _healthDashboard = dashboard);
    });
  }

  void _loadData() {
    _perfSummary = _perfService.getSummary();
    _healthDashboard = _healthService.getDashboard();
  }

  @override
  void dispose() {
    _perfSub?.cancel();
    _healthSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'Performance & Health',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh data',
            onPressed: () => setState(() => _loadData()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Health Status Banner
            _buildHealthStatusBanner(),
            const SizedBox(height: 20),

            // SLO Compliance Overview
            _buildSectionTitle('Service Level Objectives', Icons.verified),
            const SizedBox(height: 12),
            _buildSloOverview(),
            const SizedBox(height: 24),

            // Startup Performance
            _buildSectionTitle('Startup Performance', Icons.rocket_launch),
            const SizedBox(height: 12),
            _buildStartupMetrics(),
            const SizedBox(height: 24),

            // Frame Rendering
            _buildSectionTitle('Frame Rendering', Icons.speed),
            const SizedBox(height: 12),
            _buildFrameMetrics(),
            const SizedBox(height: 24),

            // Network Performance
            _buildSectionTitle('Network Performance', Icons.wifi),
            const SizedBox(height: 12),
            _buildNetworkMetrics(),
            const SizedBox(height: 24),

            // Active Alerts
            _buildSectionTitle('Active Alerts', Icons.warning_amber),
            const SizedBox(height: 12),
            _buildAlertsList(),
            const SizedBox(height: 24),

            // Error Budget
            _buildSectionTitle('Error Budget', Icons.data_usage),
            const SizedBox(height: 12),
            _buildErrorBudget(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ========================================
  // HEALTH STATUS BANNER
  // ========================================

  Widget _buildHealthStatusBanner() {
    final dashboard = _healthDashboard;
    if (dashboard == null) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (dashboard.overallStatus) {
      case HealthStatus.healthy:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'All Systems Healthy';
        break;
      case HealthStatus.degraded:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Performance Degraded';
        break;
      case HealthStatus.unhealthy:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'SLO Violations Detected';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.3),
            statusColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dashboard.activeAlerts.length} active alert${dashboard.activeAlerts.length != 1 ? "s" : ""} • '
                  '${dashboard.totalSessions} sessions tracked',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _perfSummary != null
                  ? '${(_perfSummary!.overallSloCompliance * 100).toStringAsFixed(0)}%'
                  : '--',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // SLO OVERVIEW
  // ========================================

  Widget _buildSloOverview() {
    final dashboard = _healthDashboard;
    if (dashboard == null) {
      return _buildEmptyState('No SLO data available');
    }

    return Column(
      children: dashboard.slos.map((slo) => _buildSloCard(slo)).toList(),
    );
  }

  Widget _buildSloCard(ServiceLevelObjective slo) {
    Color statusColor;
    IconData statusIcon;
    switch (slo.status) {
      case HealthStatus.healthy:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case HealthStatus.degraded:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case HealthStatus.unhealthy:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slo.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                slo.displayValue,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar showing current value vs target
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: slo.currentValue.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slo.description,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                'Target: ${slo.displayTarget}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================
  // STARTUP METRICS
  // ========================================

  Widget _buildStartupMetrics() {
    final perf = _perfSummary;
    if (perf == null) return _buildEmptyState('No startup data');

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Cold Start',
            value: '${perf.avgColdStartMs.toStringAsFixed(0)} ms',
            subtitle: 'P95: ${perf.p95ColdStartMs.toStringAsFixed(0)} ms',
            icon: Icons.ac_unit,
            sloMet: perf.coldStartSloMet,
            sloLabel: 'SLO: < ${PerformanceService.coldStartSloMs.toInt()} ms',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Warm Start',
            value: '${perf.avgWarmStartMs.toStringAsFixed(0)} ms',
            subtitle: 'P95: ${perf.p95WarmStartMs.toStringAsFixed(0)} ms',
            icon: Icons.wb_sunny,
            sloMet: perf.warmStartSloMet,
            sloLabel: 'SLO: < ${PerformanceService.warmStartSloMs.toInt()} ms',
          ),
        ),
      ],
    );
  }

  // ========================================
  // FRAME METRICS
  // ========================================

  Widget _buildFrameMetrics() {
    final perf = _perfSummary;
    if (perf == null) return _buildEmptyState('No frame data');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Avg FPS',
                value: perf.avgFps.toStringAsFixed(1),
                subtitle: '${perf.totalFrames} frames tracked',
                icon: Icons.speed,
                sloMet: perf.fpsSloMet,
                sloLabel: 'SLO: >= ${PerformanceService.fpsSlO.toInt()} FPS',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Jank Rate',
                value: '${(perf.jankRate * 100).toStringAsFixed(1)}%',
                subtitle: '${perf.jankFrames} jank frames',
                icon: Icons.warning_amber,
                sloMet: perf.jankSloMet,
                sloLabel: 'SLO: < ${(PerformanceService.jankRateSlo * 100).toInt()}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Avg Build',
                value: '${perf.avgFrameBuildMs.toStringAsFixed(2)} ms',
                subtitle: 'Frame build time',
                icon: Icons.build,
                sloMet: perf.avgFrameBuildMs < 16.0,
                sloLabel: 'Target: < 16 ms',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Avg Raster',
                value: '${perf.avgFrameRasterMs.toStringAsFixed(2)} ms',
                subtitle: 'P95: ${perf.p95FrameDurationMs.toStringAsFixed(1)} ms',
                icon: Icons.brush,
                sloMet: perf.avgFrameRasterMs < 16.0,
                sloLabel: 'Target: < 16 ms',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Frame timing chart
        _buildFrameTimingChart(),
      ],
    );
  }

  Widget _buildFrameTimingChart() {
    final timings = _perfService.getRecentFrameTimings(count: 60);
    if (timings.isEmpty) {
      return _buildEmptyState('No frame timings recorded yet');
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frame Durations (last ${timings.length} frames)',
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: timings.asMap().entries.map((entry) {
                  final duration =
                      entry.value.totalDuration.inMicroseconds / 1000.0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: duration.clamp(0, 50),
                        color: entry.value.isJank
                            ? Colors.red
                            : const Color(0xFF00D9FF),
                        width: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} ms',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 16.67,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: value == 16.67
                          ? Colors.red.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.1),
                      strokeWidth: value == 16.67 ? 2 : 1,
                      dashArray: value == 16.67 ? [5, 5] : null,
                    );
                  },
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 16.67,
                      color: Colors.red.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) => '60 FPS limit',
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // NETWORK METRICS
  // ========================================

  Widget _buildNetworkMetrics() {
    final perf = _perfSummary;
    if (perf == null) return _buildEmptyState('No network data');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Avg Latency',
                value: '${perf.avgNetworkLatencyMs.toStringAsFixed(0)} ms',
                subtitle: 'P50: ${perf.p50NetworkLatencyMs.toStringAsFixed(0)} ms',
                icon: Icons.timer,
                sloMet: perf.networkLatencySloMet,
                sloLabel: 'P95 SLO: < ${PerformanceService.networkLatencyP95SloMs.toInt()} ms',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Error Rate',
                value: '${(perf.networkErrorRate * 100).toStringAsFixed(2)}%',
                subtitle: '${perf.failedRequests}/${perf.totalRequests} failed',
                icon: Icons.error_outline,
                sloMet: perf.networkErrorSloMet,
                sloLabel:
                    'SLO: < ${(PerformanceService.networkErrorRateSlo * 100).toInt()}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'P95 Latency',
                value: '${perf.p95NetworkLatencyMs.toStringAsFixed(0)} ms',
                subtitle: 'Slowest 5% of requests',
                icon: Icons.trending_up,
                sloMet: perf.p95NetworkLatencyMs <= PerformanceService.networkLatencyP95SloMs,
                sloLabel: 'SLO: < ${PerformanceService.networkLatencyP95SloMs.toInt()} ms',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Throughput',
                value: _formatBytes(perf.avgThroughputBytesPerSec),
                subtitle: 'Average bytes/sec',
                icon: Icons.swap_vert,
                sloMet: true,
                sloLabel: '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========================================
  // ALERTS
  // ========================================

  Widget _buildAlertsList() {
    final alerts = _healthDashboard?.activeAlerts ?? [];
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'No active alerts - all clear!',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        Color alertColor;
        switch (alert.severity) {
          case AlertSeverity.critical:
            alertColor = Colors.red;
            break;
          case AlertSeverity.warning:
            alertColor = Colors.orange;
            break;
          case AlertSeverity.info:
            alertColor = Colors.blue;
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: alertColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(
                alert.severity == AlertSeverity.critical
                    ? Icons.error
                    : alert.severity == AlertSeverity.warning
                        ? Icons.warning
                        : Icons.info,
                color: alertColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.message,
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.grey, size: 20),
                onPressed: () {
                  _healthService.acknowledgeAlert(alert.id);
                  setState(() => _healthDashboard = _healthService.getDashboard());
                },
                tooltip: 'Acknowledge',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ========================================
  // ERROR BUDGET
  // ========================================

  Widget _buildErrorBudget() {
    final dashboard = _healthDashboard;
    if (dashboard == null) return const SizedBox.shrink();

    final budgetUsed = dashboard.errorBudgetUsed;
    final budgetColor = budgetUsed > 0.8
        ? Colors.red
        : budgetUsed > 0.5
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crash-Free Error Budget',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(budgetUsed * 100).toStringAsFixed(1)}% consumed',
                style: TextStyle(
                  color: budgetColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: budgetUsed.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(budgetColor),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${(HealthDashboardService.crashFreeTarget * 100).toStringAsFixed(1)}% crash-free sessions. '
            '${((1.0 - budgetUsed) * 100).toStringAsFixed(1)}% of error budget remaining.',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ========================================
  // SHARED WIDGETS
  // ========================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required bool sloMet,
    required String sloLabel,
  }) {
    final statusColor = sloMet ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00D9FF), size: 18),
              const Spacer(),
              Icon(
                sloMet ? Icons.check_circle : Icons.cancel,
                color: statusColor,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: Colors.grey[300], fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          if (sloLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sloLabel,
              style: TextStyle(
                color: statusColor.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, color: Colors.grey[600], size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Data will appear as the app is used.',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B/s';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}
