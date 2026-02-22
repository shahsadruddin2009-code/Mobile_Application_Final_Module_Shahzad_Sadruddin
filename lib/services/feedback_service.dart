// ============================================================================
// MUSCLE POWER - User Feedback & Support Service
// ============================================================================
//
// File: feedback_service.dart
// Description: Manages user feedback collection, bug reports, feature
//              requests, NPS surveys, and support ticket lifecycle.
//
// Features:
// - In-app feedback submission (bug reports, feature requests, general)
// - Net Promoter Score (NPS) surveys with scheduling
// - Star ratings with contextual prompts
// - Support ticket creation and tracking
// - Feedback categorization and priority assignment
// - Automated follow-up scheduling
// - Feedback analytics and sentiment summary
//
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// FEEDBACK DATA MODELS
// =============================================================================

/// Type of feedback submitted
enum FeedbackType { bugReport, featureRequest, general, complaint, praise }

/// Priority level for support tickets
enum TicketPriority { low, medium, high, urgent }

/// Current status of a support ticket
enum TicketStatus { open, inProgress, waitingOnUser, resolved, closed }

/// NPS category based on score
enum NpsCategory { detractor, passive, promoter }

/// A user feedback submission
class FeedbackEntry {
  final String id;
  final FeedbackType type;
  final String title;
  final String description;
  final int? rating; // 1-5 star rating
  final String? screenContext; // Which screen they were on
  final DateTime timestamp;
  final String? userEmail;
  final String? userName;
  final List<String> tags;
  final Map<String, dynamic>? deviceInfo;
  final String? screenshotPath;
  final bool contactConsent; // User consents to follow-up

  FeedbackEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.rating,
    this.screenContext,
    required this.timestamp,
    this.userEmail,
    this.userName,
    this.tags = const [],
    this.deviceInfo,
    this.screenshotPath,
    this.contactConsent = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'rating': rating,
        'screenContext': screenContext,
        'timestamp': timestamp.toIso8601String(),
        'userEmail': userEmail,
        'userName': userName,
        'tags': tags,
        'deviceInfo': deviceInfo,
        'screenshotPath': screenshotPath,
        'contactConsent': contactConsent,
      };

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      id: json['id'] as String,
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.general,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      rating: json['rating'] as int?,
      screenContext: json['screenContext'] as String?,
      timestamp: DateTime.parse(json['timestamp']),
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
      screenshotPath: json['screenshotPath'] as String?,
      contactConsent: json['contactConsent'] as bool? ?? false,
    );
  }
}

/// A support ticket with lifecycle tracking
class SupportTicket {
  final String id;
  final String feedbackId; // Links to the original feedback
  final String subject;
  final String description;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketMessage> messages;
  final String? assignedTo;
  final String? resolution;

  SupportTicket({
    required this.id,
    required this.feedbackId,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.assignedTo,
    this.resolution,
  });

  SupportTicket copyWith({
    TicketStatus? status,
    DateTime? updatedAt,
    List<TicketMessage>? messages,
    String? assignedTo,
    String? resolution,
  }) {
    return SupportTicket(
      id: id,
      feedbackId: feedbackId,
      subject: subject,
      description: description,
      priority: priority,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      assignedTo: assignedTo ?? this.assignedTo,
      resolution: resolution ?? this.resolution,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'feedbackId': feedbackId,
        'subject': subject,
        'description': description,
        'priority': priority.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'assignedTo': assignedTo,
        'resolution': resolution,
      };

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      feedbackId: json['feedbackId'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messages: (json['messages'] as List?)
              ?.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      assignedTo: json['assignedTo'] as String?,
      resolution: json['resolution'] as String?,
    );
  }
}

/// A message within a support ticket thread
class TicketMessage {
  final String id;
  final String senderName;
  final bool isFromUser;
  final String content;
  final DateTime timestamp;

  TicketMessage({
    required this.id,
    required this.senderName,
    required this.isFromUser,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderName': senderName,
        'isFromUser': isFromUser,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as String,
      senderName: json['senderName'] as String,
      isFromUser: json['isFromUser'] as bool,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// NPS survey response
class NpsSurveyResponse {
  final String id;
  final int score; // 0-10
  final String? reason;
  final DateTime timestamp;
  final NpsCategory category;

  NpsSurveyResponse({
    required this.id,
    required this.score,
    this.reason,
    required this.timestamp,
  }) : category = score <= 6
            ? NpsCategory.detractor
            : score <= 8
                ? NpsCategory.passive
                : NpsCategory.promoter;

  Map<String, dynamic> toJson() => {
        'id': id,
        'score': score,
        'reason': reason,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NpsSurveyResponse.fromJson(Map<String, dynamic> json) {
    return NpsSurveyResponse(
      id: json['id'] as String,
      score: json['score'] as int,
      reason: json['reason'] as String?,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Feedback analytics summary
class FeedbackSummary {
  final int totalFeedback;
  final int bugReports;
  final int featureRequests;
  final int generalFeedback;
  final double averageRating;
  final int openTickets;
  final int resolvedTickets;
  final double npsScore;
  final int promoters;
  final int passives;
  final int detractors;
  final double avgResolutionTimeHours;
  final Map<String, int> tagCounts;

  FeedbackSummary({
    required this.totalFeedback,
    required this.bugReports,
    required this.featureRequests,
    required this.generalFeedback,
    required this.averageRating,
    required this.openTickets,
    required this.resolvedTickets,
    required this.npsScore,
    required this.promoters,
    required this.passives,
    required this.detractors,
    required this.avgResolutionTimeHours,
    required this.tagCounts,
  });
}

// =============================================================================
// FEEDBACK SERVICE (SINGLETON)
// =============================================================================

/// Manages all user feedback, support tickets, and NPS surveys.
///
/// Provides a complete feedback loop:
/// 1. Users submit feedback (bug, feature request, general)
/// 2. Priority-based support ticket creation
/// 3. Two-way message thread for issue resolution
/// 4. Periodic NPS surveys for satisfaction tracking
/// 5. Analytics for feedback trends and sentiment
///
/// Usage:
/// ```dart
/// final feedback = FeedbackService();
/// await feedback.init();
/// await feedback.submitFeedback(type: FeedbackType.bugReport, ...);
/// final summary = feedback.getSummary();
/// ```
class FeedbackService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // ========================================
  // DATA STORAGE
  // ========================================
  final List<FeedbackEntry> _feedback = [];
  final List<SupportTicket> _tickets = [];
  final List<NpsSurveyResponse> _npsResponses = [];
  bool _initialized = false;
  DateTime? _lastNpsPrompt;

  // Streams
  final StreamController<FeedbackSummary> _summaryController =
      StreamController<FeedbackSummary>.broadcast();
  Stream<FeedbackSummary> get summaryStream => _summaryController.stream;

  final StreamController<SupportTicket> _ticketUpdateController =
      StreamController<SupportTicket>.broadcast();
  Stream<SupportTicket> get ticketUpdateStream => _ticketUpdateController.stream;

  // NPS scheduling
  static const int _npsCooldownDays = 90; // Don't ask more than once per 90 days
  static const int _npsMinSessionsBeforePrompt = 5;

  // ========================================
  // INITIALIZATION
  // ========================================

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadPersistedData();
  }

  // ========================================
  // FEEDBACK SUBMISSION
  // ========================================

  /// Submit a new feedback entry.
  ///
  /// Returns the created feedback entry with a generated ID.
  /// Automatically creates a support ticket for bug reports.
  Future<FeedbackEntry> submitFeedback({
    required FeedbackType type,
    required String title,
    required String description,
    int? rating,
    String? screenContext,
    String? userEmail,
    String? userName,
    List<String> tags = const [],
    bool contactConsent = false,
  }) async {
    final entry = FeedbackEntry(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      description: description,
      rating: rating,
      screenContext: screenContext,
      timestamp: DateTime.now(),
      userEmail: userEmail,
      userName: userName,
      tags: tags,
      contactConsent: contactConsent,
    );

    _feedback.add(entry);

    // Auto-create support tickets for bug reports and complaints
    if (type == FeedbackType.bugReport || type == FeedbackType.complaint) {
      await _createTicketFromFeedback(entry);
    }

    await _persistData();
    _emitSummary();
    return entry;
  }

  /// Submit a quick rating (e.g., "How was your workout?")
  Future<void> submitQuickRating({
    required int rating,
    required String context,
    String? comment,
  }) async {
    await submitFeedback(
      type: FeedbackType.general,
      title: 'Quick Rating: $context',
      description: comment ?? 'User rated $rating/5 for $context',
      rating: rating,
      screenContext: context,
    );
  }

  // ========================================
  // SUPPORT TICKETS
  // ========================================

  Future<SupportTicket> _createTicketFromFeedback(FeedbackEntry feedback) async {
    final priority = feedback.type == FeedbackType.bugReport
        ? TicketPriority.high
        : TicketPriority.medium;

    final ticket = SupportTicket(
      id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      feedbackId: feedback.id,
      subject: feedback.title,
      description: feedback.description,
      priority: priority,
      status: TicketStatus.open,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [
        TicketMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderName: feedback.userName ?? 'User',
          isFromUser: true,
          content: feedback.description,
          timestamp: DateTime.now(),
        ),
        TicketMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
          senderName: 'Muscle Power Support',
          isFromUser: false,
          content: 'Thank you for your ${feedback.type == FeedbackType.bugReport ? "bug report" : "feedback"}. '
              'We\'ve received your message and our team will review it shortly. '
              'Your ticket ID is: ticket_${DateTime.now().millisecondsSinceEpoch}.',
          timestamp: DateTime.now(),
        ),
      ],
    );

    _tickets.add(ticket);
    if (!_ticketUpdateController.isClosed) {
      _ticketUpdateController.add(ticket);
    }
    return ticket;
  }

  /// Create a support ticket manually
  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    TicketPriority priority = TicketPriority.medium,
    String? userName,
  }) async {
    final feedback = await submitFeedback(
      type: FeedbackType.general,
      title: subject,
      description: description,
      userName: userName,
      contactConsent: true,
    );

    final existingTicket = _tickets.where((t) => t.feedbackId == feedback.id);
    if (existingTicket.isNotEmpty) return existingTicket.first;

    return _createTicketFromFeedback(feedback);
  }

  /// Add a message to a support ticket
  Future<void> addTicketMessage({
    required String ticketId,
    required String message,
    required String senderName,
    required bool isFromUser,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final ticket = _tickets[index];
    final newMessage = TicketMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      isFromUser: isFromUser,
      content: message,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...ticket.messages, newMessage];
    _tickets[index] = ticket.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
      status: isFromUser ? TicketStatus.open : TicketStatus.waitingOnUser,
    );

    if (!_ticketUpdateController.isClosed) {
      _ticketUpdateController.add(_tickets[index]);
    }
    await _persistData();
  }

  /// Update ticket status
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
    String? resolution,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    _tickets[index] = _tickets[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
      resolution: resolution,
    );

    if (!_ticketUpdateController.isClosed) {
      _ticketUpdateController.add(_tickets[index]);
    }
    await _persistData();
    _emitSummary();
  }

  // ========================================
  // NPS SURVEYS
  // ========================================

  /// Check if it's time to show an NPS survey
  bool shouldShowNpsSurvey({int sessionCount = 0}) {
    if (sessionCount < _npsMinSessionsBeforePrompt) return false;
    if (_lastNpsPrompt != null) {
      final daysSince = DateTime.now().difference(_lastNpsPrompt!).inDays;
      if (daysSince < _npsCooldownDays) return false;
    }
    return true;
  }

  /// Submit an NPS survey response
  Future<void> submitNpsResponse({
    required int score,
    String? reason,
  }) async {
    final response = NpsSurveyResponse(
      id: 'nps_${DateTime.now().millisecondsSinceEpoch}',
      score: score,
      reason: reason,
      timestamp: DateTime.now(),
    );

    _npsResponses.add(response);
    _lastNpsPrompt = DateTime.now();

    // If detractor, auto-create a support follow-up
    if (response.category == NpsCategory.detractor && reason != null) {
      await submitFeedback(
        type: FeedbackType.complaint,
        title: 'NPS Detractor Follow-up',
        description: 'NPS Score: $score/10. Reason: $reason',
        rating: (score / 2).round(),
        contactConsent: true,
      );
    }

    await _persistData();
    _emitSummary();
  }

  /// Calculate the current NPS score (-100 to +100)
  double get npsScore {
    if (_npsResponses.isEmpty) return 0.0;
    final promoters =
        _npsResponses.where((r) => r.category == NpsCategory.promoter).length;
    final detractors =
        _npsResponses.where((r) => r.category == NpsCategory.detractor).length;
    return ((promoters - detractors) / _npsResponses.length) * 100;
  }

  // ========================================
  // ANALYTICS
  // ========================================

  /// Get comprehensive feedback analytics summary
  FeedbackSummary getSummary() {
    final bugReports =
        _feedback.where((f) => f.type == FeedbackType.bugReport).length;
    final featureRequests =
        _feedback.where((f) => f.type == FeedbackType.featureRequest).length;
    final general = _feedback.length - bugReports - featureRequests;

    final rated = _feedback.where((f) => f.rating != null).toList();
    final avgRating = rated.isEmpty
        ? 0.0
        : rated.map((f) => f.rating!).reduce((a, b) => a + b) / rated.length;

    final openTickets =
        _tickets.where((t) => t.status == TicketStatus.open || t.status == TicketStatus.inProgress).length;
    final resolvedTickets =
        _tickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).length;

    // Average resolution time
    final resolved = _tickets.where(
        (t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed);
    final avgResolution = resolved.isEmpty
        ? 0.0
        : resolved
                .map((t) => t.updatedAt.difference(t.createdAt).inHours.toDouble())
                .reduce((a, b) => a + b) /
            resolved.length;

    final promoters =
        _npsResponses.where((r) => r.category == NpsCategory.promoter).length;
    final passives =
        _npsResponses.where((r) => r.category == NpsCategory.passive).length;
    final detractors =
        _npsResponses.where((r) => r.category == NpsCategory.detractor).length;

    // Tag frequency analysis
    final tagCounts = <String, int>{};
    for (final fb in _feedback) {
      for (final tag in fb.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    return FeedbackSummary(
      totalFeedback: _feedback.length,
      bugReports: bugReports,
      featureRequests: featureRequests,
      generalFeedback: general,
      averageRating: avgRating,
      openTickets: openTickets,
      resolvedTickets: resolvedTickets,
      npsScore: npsScore,
      promoters: promoters,
      passives: passives,
      detractors: detractors,
      avgResolutionTimeHours: avgResolution,
      tagCounts: tagCounts,
    );
  }

  // ========================================
  // DATA ACCESS
  // ========================================

  /// Get all feedback entries
  List<FeedbackEntry> getAllFeedback() => List.from(_feedback);

  /// Get feedback by type
  List<FeedbackEntry> getFeedbackByType(FeedbackType type) =>
      _feedback.where((f) => f.type == type).toList();

  /// Get all support tickets
  List<SupportTicket> getAllTickets() => List.from(_tickets);

  /// Get tickets by status
  List<SupportTicket> getTicketsByStatus(TicketStatus status) =>
      _tickets.where((t) => t.status == status).toList();

  /// Get a specific ticket by ID
  SupportTicket? getTicket(String id) {
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all NPS responses
  List<NpsSurveyResponse> getNpsResponses() => List.from(_npsResponses);

  // ========================================
  // PERSISTENCE
  // ========================================

  Future<void> _persistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final feedbackJson = _feedback
          .reversed
          .take(200)
          .map((f) => f.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('feedback_entries', jsonEncode(feedbackJson));

      final ticketsJson = _tickets
          .reversed
          .take(100)
          .map((t) => t.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('feedback_tickets', jsonEncode(ticketsJson));

      final npsJson = _npsResponses
          .reversed
          .take(100)
          .map((n) => n.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('feedback_nps', jsonEncode(npsJson));

      if (_lastNpsPrompt != null) {
        await prefs.setString(
            'feedback_last_nps', _lastNpsPrompt!.toIso8601String());
      }
    } catch (e) {
      debugPrint('FeedbackService: persist error — $e');
    }
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final feedbackStr = prefs.getString('feedback_entries');
      if (feedbackStr != null) {
        final list = jsonDecode(feedbackStr) as List;
        _feedback.addAll(
            list.map((j) => FeedbackEntry.fromJson(j as Map<String, dynamic>)));
      }

      final ticketsStr = prefs.getString('feedback_tickets');
      if (ticketsStr != null) {
        final list = jsonDecode(ticketsStr) as List;
        _tickets.addAll(
            list.map((j) => SupportTicket.fromJson(j as Map<String, dynamic>)));
      }

      final npsStr = prefs.getString('feedback_nps');
      if (npsStr != null) {
        final list = jsonDecode(npsStr) as List;
        _npsResponses.addAll(
            list.map((j) => NpsSurveyResponse.fromJson(j as Map<String, dynamic>)));
      }

      final lastNps = prefs.getString('feedback_last_nps');
      if (lastNps != null) {
        _lastNpsPrompt = DateTime.parse(lastNps);
      }
    } catch (e) {
      debugPrint('FeedbackService: load error — $e');
    }
  }

  void _emitSummary() {
    if (!_summaryController.isClosed) {
      _summaryController.add(getSummary());
    }
  }

  /// Clear all feedback data
  Future<void> clearAll() async {
    _feedback.clear();
    _tickets.clear();
    _npsResponses.clear();
    _lastNpsPrompt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('feedback_entries');
    await prefs.remove('feedback_tickets');
    await prefs.remove('feedback_nps');
    await prefs.remove('feedback_last_nps');
    _emitSummary();
  }

  /// Dispose resources
  void dispose() {
    _summaryController.close();
    _ticketUpdateController.close();
  }
}
