// ============================================================================
// MUSCLE POWER - Data Lifecycle Service Tests
// ============================================================================
//
// Coverage targets: data_lifecycle_service.dart
// Tests: consent management, retention enforcement, data export, erasure
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/services/data_lifecycle_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataLifecycleService singleton', () {
    test('returns same instance', () {
      expect(
        identical(DataLifecycleService(), DataLifecycleService()),
        isTrue,
      );
    });
  });

  group('Consent management', () {
    test('essential consent is always true', () async {
      final service = DataLifecycleService();
      expect(await service.hasConsent(ConsentCategory.essential), isTrue);
    });

    test('analytics consent defaults to false', () async {
      final service = DataLifecycleService();
      expect(await service.hasConsent(ConsentCategory.analytics), isFalse);
    });

    test('setConsent persists the value', () async {
      final service = DataLifecycleService();
      await service.setConsent(ConsentCategory.analytics, true);
      expect(await service.hasConsent(ConsentCategory.analytics), isTrue);

      await service.setConsent(ConsentCategory.analytics, false);
      expect(await service.hasConsent(ConsentCategory.analytics), isFalse);
    });

    test('essential consent cannot be revoked', () async {
      final service = DataLifecycleService();
      await service.setConsent(ConsentCategory.essential, false);
      expect(await service.hasConsent(ConsentCategory.essential), isTrue);
    });

    test('getAllConsents returns all categories', () async {
      final service = DataLifecycleService();
      final consents = await service.getAllConsents();
      expect(consents.keys, containsAll(ConsentCategory.values));
      expect(consents[ConsentCategory.essential], isTrue);
    });

    test('consent timestamp is recorded', () async {
      final service = DataLifecycleService();
      await service.setConsent(ConsentCategory.contact, true);

      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('consent_contact_at');
      expect(timestamp, isNotNull);
      // Should be a valid ISO-8601 date
      expect(() => DateTime.parse(timestamp!), returnsNormally);
    });
  });

  group('Retention constants', () {
    test('workout retention is 24 months (730 days)', () {
      expect(DataLifecycleService.workoutRetention.inDays, 730);
    });

    test('meal retention is 12 months (365 days)', () {
      expect(DataLifecycleService.mealRetention.inDays, 365);
    });

    test('feedback retention is 6 months (180 days)', () {
      expect(DataLifecycleService.feedbackRetention.inDays, 180);
    });

    test('metrics retention is 90 days', () {
      expect(DataLifecycleService.metricsRetention.inDays, 90);
    });

    test('inactive account threshold is 18 months (548 days)', () {
      expect(DataLifecycleService.inactiveAccountThreshold.inDays, 548);
    });
  });

  group('Data minimisation', () {
    test('minimise strips non-whitelisted fields', () {
      final service = DataLifecycleService();
      final input = {
        'email': 'test@test.com',
        'name': 'John',
        'secretField': 'should be stripped',
        'anotherField': 123,
      };
      final result = service.minimise(input, {'email', 'name'});
      expect(result.keys, containsAll(['email', 'name']));
      expect(result.containsKey('secretField'), isFalse);
      expect(result.containsKey('anotherField'), isFalse);
    });

    test('minimise keeps allowed fields', () {
      final service = DataLifecycleService();
      final result = service.minimise({'a': 1, 'b': 2}, {'a', 'b'});
      expect(result, {'a': 1, 'b': 2});
    });

    test('minimise handles empty input', () {
      final result = DataLifecycleService().minimise({}, {'a'});
      expect(result, isEmpty);
    });
  });

  group('Retention enforcement', () {
    test('enforceRetention runs without error', () async {
      final service = DataLifecycleService();
      final report = await service.enforceRetention();
      expect(report.totalPurged, greaterThanOrEqualTo(0));
      expect(report.ranAt, isNotNull);
    });

    test('RetentionReport toString includes totals', () {
      final report = RetentionReport(
        purgedProgress: 1,
        purgedNutrition: 2,
        purgedFeedback: 3,
        purgedMetrics: 4,
        ranAt: DateTime.now(),
      );
      expect(report.totalPurged, 10);
      expect(report.toString(), contains('total=10'));
    });
  });

  group('Data export', () {
    test('exportUserData returns valid GDPR bundle', () async {
      final service = DataLifecycleService();
      final data = await service.exportUserData();
      expect(data['format'], 'GDPR_PORTABLE_JSON_V1');
      expect(data['exportedAt'], isNotNull);
      expect(data.containsKey('user'), isTrue);
      expect(data.containsKey('consents'), isTrue);
    });

    test('exportUserDataAsJson returns valid JSON string', () async {
      final service = DataLifecycleService();
      final json = await service.exportUserDataAsJson();
      expect(json, isA<String>());
      expect(json, contains('GDPR_PORTABLE_JSON_V1'));
    });
  });

  group('Right to erasure', () {
    test('deleteAllUserData clears SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test_key', 'value');

      await DataLifecycleService().deleteAllUserData();

      final afterPrefs = await SharedPreferences.getInstance();
      expect(afterPrefs.getString('test_key'), isNull);
    });
  });
}
