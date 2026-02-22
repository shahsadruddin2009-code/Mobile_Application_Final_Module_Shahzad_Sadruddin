// ============================================================================
// MUSCLE POWER - Connectivity Service Tests
// ============================================================================
//
// Coverage targets: connectivity_service.dart
// Tests: singleton, init, offline state, stream behaviour
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConnectivityService singleton', () {
    test('returns same instance', () {
      expect(identical(ConnectivityService(), ConnectivityService()), isTrue);
    });
  });

  group('Initialisation', () {
    test('init completes without error', () async {
      final service = ConnectivityService();
      // Should complete gracefully even if connectivity_plus is stubbed
      await expectLater(service.init(), completes);
    });

    test('isOffline defaults to false before init', () {
      // On test platform, we default to "online"
      expect(ConnectivityService().isOffline, isFalse);
    });

    test('repeated init calls are no-ops', () async {
      final service = ConnectivityService();
      await service.init();
      await service.init(); // should not throw
    });
  });

  group('Connect stream', () {
    test('connectivityStream is a broadcast stream', () {
      final stream = ConnectivityService().connectivityStream;
      expect(stream.isBroadcast, isTrue);
    });
  });
}
