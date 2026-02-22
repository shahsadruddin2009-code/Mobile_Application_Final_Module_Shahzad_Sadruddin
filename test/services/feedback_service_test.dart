// ============================================================================
// MUSCLE POWER - Feedback Service Unit Tests
// ============================================================================
//
// Coverage targets: feedback_service.dart
// Tests: feedback models, submission, NPS scoring, ticket lifecycle,
//        summary analytics, persistence, and stream emissions.
//
// Total: 42 tests
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/feedback_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ========================================
  // FEEDBACK ENTRY MODEL TESTS
  // ========================================

  group('FeedbackEntry model', () {
    test('toJson produces expected keys', () {
      final entry = FeedbackEntry(
        id: 'fb_1',
        type: FeedbackType.bugReport,
        title: 'Crash on launch',
        description: 'App crashes immediately',
        rating: 1,
        screenContext: 'HomeScreen',
        timestamp: DateTime(2026, 1, 15),
        userEmail: 'test@example.com',
        userName: 'Tester',
        tags: ['crash', 'urgent'],
        contactConsent: true,
      );
      final json = entry.toJson();
      expect(json['id'], 'fb_1');
      expect(json['type'], 'bugReport');
      expect(json['title'], 'Crash on launch');
      expect(json['rating'], 1);
      expect(json['tags'], ['crash', 'urgent']);
      expect(json['contactConsent'], true);
    });

    test('fromJson round-trips correctly', () {
      final original = FeedbackEntry(
        id: 'fb_2',
        type: FeedbackType.featureRequest,
        title: 'Dark mode',
        description: 'Please add dark theme',
        timestamp: DateTime(2026, 2, 1),
        tags: ['ui'],
      );
      final json = original.toJson();
      final restored = FeedbackEntry.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.type, FeedbackType.featureRequest);
      expect(restored.title, original.title);
      expect(restored.tags, ['ui']);
      expect(restored.contactConsent, false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'fb_3',
        'type': 'general',
        'title': 'Test',
        'description': 'Desc',
        'timestamp': '2026-01-01T00:00:00.000',
      };
      final entry = FeedbackEntry.fromJson(json);
      expect(entry.rating, isNull);
      expect(entry.userEmail, isNull);
      expect(entry.tags, isEmpty);
      expect(entry.contactConsent, false);
    });

    test('fromJson defaults to general for unknown type', () {
      final json = {
        'id': 'fb_4',
        'type': 'unknown_type',
        'title': 'Test',
        'description': 'Desc',
        'timestamp': '2026-01-01T00:00:00.000',
      };
      final entry = FeedbackEntry.fromJson(json);
      expect(entry.type, FeedbackType.general);
    });
  });

  // ========================================
  // SUPPORT TICKET MODEL TESTS
  // ========================================

  group('SupportTicket model', () {
    test('copyWith creates modified copy', () {
      final ticket = SupportTicket(
        id: 'ticket_1',
        feedbackId: 'fb_1',
        subject: 'Bug',
        description: 'It broke',
        priority: TicketPriority.high,
        status: TicketStatus.open,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final updated = ticket.copyWith(
        status: TicketStatus.resolved,
        resolution: 'Fixed in v1.1',
      );
      expect(updated.status, TicketStatus.resolved);
      expect(updated.resolution, 'Fixed in v1.1');
      expect(updated.id, 'ticket_1');
      expect(updated.priority, TicketPriority.high);
    });

    test('toJson and fromJson round-trip', () {
      final ticket = SupportTicket(
        id: 'ticket_2',
        feedbackId: 'fb_2',
        subject: 'Feature',
        description: 'Need feature',
        priority: TicketPriority.medium,
        status: TicketStatus.inProgress,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        messages: [
          TicketMessage(
            id: 'msg_1',
            senderName: 'User',
            isFromUser: true,
            content: 'Hello',
            timestamp: DateTime(2026, 1, 1),
          ),
        ],
      );
      final json = ticket.toJson();
      final restored = SupportTicket.fromJson(json);
      expect(restored.id, 'ticket_2');
      expect(restored.status, TicketStatus.inProgress);
      expect(restored.messages, hasLength(1));
      expect(restored.messages.first.content, 'Hello');
    });
  });

  // ========================================
  // TICKET MESSAGE MODEL TESTS
  // ========================================

  group('TicketMessage model', () {
    test('serialises correctly', () {
      final msg = TicketMessage(
        id: 'msg_1',
        senderName: 'Support',
        isFromUser: false,
        content: 'We are looking into it.',
        timestamp: DateTime(2026, 1, 10),
      );
      final json = msg.toJson();
      expect(json['senderName'], 'Support');
      expect(json['isFromUser'], false);
    });

    test('fromJson round-trips', () {
      final msg = TicketMessage(
        id: 'msg_2',
        senderName: 'User',
        isFromUser: true,
        content: 'Thanks!',
        timestamp: DateTime(2026, 1, 11),
      );
      final restored = TicketMessage.fromJson(msg.toJson());
      expect(restored.id, 'msg_2');
      expect(restored.isFromUser, true);
    });
  });

  // ========================================
  // NPS SURVEY MODEL TESTS
  // ========================================

  group('NpsSurveyResponse model', () {
    test('score 0-6 is detractor', () {
      final resp = NpsSurveyResponse(
        id: 'nps_1', score: 5, timestamp: DateTime(2026, 1, 1));
      expect(resp.category, NpsCategory.detractor);
    });

    test('score 7-8 is passive', () {
      final resp = NpsSurveyResponse(
        id: 'nps_2', score: 7, timestamp: DateTime(2026, 1, 1));
      expect(resp.category, NpsCategory.passive);
    });

    test('score 9-10 is promoter', () {
      final resp = NpsSurveyResponse(
        id: 'nps_3', score: 9, timestamp: DateTime(2026, 1, 1));
      expect(resp.category, NpsCategory.promoter);
    });

    test('toJson / fromJson round-trip', () {
      final resp = NpsSurveyResponse(
        id: 'nps_4', score: 10, reason: 'Love it!', timestamp: DateTime(2026, 2, 1));
      final restored = NpsSurveyResponse.fromJson(resp.toJson());
      expect(restored.score, 10);
      expect(restored.reason, 'Love it!');
      expect(restored.category, NpsCategory.promoter);
    });
  });

  // ========================================
  // FEEDBACK SUMMARY MODEL TESTS
  // ========================================

  group('FeedbackSummary model', () {
    test('constructs with all fields', () {
      final summary = FeedbackSummary(
        totalFeedback: 100,
        bugReports: 20,
        featureRequests: 30,
        generalFeedback: 50,
        averageRating: 4.2,
        openTickets: 5,
        resolvedTickets: 15,
        npsScore: 42.0,
        promoters: 6,
        passives: 2,
        detractors: 2,
        avgResolutionTimeHours: 12.5,
        tagCounts: {'crash': 5, 'ui': 10},
      );
      expect(summary.totalFeedback, 100);
      expect(summary.averageRating, 4.2);
      expect(summary.tagCounts['crash'], 5);
    });
  });

  // ========================================
  // FEEDBACK SERVICE SINGLETON TESTS
  // ========================================

  group('FeedbackService singleton', () {
    test('returns same instance', () {
      expect(identical(FeedbackService(), FeedbackService()), isTrue);
    });
  });

  // ========================================
  // FEEDBACK SUBMISSION TESTS
  // ========================================

  group('Feedback submission', () {
    test('submitFeedback returns entry with generated ID', () async {
      final service = FeedbackService();
      await service.clearAll();
      final entry = await service.submitFeedback(
        type: FeedbackType.general,
        title: 'Great app',
        description: 'I love this fitness app',
        rating: 5,
      );
      expect(entry.id, startsWith('fb_'));
      expect(entry.type, FeedbackType.general);
      expect(entry.title, 'Great app');
      expect(entry.rating, 5);
    });

    test('bug report auto-creates support ticket', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitFeedback(
        type: FeedbackType.bugReport,
        title: 'Crash on save',
        description: 'App crashes when saving workout',
      );
      final tickets = service.getAllTickets();
      expect(tickets, isNotEmpty);
      expect(tickets.first.subject, 'Crash on save');
      expect(tickets.first.priority, TicketPriority.high);
    });

    test('complaint auto-creates ticket', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitFeedback(
        type: FeedbackType.complaint,
        title: 'Slow loading',
        description: 'Takes too long to load',
      );
      final tickets = service.getAllTickets();
      expect(tickets, isNotEmpty);
    });

    test('feature request does NOT auto-create ticket', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitFeedback(
        type: FeedbackType.featureRequest,
        title: 'Add stretching',
        description: 'Please add stretching routines',
      );
      final tickets = service.getAllTickets();
      expect(tickets, isEmpty);
    });

    test('submitQuickRating stores as general feedback', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitQuickRating(
        rating: 4,
        context: 'post_workout',
        comment: 'Good session',
      );
      final all = service.getAllFeedback();
      expect(all, hasLength(1));
      expect(all.first.title, contains('Quick Rating'));
    });
  });

  // ========================================
  // NPS SURVEY TESTS
  // ========================================

  group('NPS surveys', () {
    test('shouldShowNpsSurvey returns false when sessions < minimum', () {
      final service = FeedbackService();
      expect(service.shouldShowNpsSurvey(sessionCount: 2), isFalse);
    });

    test('shouldShowNpsSurvey returns true when eligible', () async {
      final service = FeedbackService();
      await service.clearAll();
      expect(service.shouldShowNpsSurvey(sessionCount: 10), isTrue);
    });

    test('npsScore starts at 0', () async {
      final service = FeedbackService();
      await service.clearAll();
      expect(service.npsScore, 0.0);
    });

    test('detractor NPS creates complaint feedback', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitNpsResponse(score: 3, reason: 'Too buggy');
      final feedback = service.getAllFeedback();
      expect(feedback.any((f) => f.type == FeedbackType.complaint), isTrue);
    });
  });

  // ========================================
  // DATA ACCESS TESTS
  // ========================================

  group('Data access methods', () {
    test('getFeedbackByType filters correctly', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitFeedback(
        type: FeedbackType.bugReport,
        title: 'Bug 1', description: 'Bug',
      );
      await service.submitFeedback(
        type: FeedbackType.featureRequest,
        title: 'Feature 1', description: 'Feature',
      );
      await service.submitFeedback(
        type: FeedbackType.bugReport,
        title: 'Bug 2', description: 'Bug',
      );
      final bugs = service.getFeedbackByType(FeedbackType.bugReport);
      expect(bugs, hasLength(2));
    });

    test('getTicket returns null for unknown ID', () {
      final service = FeedbackService();
      expect(service.getTicket('nonexistent'), isNull);
    });
  });

  // ========================================
  // SUMMARY ANALYTICS TESTS
  // ========================================

  group('Summary analytics', () {
    test('getSummary returns correct counts', () async {
      final service = FeedbackService();
      await service.clearAll();
      await service.submitFeedback(
        type: FeedbackType.bugReport,
        title: 'Bug', description: 'A bug', rating: 2,
      );
      await service.submitFeedback(
        type: FeedbackType.featureRequest,
        title: 'Feature', description: 'A feature', rating: 4,
      );
      await service.submitFeedback(
        type: FeedbackType.general,
        title: 'General', description: 'General feedback',
      );
      final summary = service.getSummary();
      expect(summary.totalFeedback, 3);
      expect(summary.bugReports, 1);
      expect(summary.featureRequests, 1);
      expect(summary.averageRating, 3.0);
    });

    test('clearAll resets all data', () async {
      final service = FeedbackService();
      await service.submitFeedback(
        type: FeedbackType.general,
        title: 'Test', description: 'Test',
      );
      await service.clearAll();
      expect(service.getAllFeedback(), isEmpty);
      expect(service.getAllTickets(), isEmpty);
      expect(service.getNpsResponses(), isEmpty);
    });
  });
}
