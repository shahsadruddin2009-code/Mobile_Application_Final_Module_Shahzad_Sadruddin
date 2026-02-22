// ============================================================================
// MUSCLE POWER - Cache Manager Tests
// ============================================================================
//
// Coverage targets: cache_manager.dart
// Tests: put/get, TTL expiry, LRU eviction, size cap, stale eviction
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/services/cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final cache = CacheManager();
    await cache.clearAll();
  });

  group('CacheManager singleton', () {
    test('returns same instance', () {
      expect(identical(CacheManager(), CacheManager()), isTrue);
    });
  });

  group('Basic put / get', () {
    test('stores and retrieves a value', () async {
      final cache = CacheManager();
      await cache.put('key1', 'hello');
      final result = await cache.get<String>('key1');
      expect(result, 'hello');
    });

    test('returns null for missing key', () async {
      final result = await CacheManager().get<String>('nonexistent');
      expect(result, isNull);
    });

    test('stores complex types (maps, lists)', () async {
      final cache = CacheManager();
      await cache.put('map', {'a': 1, 'b': [2, 3]});
      final result = await cache.get<Map>('map');
      expect(result, isNotNull);
    });
  });

  group('TTL expiry', () {
    test('entry expires after TTL', () async {
      final cache = CacheManager();
      await cache.put('ttl_key', 'value',
          ttl: const Duration(milliseconds: 1));
      // Wait for TTL to expire
      await Future.delayed(const Duration(milliseconds: 50));
      final result = await cache.get<String>('ttl_key');
      expect(result, isNull);
    });

    test('entry is still valid before TTL', () async {
      final cache = CacheManager();
      await cache.put('ttl_key2', 'value', ttl: const Duration(hours: 1));
      final result = await cache.get<String>('ttl_key2');
      expect(result, 'value');
    });
  });

  group('LRU eviction', () {
    test('evicts oldest entry when memory capacity exceeded', () async {
      final cache = CacheManager();
      cache.maxMemoryEntries = 3;

      await cache.put('a', 1);
      await cache.put('b', 2);
      await cache.put('c', 3);
      // This should evict 'a'
      await cache.put('d', 4);

      expect(cache.memoryEntryCount, 3);
      // 'a' was evicted from memory (may still be in persistent)
    });
  });

  group('Remove and clear', () {
    test('remove deletes a single entry', () async {
      final cache = CacheManager();
      await cache.put('x', 'y');
      await cache.remove('x');
      final result = await cache.get<String>('x');
      expect(result, isNull);
    });

    test('clearAll empties the cache', () async {
      final cache = CacheManager();
      await cache.put('a', 1);
      await cache.put('b', 2);
      await cache.clearAll();
      expect(cache.memoryEntryCount, 0);
    });
  });

  group('evictStale', () {
    test('removes expired entries from persistent storage', () async {
      final cache = CacheManager();
      await cache.put('stale', 'old', ttl: const Duration(milliseconds: 1));
      await Future.delayed(const Duration(milliseconds: 50));
      final evicted = await cache.evictStale();
      expect(evicted, greaterThanOrEqualTo(1));
    });
  });

  group('Diagnostics', () {
    test('memoryEntryCount reflects stored items', () async {
      final cache = CacheManager();
      await cache.clearAll();
      expect(cache.memoryEntryCount, 0);
      await cache.put('k', 'v');
      expect(cache.memoryEntryCount, 1);
    });

    test('persistentSizeBytes returns a non-negative number', () async {
      final cache = CacheManager();
      await cache.put('size_test', 'data');
      final size = await cache.persistentSizeBytes();
      expect(size, greaterThanOrEqualTo(0));
    });
  });
}
