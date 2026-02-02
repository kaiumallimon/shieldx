// =====================================================
// ShieldX Brandfetch Icon Service
// File: brandfetch_service.dart
// =====================================================
// Description: Service for fetching and caching brand icons from
// Brandfetch API with local caching to minimize API costs.
// =====================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// =====================================================
// SERVICE: BrandfetchService
// =====================================================

class BrandfetchService {
  final http.Client _httpClient;
  final SupabaseClient _supabase;
  final String _apiKey;

  static const String _brandfetchBaseUrl = 'https://api.brandfetch.io/v2';
  static const String _iconCacheTable = 'icon_cache';
  static const Duration _cacheExpiration = Duration(days: 30);

  BrandfetchService({
    required http.Client httpClient,
    required SupabaseClient supabase,
    required String apiKey,
  })  : _httpClient = httpClient,
        _supabase = supabase,
        _apiKey = apiKey;

  // =====================================================
  // PUBLIC: Get Icon for Domain
  // =====================================================

  /// Retrieves brand icon for a domain with caching
  /// 1. Check local cache first (database)
  /// 2. If expired or not found, fetch from Brandfetch API
  /// 3. Store in cache for future use
  Future<BrandIcon?> getIconForDomain(String url) async {
    final domain = _extractDomain(url);
    if (domain == null) return null;

    try {
      // Check cache first
      final cachedIcon = await _getCachedIcon(domain);
      if (cachedIcon != null && !_isCacheExpired(cachedIcon)) {
        await _updateCacheAccessTime(domain);
        return cachedIcon;
      }

      // Fetch from API if not cached or expired
      final icon = await _fetchIconFromAPI(domain);
      if (icon != null) {
        await _cacheIcon(domain, icon);
      }

      return icon;
    } catch (e) {
      // Fallback: return cached icon even if expired, or null
      final cachedIcon = await _getCachedIcon(domain);
      return cachedIcon;
    }
  }

  // =====================================================
  // PRIVATE: Cache Management
  // =====================================================

  /// Retrieves icon from local cache
  Future<BrandIcon?> _getCachedIcon(String domain) async {
    try {
      final response = await _supabase
          .from(_iconCacheTable)
          .select()
          .eq('domain', domain)
          .maybeSingle();

      if (response == null) return null;

      return BrandIcon.fromCacheJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Checks if cache entry is expired
  bool _isCacheExpired(BrandIcon icon) {
    if (icon.expiresAt == null) return true;
    return DateTime.now().isAfter(icon.expiresAt!);
  }

  /// Updates last access time for cache entry (LRU tracking)
  Future<void> _updateCacheAccessTime(String domain) async {
    try {
      await _supabase.from(_iconCacheTable).update({
        'last_accessed_at': DateTime.now().toIso8601String(),
      }).eq('domain', domain);
    } catch (e) {
      // Ignore errors (non-critical)
    }
  }

  /// Caches icon in database
  Future<void> _cacheIcon(String domain, BrandIcon icon) async {
    try {
      final data = {
        'domain': domain,
        'icon_url': icon.iconUrl,
        'icon_type': icon.iconType,
        'brand_name': icon.brandName,
        'brand_color': icon.brandColor,
        'fetched_at': DateTime.now().toIso8601String(),
        'expires_at':
            DateTime.now().add(_cacheExpiration).toIso8601String(),
        'fetch_count': 1,
        'last_accessed_at': DateTime.now().toIso8601String(),
        'raw_response': icon.rawResponse,
      };

      // Upsert (insert or update if exists)
      await _supabase.from(_iconCacheTable).upsert(data);
    } catch (e) {
      // Ignore cache write errors (non-critical)
    }
  }

  // =====================================================
  // PRIVATE: Brandfetch API Integration
  // =====================================================

  /// Fetches icon from Brandfetch API
  Future<BrandIcon?> _fetchIconFromAPI(String domain) async {
    try {
      final url = Uri.parse('$_brandfetchBaseUrl/brands/$domain');
      final response = await _httpClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseBrandfetchResponse(json);
      } else if (response.statusCode == 404) {
        // Brand not found - cache null result to avoid repeated API calls
        return null;
      } else {
        throw BrandfetchException(
          'API request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw BrandfetchException('Failed to fetch icon from API: $e');
    }
  }

  /// Parses Brandfetch API response
  BrandIcon? _parseBrandfetchResponse(Map<String, dynamic> json) {
    try {
      // Extract logo from response
      final logos = json['logos'] as List?;
      if (logos == null || logos.isEmpty) return null;

      final logo = logos.first as Map<String, dynamic>;
      final formats = logo['formats'] as List?;
      if (formats == null || formats.isEmpty) return null;

      // Prefer SVG, fallback to PNG
      final format = formats.firstWhere(
        (f) => f['format'] == 'svg',
        orElse: () => formats.first,
      ) as Map<String, dynamic>;

      final iconUrl = format['src'] as String?;
      if (iconUrl == null) return null;

      // Extract brand info
      final brandName = json['name'] as String?;
      final brandColor = _extractBrandColor(json);

      return BrandIcon(
        iconUrl: iconUrl,
        iconType: format['format'] as String? ?? 'unknown',
        brandName: brandName,
        brandColor: brandColor,
        rawResponse: json,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extracts primary brand color from response
  String? _extractBrandColor(Map<String, dynamic> json) {
    try {
      final colors = json['colors'] as List?;
      if (colors == null || colors.isEmpty) return null;

      final primaryColor = colors.first as Map<String, dynamic>;
      return primaryColor['hex'] as String?;
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // UTILITIES: Domain Extraction
  // =====================================================

  /// Extracts domain from URL
  String? _extractDomain(String url) {
    try {
      // Add scheme if missing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // MAINTENANCE: Cache Cleanup
  // =====================================================

  /// Cleans up expired cache entries
  Future<void> cleanupExpiredCache() async {
    try {
      await _supabase
          .from(_iconCacheTable)
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Cleans up least recently used cache entries (keep top 10k)
  Future<void> cleanupLRUCache({int maxEntries = 10000}) async {
    try {
      // Get all domains and count them
      final allEntries = await _supabase
          .from(_iconCacheTable)
          .select('domain');

      final count = (allEntries as List).length;
      if (count <= maxEntries) return;

      // Delete least recently accessed entries
      final toDelete = count - maxEntries;
      final oldestEntries = await _supabase
          .from(_iconCacheTable)
          .select('domain')
          .order('last_accessed_at', ascending: true)
          .limit(toDelete);

      final domains = (oldestEntries as List)
          .map((e) => e['domain'] as String)
          .toList();

      if (domains.isNotEmpty) {
        await _supabase.from(_iconCacheTable).delete().inFilter('domain', domains);
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}

// =====================================================
// MODEL: BrandIcon
// =====================================================

class BrandIcon {
  final String iconUrl;
  final String iconType;
  final String? brandName;
  final String? brandColor;
  final Map<String, dynamic>? rawResponse;
  final DateTime? expiresAt;

  BrandIcon({
    required this.iconUrl,
    required this.iconType,
    this.brandName,
    this.brandColor,
    this.rawResponse,
    this.expiresAt,
  });

  factory BrandIcon.fromCacheJson(Map<String, dynamic> json) {
    return BrandIcon(
      iconUrl: json['icon_url'] as String,
      iconType: json['icon_type'] as String,
      brandName: json['brand_name'] as String?,
      brandColor: json['brand_color'] as String?,
      rawResponse: json['raw_response'] as Map<String, dynamic>?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'icon_url': iconUrl,
        'icon_type': iconType,
        'brand_name': brandName,
        'brand_color': brandColor,
        'raw_response': rawResponse,
        'expires_at': expiresAt?.toIso8601String(),
      };
}

// =====================================================
// EXCEPTION: BrandfetchException
// =====================================================

class BrandfetchException implements Exception {
  final String message;

  BrandfetchException(this.message);

  @override
  String toString() => 'BrandfetchException: $message';
}

// =====================================================
// PROVIDER: Brandfetch Service Factory
// =====================================================

class BrandfetchServiceProvider {
  static BrandfetchService create({
    required SupabaseClient supabase,
    required String apiKey,
  }) {
    return BrandfetchService(
      httpClient: http.Client(),
      supabase: supabase,
      apiKey: apiKey,
    );
  }
}
