// ============================================================================
// MUSCLE POWER - Cache Manager
// ============================================================================
//
// File: cache_manager.dart
// Description: Centralised in-memory + persistent cache with TTL-based
//              eviction, size limits, and LRU replacement policy.
//
// Caching Strategy:
//   Layer 1 — In-memory LRU cache (fast, volatile)
//     • Max 200 entries by default.
//     • Eviction: Least-Recently-Used when capacity exceeded.
//     • Cleared on app restart.
//
//   Layer 2 — SharedPreferences (persistent, cross-platform)
//     • All cache entries serialised as JSON with metadata envelope.
//     • TTL per entry (default 1 hour).
//     • Stale entries evicted lazily on read or eagerly via [evictStale()].
//
// Eviction Policy:
//   1. TTL expiry — entries older than their TTL are evicted on access.
//   2. LRU — when the in-memory cache exceeds [maxMemoryEntries], the
//      least-recently-used entry is removed.
//   3. Size cap — total persistent cache payload is capped at
//      [maxPersistentBytes] (default 5 MB). Oldest entries are evicted
//      first when the cap is exceeded.
//   4. Manual — callers can call [remove()] or [clearAll()].
//
// Usage:
//   final cache = CacheManager();
//   await cache.put('exercises', exerciseListJson, ttl: Duration(hours: 4));
//   final hit = await cache.get<List>('exercises');
// ============================================================================

import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Metadata wrapper stored alongside each cached value.
class _CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration ttl;
  DateTime lastAccessedAt;

  _CacheEntry({
    required this.value,
    required this.ttl,
  })  : createdAt = DateTime.now(),
        lastAccessedAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  void touch() => lastAccessedAt = DateTime.now();
}

/// Centralised cache with in-memory LRU + persistent SharedPreferences layers.
///
/// Singleton — access via `CacheManager()`.
class CacheManager {
  // ======== singleton ========
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // ======== configuration ========

  /// Maximum number of entries kept in the in-memory LRU cache.
  int maxMemoryEntries = 200;

  /// Maximum approximate size (bytes) of serialised values in persistent
  /// storage.  Oldest entries are evicted when this is exceeded.
  int maxPersistentBytes = 5 * 1024 * 1024; // 5 MB

  /// Default TTL applied if none is specified in [put()].
  Duration defaultTtl = const Duration(hours: 1);

  // ======== internal storage ========
  final LinkedHashMap<String, _CacheEntry<dynamic>> _memory =
      LinkedHashMap<String, _CacheEntry<dynamic>>();

  static const String _persistPrefix = 'cache_';

  // ====================================================================
  // READ
  // ====================================================================

  /// Retrieve a cached value by [key].
  ///
  /// Checks in-memory first, then persistent storage. Returns `null` on
  /// miss or if the entry has expired (the stale entry is evicted).
  Future<T?> get<T>(String key) async {
    // L1 — in-memory
    final memEntry = _memory[key];
    if (memEntry != null) {
      if (memEntry.isExpired) {
        _memory.remove(key);
        await _removePersistent(key);
        return null;
      }
      memEntry.touch();
      // Move to end for LRU ordering
      _memory.remove(key);
      _memory[key] = memEntry;
      return memEntry.value as T;
    }

    // L2 — persistent
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_persistPrefix$key');
    if (raw == null) return null;

    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final createdAt = DateTime.parse(envelope['createdAt'] as String);
      final ttl = Duration(milliseconds: envelope['ttlMs'] as int);
      if (DateTime.now().difference(createdAt) > ttl) {
        await _removePersistent(key);
        return null;
      }

      final value = envelope['value'] as T;
      // Promote to L1
      _putMemory(key, value, ttl);
      return value;
    } catch (e) {
      debugPrint('CacheManager: corrupt entry for $key — $e');
      await _removePersistent(key);
      return null;
    }
  }

  // ====================================================================
  // WRITE
  // ====================================================================

  /// Store [value] under [key] in both memory and persistent layers.
  ///
  /// [ttl] overrides [defaultTtl] for this entry.
  Future<void> put<T>(String key, T value, {Duration? ttl}) async {
    final effectiveTtl = ttl ?? defaultTtl;

    // L1
    _putMemory(key, value, effectiveTtl);

    // L2
    try {
      final prefs = await SharedPreferences.getInstance();
      final envelope = jsonEncode({
        'value': value,
        'createdAt': DateTime.now().toIso8601String(),
        'ttlMs': effectiveTtl.inMilliseconds,
      });
      await prefs.setString('$_persistPrefix$key', envelope);
      await _enforceSizeCap(prefs);
    } catch (e) {
      debugPrint('CacheManager: persist error for $key — $e');
    }
  }

  // ====================================================================
  // EVICTION
  // ====================================================================

  /// Remove a single entry from both layers.
  Future<void> remove(String key) async {
    _memory.remove(key);
    await _removePersistent(key);
  }

  /// Remove ALL cache entries from both layers.
  Future<void> clearAll() async {
    _memory.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith(_persistPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    debugPrint('CacheManager: cleared ${keys.length} persistent entries');
  }

  /// Eagerly remove all stale (TTL-expired) entries from persistent storage.
  Future<int> evictStale() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith(_persistPrefix)).toList();
    int evicted = 0;

    for (final k in keys) {
      try {
        final raw = prefs.getString(k);
        if (raw == null) continue;
        final envelope = jsonDecode(raw) as Map<String, dynamic>;
        final createdAt = DateTime.parse(envelope['createdAt'] as String);
        final ttl = Duration(milliseconds: envelope['ttlMs'] as int);
        if (DateTime.now().difference(createdAt) > ttl) {
          await prefs.remove(k);
          evicted++;
        }
      } catch (_) {
        await prefs.remove(k);
        evicted++;
      }
    }

    // Also sweep in-memory
    _memory.removeWhere((_, entry) => entry.isExpired);

    debugPrint('CacheManager: evicted $evicted stale entries');
    return evicted;
  }

  // ====================================================================
  // DIAGNOSTICS
  // ====================================================================

  /// Current number of in-memory entries (for testing / monitoring).
  int get memoryEntryCount => _memory.length;

  /// Approximate total bytes used in persistent cache.
  Future<int> persistentSizeBytes() async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;
    for (final k in prefs.getKeys()) {
      if (k.startsWith(_persistPrefix)) {
        total += (prefs.getString(k)?.length ?? 0) * 2; // UTF-16
      }
    }
    return total;
  }

  // ====================================================================
  // INTERNALS
  // ====================================================================

  void _putMemory<T>(String key, T value, Duration ttl) {
    // Evict LRU if at capacity
    while (_memory.length >= maxMemoryEntries) {
      final lruKey = _memory.keys.first;
      _memory.remove(lruKey);
    }
    _memory[key] = _CacheEntry<T>(value: value, ttl: ttl);
  }

  Future<void> _removePersistent(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_persistPrefix$key');
  }

  /// Evict oldest persistent entries until size is under [maxPersistentBytes].
  Future<void> _enforceSizeCap(SharedPreferences prefs) async {
    final cacheKeys =
        prefs.getKeys().where((k) => k.startsWith(_persistPrefix)).toList();

    // Estimate total size
    int totalBytes = 0;
    final entries = <MapEntry<String, int>>[];
    for (final k in cacheKeys) {
      final raw = prefs.getString(k);
      final bytes = (raw?.length ?? 0) * 2;
      totalBytes += bytes;
      entries.add(MapEntry(k, bytes));
    }

    if (totalBytes <= maxPersistentBytes) return;

    // Sort by creation time ascending (oldest first) — parse createdAt
    entries.sort((a, b) {
      try {
        final aRaw = prefs.getString(a.key);
        final bRaw = prefs.getString(b.key);
        if (aRaw == null || bRaw == null) return 0;
        final aTime = DateTime.parse(
            (jsonDecode(aRaw) as Map<String, dynamic>)['createdAt'] as String);
        final bTime = DateTime.parse(
            (jsonDecode(bRaw) as Map<String, dynamic>)['createdAt'] as String);
        return aTime.compareTo(bTime);
      } catch (_) {
        return 0;
      }
    });

    // Evict oldest until under cap
    for (final entry in entries) {
      if (totalBytes <= maxPersistentBytes) break;
      await prefs.remove(entry.key);
      totalBytes -= entry.value;
      debugPrint('CacheManager: size-evicted ${entry.key}');
    }
  }
}
