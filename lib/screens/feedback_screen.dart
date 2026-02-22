// ============================================================================
// MUSCLE POWER - User Feedback & Support Screen
// ============================================================================
//
// File: feedback_screen.dart
// Description: UI for submitting feedback, viewing support tickets,
//              NPS surveys, and feedback analytics.
//
// Features:
// - Tab-based layout: Submit Feedback | My Tickets | NPS Survey
// - Bug report, feature request, and general feedback forms
// - Star rating widget
// - Support ticket list with status indicators
// - Ticket detail view with message thread
// - NPS survey with score slider and reason field
// - Feedback analytics summary cards
//
// ============================================================================

import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../services/auth_service.dart';

/// User Feedback & Support Screen
///
/// Provides a comprehensive interface for users to:
/// - Submit bug reports, feature requests, and general feedback
/// - View and track support tickets
/// - Complete NPS satisfaction surveys
/// - See feedback analytics summary
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final FeedbackService _feedbackService = FeedbackService();
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text(
          'Feedback & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B35),
          labelColor: const Color(0xFFFF6B35),
          unselectedLabelColor: Colors.grey[500],
          tabs: const [
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
            Tab(icon: Icon(Icons.support_agent), text: 'Tickets'),
            Tab(icon: Icon(Icons.star), text: 'Survey'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackTab(),
          _buildTicketsTab(),
          _buildSurveyTab(),
        ],
      ),
    );
  }

  // ========================================
  // FEEDBACK SUBMISSION TAB
  // ========================================

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Summary
          _buildFeedbackSummaryCards(),
          const SizedBox(height: 24),

          // Feedback Type Cards
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a category to submit your feedback',
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          const SizedBox(height: 16),

          _buildFeedbackTypeCard(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            description:
                'Something not working correctly? Let us know so we can fix it.',
            color: Colors.red,
            type: FeedbackType.bugReport,
          ),
          const SizedBox(height: 12),
          _buildFeedbackTypeCard(
            icon: Icons.lightbulb,
            title: 'Feature Request',
            description: 'Have an idea to improve the app? We\'d love to hear it.',
            color: Colors.amber,
            type: FeedbackType.featureRequest,
          ),
          const SizedBox(height: 12),
          _buildFeedbackTypeCard(
            icon: Icons.chat_bubble,
            title: 'General Feedback',
            description:
                'Share your thoughts, suggestions, or compliments with us.',
            color: const Color(0xFF00D9FF),
            type: FeedbackType.general,
          ),
          const SizedBox(height: 12),
          _buildFeedbackTypeCard(
            icon: Icons.thumb_up,
            title: 'Praise / Testimonial',
            description: 'Loving the app? Tell us what you enjoy most!',
            color: Colors.green,
            type: FeedbackType.praise,
          ),
          const SizedBox(height: 24),

          // Recent Feedback
          _buildRecentFeedback(),
        ],
      ),
    );
  }

  Widget _buildFeedbackSummaryCards() {
    final summary = _feedbackService.getSummary();

    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            '${summary.totalFeedback}',
            'Total',
            Icons.feedback,
            const Color(0xFF00D9FF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStat(
            '${summary.bugReports}',
            'Bugs',
            Icons.bug_report,
            Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStat(
            '${summary.openTickets}',
            'Open',
            Icons.support_agent,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStat(
            summary.averageRating > 0
                ? '${summary.averageRating.toStringAsFixed(1)}'
                : '--',
            'Rating',
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required FeedbackType type,
  }) {
    return InkWell(
      onTap: () => _showFeedbackForm(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFeedback() {
    final feedback = _feedbackService.getAllFeedback();
    if (feedback.isEmpty) return const SizedBox.shrink();

    final recent = feedback.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Submissions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...recent.map((fb) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _getFeedbackIcon(fb.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _timeAgo(fb.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (fb.rating != null)
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < fb.rating! ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  // ========================================
  // TICKETS TAB
  // ========================================

  Widget _buildTicketsTab() {
    final tickets = _feedbackService.getAllTickets();

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'No Support Tickets',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit a bug report to create a ticket',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets.reversed.toList()[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    Color statusColor;
    String statusText;
    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = Colors.blue;
        statusText = 'Open';
        break;
      case TicketStatus.inProgress:
        statusColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case TicketStatus.waitingOnUser:
        statusColor = Colors.purple;
        statusText = 'Awaiting Reply';
        break;
      case TicketStatus.resolved:
        statusColor = Colors.green;
        statusText = 'Resolved';
        break;
      case TicketStatus.closed:
        statusColor = Colors.grey;
        statusText = 'Closed';
        break;
    }

    Color priorityColor;
    switch (ticket.priority) {
      case TicketPriority.urgent:
        priorityColor = Colors.red;
        break;
      case TicketPriority.high:
        priorityColor = Colors.orange;
        break;
      case TicketPriority.medium:
        priorityColor = Colors.amber;
        break;
      case TicketPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return InkWell(
      onTap: () => _showTicketDetail(ticket),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.priority.name.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(ticket.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.subject,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[300], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${ticket.messages.length} messages',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // NPS SURVEY TAB
  // ========================================

  Widget _buildSurveyTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NPS Score Card
          _buildNpsScoreCard(),
          const SizedBox(height: 24),

          // NPS Survey Form
          _buildNpsSurveyForm(),
          const SizedBox(height: 24),

          // Quick Rating Section
          _buildQuickRatingSection(),
          const SizedBox(height: 24),

          // NPS Response History
          _buildNpsHistory(),
        ],
      ),
    );
  }

  Widget _buildNpsScoreCard() {
    final summary = _feedbackService.getSummary();
    final npsScore = summary.npsScore;

    Color scoreColor;
    String scoreLabel;
    if (npsScore >= 50) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent';
    } else if (npsScore >= 0) {
      scoreColor = Colors.amber;
      scoreLabel = 'Good';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Needs Improvement';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.2),
            scoreColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Net Promoter Score',
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${npsScore.toStringAsFixed(0)}',
            style: TextStyle(
              color: scoreColor,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            scoreLabel,
            style: TextStyle(
              color: scoreColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNpsCategory(
                  '${summary.promoters}', 'Promoters', Colors.green),
              _buildNpsCategory(
                  '${summary.passives}', 'Passives', Colors.amber),
              _buildNpsCategory(
                  '${summary.detractors}', 'Detractors', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNpsCategory(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[300], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNpsSurveyForm() {
    return _NpsSurveyWidget(
      onSubmit: (score, reason) async {
        await _feedbackService.submitNpsResponse(
          score: score,
          reason: reason,
        );
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thank you for your feedback!'),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      },
    );
  }

  Widget _buildQuickRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Ratings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickRatingRow('Workout Experience', 'workout'),
        const SizedBox(height: 8),
        _buildQuickRatingRow('App Navigation', 'navigation'),
        const SizedBox(height: 8),
        _buildQuickRatingRow('Content Quality', 'content'),
      ],
    );
  }

  Widget _buildQuickRatingRow(String label, String context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          ...List.generate(5, (index) {
            return IconButton(
              icon: const Icon(Icons.star_border, color: Colors.amber),
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
              onPressed: () async {
                await _feedbackService.submitQuickRating(
                  rating: index + 1,
                  context: context,
                );
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                    SnackBar(
                      content:
                          Text('Rated $label ${index + 1}/5. Thank you!'),
                      backgroundColor: Colors.green[700],
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNpsHistory() {
    final responses = _feedbackService.getNpsResponses();
    if (responses.isEmpty) return const SizedBox.shrink();

    final recent = responses.reversed.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Survey History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...recent.map((nps) {
          Color categoryColor;
          switch (nps.category) {
            case NpsCategory.promoter:
              categoryColor = Colors.green;
              break;
            case NpsCategory.passive:
              categoryColor = Colors.amber;
              break;
            case NpsCategory.detractor:
              categoryColor = Colors.red;
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${nps.score}',
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nps.category.name.toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (nps.reason != null)
                        Text(
                          nps.reason!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _timeAgo(nps.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ========================================
  // FEEDBACK FORM DIALOG
  // ========================================

  void _showFeedbackForm(FeedbackType type) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int rating = 0;
    bool contactConsent = false;

    String formTitle;
    switch (type) {
      case FeedbackType.bugReport:
        formTitle = 'Report a Bug';
        break;
      case FeedbackType.featureRequest:
        formTitle = 'Feature Request';
        break;
      case FeedbackType.praise:
        formTitle = 'Share Praise';
        break;
      default:
        formTitle = 'General Feedback';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  formTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Title field
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                    filled: true,
                    fillColor: const Color(0xFF0F0F1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      type == FeedbackType.bugReport
                          ? Icons.bug_report
                          : type == FeedbackType.featureRequest
                              ? Icons.lightbulb
                              : Icons.feedback,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description field
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey[300]),
                    filled: true,
                    fillColor: const Color(0xFF0F0F1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: type == FeedbackType.bugReport
                        ? 'Steps to reproduce the issue...'
                        : 'Tell us more...',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 16),

                // Star Rating
                const Text(
                  'Rate your experience',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () =>
                          setModalState(() => rating = i + 1),
                    );
                  }),
                ),
                const SizedBox(height: 12),

                // Contact consent
                Row(
                  children: [
                    Checkbox(
                      value: contactConsent,
                      onChanged: (v) =>
                          setModalState(() => contactConsent = v ?? false),
                      activeColor: const Color(0xFFFF6B35),
                    ),
                    const Expanded(
                      child: Text(
                        'I consent to being contacted for follow-up',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          descController.text.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      await _feedbackService.submitFeedback(
                        type: type,
                        title: titleController.text,
                        description: descController.text,
                        rating: rating > 0 ? rating : null,
                        userName: _authService.currentUser?['fullName'] ??
                            'User',
                        userEmail:
                            _authService.currentUser?['email'] as String?,
                        contactConsent: contactConsent,
                        tags: [type.name],
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Feedback submitted successfully! Thank you.'),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================
  // TICKET DETAIL DIALOG
  // ========================================

  void _showTicketDetail(SupportTicket ticket) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final currentTicket = _feedbackService.getTicket(ticket.id) ?? ticket;

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle & Title
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentTicket.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ticket: ${currentTicket.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Messages
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: currentTicket.messages.length,
                    itemBuilder: (ctx, index) {
                      final msg = currentTicket.messages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: msg.isFromUser
                              ? const Color(0xFF0F0F1A)
                              : const Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: msg.isFromUser
                                ? Colors.grey.withValues(alpha: 0.2)
                                : const Color(0xFFFF6B35)
                                    .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  msg.isFromUser
                                      ? Icons.person
                                      : Icons.support_agent,
                                  color: msg.isFromUser
                                      ? Colors.grey[300]
                                      : const Color(0xFFFF6B35),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    color: msg.isFromUser
                                        ? Colors.grey[300]
                                        : const Color(0xFFFF6B35),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _timeAgo(msg.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              msg.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Reply Field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a reply...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: const Color(0xFF0F0F1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          if (messageController.text.isNotEmpty) {
                            await _feedbackService.addTicketMessage(
                              ticketId: currentTicket.id,
                              message: messageController.text,
                              senderName:
                                  _authService.currentUser?['fullName'] ??
                                      'User',
                              isFromUser: true,
                            );
                            messageController.clear();
                            setModalState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  Widget _getFeedbackIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.bugReport:
        return const Icon(Icons.bug_report, color: Colors.red, size: 20);
      case FeedbackType.featureRequest:
        return const Icon(Icons.lightbulb, color: Colors.amber, size: 20);
      case FeedbackType.praise:
        return const Icon(Icons.thumb_up, color: Colors.green, size: 20);
      case FeedbackType.complaint:
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
      case FeedbackType.general:
        return const Icon(Icons.chat_bubble, color: Color(0xFF00D9FF), size: 20);
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}

// =============================================================================
// NPS SURVEY WIDGET
// =============================================================================

/// Standalone NPS survey widget with score slider and reason field
class _NpsSurveyWidget extends StatefulWidget {
  final Future<void> Function(int score, String? reason) onSubmit;

  const _NpsSurveyWidget({required this.onSubmit});

  @override
  State<_NpsSurveyWidget> createState() => _NpsSurveyWidgetState();
}

class _NpsSurveyWidgetState extends State<_NpsSurveyWidget> {
  double _npsScore = 7;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    String categoryLabel;
    if (_npsScore <= 6) {
      scoreColor = Colors.red;
      categoryLabel = 'Detractor';
    } else if (_npsScore <= 8) {
      scoreColor = Colors.amber;
      categoryLabel = 'Passive';
    } else {
      scoreColor = Colors.green;
      categoryLabel = 'Promoter';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How likely are you to recommend\nMuscle Power to a friend?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Score display
          Center(
            child: Text(
              '${_npsScore.round()}',
              style: TextStyle(
                color: scoreColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              categoryLabel,
              style: TextStyle(
                color: scoreColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Slider  
          Slider(
            value: _npsScore,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: scoreColor,
            inactiveColor: Colors.grey[800],
            label: '${_npsScore.round()}',
            onChanged: (value) => setState(() => _npsScore = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 - Not likely',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              Text('10 - Very likely',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),

          // Reason field
          TextField(
            controller: _reasonController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Tell us why (optional)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFF0F0F1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await widget.onSubmit(
                  _npsScore.round(),
                  _reasonController.text.isNotEmpty
                      ? _reasonController.text
                      : null,
                );
                _reasonController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Submit Survey',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
