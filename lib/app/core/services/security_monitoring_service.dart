// =====================================================
// ShieldX Security Monitoring Service
// File: security_monitoring_service.dart
// =====================================================
// Description: Client-side security monitoring for password health,
// breach detection (HIBP), and automated alert generation.
// Server remains blind to actual password content.
// =====================================================

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/vault_item_model.dart';
import '../../data/models/security_alert_model.dart';
import './encryption_service.dart';

// =====================================================
// SERVICE: SecurityMonitoringService
// =====================================================

class SecurityMonitoringService {
  final http.Client _httpClient;
  final SupabaseClient _supabase;

  static const String _hibpApiUrl = 'https://api.pwnedpasswords.com/range';
  static const String _breachCacheTable = 'password_breach_cache';
  static const String _securityAlertsTable = 'security_alerts';
  static const Duration _breachCacheExpiration = Duration(days: 7);

  SecurityMonitoringService({
    required http.Client httpClient,
    required SupabaseClient supabase,
  })  : _httpClient = httpClient,
        _supabase = supabase;

  // =====================================================
  // PASSWORD HEALTH: Strength Analysis
  // =====================================================

  /// Analyzes password strength (client-side only)
  Future<PasswordHealthStatus> analyzePasswordHealth({
    required String password,
    required List<String> allPasswords,
  }) async {
    // Check if password is empty
    if (password.isEmpty) return PasswordHealthStatus.unknown;

    // 1. Check strength
    final strength = EncryptionService.analyzePasswordStrength(password);
    if (strength == PasswordHealthStatus.weak) {
      return PasswordHealthStatus.weak;
    }

    // 2. Check for reuse
    final isReused = _checkPasswordReuse(password, allPasswords);
    if (isReused) {
      return PasswordHealthStatus.reused;
    }

    // 3. Check for breach (HIBP)
    final isBreached = await checkPasswordBreach(password);
    if (isBreached) {
      return PasswordHealthStatus.breached;
    }

    // Password is strong
    return PasswordHealthStatus.strong;
  }

  /// Checks if password is reused across multiple vault items
  bool _checkPasswordReuse(String password, List<String> allPasswords) {
    int count = 0;
    for (final pwd in allPasswords) {
      if (pwd == password) {
        count++;
        if (count > 1) return true;
      }
    }
    return false;
  }

  // =====================================================
  // BREACH DETECTION: Have I Been Pwned (k-anonymity)
  // =====================================================

  /// Checks if password has been breached using HIBP API
  /// Uses k-anonymity model (only sends first 5 chars of hash)
  Future<bool> checkPasswordBreach(String password) async {
    try {
      // Compute SHA-1 hash
      final hashPrefix = EncryptionService.computePasswordHashPrefix(password);
      final hashSuffix = EncryptionService.computePasswordHashSuffix(password);

      // Check local cache first
      final cachedResult = await _getCachedBreachStatus(hashPrefix);
      if (cachedResult != null) {
        return _matchHashSuffix(cachedResult, hashSuffix);
      }

      // Fetch from HIBP API
      final breachData = await _fetchBreachDataFromAPI(hashPrefix);
      if (breachData != null) {
        await _cacheBreachData(hashPrefix, breachData);
        return _matchHashSuffix(breachData, hashSuffix);
      }

      return false;
    } catch (e) {
      // On error, assume not breached (fail-safe)
      return false;
    }
  }

  /// Retrieves cached breach data from database
  Future<String?> _getCachedBreachStatus(String hashPrefix) async {
    try {
      final response = await _supabase
          .from(_breachCacheTable)
          .select()
          .eq('hash_prefix', hashPrefix)
          .maybeSingle();

      if (response == null) return null;

      // Check if cache is expired
      final expiresAt = DateTime.parse(response['expires_at'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        return null; // Expired, fetch fresh data
      }

      // Return cached breach data (if any)
      return response['breach_data'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Fetches breach data from HIBP API (k-anonymity)
  Future<String?> _fetchBreachDataFromAPI(String hashPrefix) async {
    try {
      final url = Uri.parse('$_hibpApiUrl/$hashPrefix');
      final response = await _httpClient.get(
        url,
        headers: {
          'User-Agent': 'ShieldX-Password-Manager',
          'Add-Padding': 'true', // Enhanced privacy
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 404) {
        return ''; // No breaches found
      } else {
        throw SecurityMonitoringException(
          'HIBP API request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw SecurityMonitoringException('Failed to fetch breach data: $e');
    }
  }

  /// Caches breach data in database
  Future<void> _cacheBreachData(String hashPrefix, String breachData) async {
    try {
      final data = {
        'hash_prefix': hashPrefix,
        'breach_data': breachData,
        'last_checked_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now()
            .add(_breachCacheExpiration)
            .toIso8601String(),
      };

      await _supabase.from(_breachCacheTable).upsert(data);
    } catch (e) {
      // Ignore cache write errors (non-critical)
    }
  }

  /// Matches hash suffix against breach data
  bool _matchHashSuffix(String breachData, String hashSuffix) {
    if (breachData.isEmpty) return false;

    // HIBP response format: "SUFFIX:COUNT\r\n"
    final lines = breachData.split('\n');
    for (final line in lines) {
      final parts = line.trim().split(':');
      if (parts.isNotEmpty && parts[0] == hashSuffix) {
        return true; // Hash found in breaches
      }
    }
    return false;
  }

  // =====================================================
  // ALERT GENERATION: Automated Security Alerts
  // =====================================================

  /// Scans all vault items and generates security alerts
  Future<List<SecurityAlert>> scanVaultForIssues({
    required List<VaultItemWithDecrypted> decryptedItems,
  }) async {
    final alerts = <SecurityAlert>[];

    // Track passwords for reuse detection
    final passwordMap = <String, List<String>>{};
    for (final item in decryptedItems) {
      final password = item.decryptedPayload.password;
      if (password != null && password.isNotEmpty) {
        passwordMap.putIfAbsent(password, () => []).add(item.vaultItem.id);
      }
    }

    // Scan each item
    for (final item in decryptedItems) {
      final password = item.decryptedPayload.password;
      if (password == null || password.isEmpty) continue;

      // 1. Check weak password
      final strength = EncryptionService.analyzePasswordStrength(password);
      if (strength == PasswordHealthStatus.weak) {
        alerts.add(await _createWeakPasswordAlert(item.vaultItem));
      }

      // 2. Check reused password
      final reusedCount = passwordMap[password]?.length ?? 0;
      if (reusedCount > 1) {
        alerts.add(await _createReusedPasswordAlert(
          item.vaultItem,
          reusedCount,
        ));
      }

      // 3. Check breached password
      final isBreached = await checkPasswordBreach(password);
      if (isBreached) {
        alerts.add(await _createBreachedPasswordAlert(item.vaultItem));
      }

      // 4. Check password age (unchanged for 90+ days)
      final daysSinceUpdate =
          DateTime.now().difference(item.vaultItem.updatedAt).inDays;
      if (daysSinceUpdate > 90) {
        alerts.add(await _createPasswordUnchangedAlert(
          item.vaultItem,
          daysSinceUpdate,
        ));
      }

      // 5. Check missing 2FA
      if (item.decryptedPayload.totpSecret == null) {
        alerts.add(await _createMissing2FAAlert(item.vaultItem));
      }
    }

    return alerts;
  }

  /// Creates weak password alert
  Future<SecurityAlert> _createWeakPasswordAlert(VaultItem item) async {
    final dto = CreateSecurityAlertDto(
      vaultItemId: item.id,
      alertType: AlertType.weakPassword,
      severity: AlertSeverity.warning,
      title: 'Weak Password Detected',
      message: '${item.title} uses a weak password that could be easily guessed.',
      recommendation: 'Update to a stronger password with at least 12 characters, including uppercase, lowercase, numbers, and symbols.',
    );

    return _createAlert(dto);
  }

  /// Creates reused password alert
  Future<SecurityAlert> _createReusedPasswordAlert(
    VaultItem item,
    int reusedCount,
  ) async {
    final dto = CreateSecurityAlertDto(
      vaultItemId: item.id,
      alertType: AlertType.reusedPassword,
      severity: AlertSeverity.critical,
      title: 'Password Reused',
      message: '${item.title} shares a password with ${reusedCount - 1} other item(s). If one account is compromised, all accounts with this password are at risk.',
      recommendation: 'Use unique passwords for each account to prevent credential stuffing attacks.',
      metadata: {'reused_count': reusedCount},
    );

    return _createAlert(dto);
  }

  /// Creates breached password alert
  Future<SecurityAlert> _createBreachedPasswordAlert(VaultItem item) async {
    final dto = CreateSecurityAlertDto(
      vaultItemId: item.id,
      alertType: AlertType.breachedPassword,
      severity: AlertSeverity.critical,
      title: 'Password Found in Data Breach',
      message: '${item.title} uses a password that has been exposed in a known data breach. Change it immediately.',
      recommendation: 'Create a new, unique password and enable two-factor authentication if available.',
      metadata: {'breach_source': 'Have I Been Pwned'},
    );

    return _createAlert(dto);
  }

  /// Creates password unchanged alert
  Future<SecurityAlert> _createPasswordUnchangedAlert(
    VaultItem item,
    int daysSinceUpdate,
  ) async {
    final dto = CreateSecurityAlertDto(
      vaultItemId: item.id,
      alertType: AlertType.passwordUnchangedLong,
      severity: AlertSeverity.info,
      title: 'Password Not Updated Recently',
      message: '${item.title} password hasn\'t been changed in $daysSinceUpdate days.',
      recommendation: 'Consider updating your password regularly (every 90-180 days) for better security.',
      metadata: {'days_since_update': daysSinceUpdate},
    );

    return _createAlert(dto);
  }

  /// Creates missing 2FA alert
  Future<SecurityAlert> _createMissing2FAAlert(VaultItem item) async {
    final dto = CreateSecurityAlertDto(
      vaultItemId: item.id,
      alertType: AlertType.missing2fa,
      severity: AlertSeverity.warning,
      title: 'Two-Factor Authentication Not Set Up',
      message: '${item.title} doesn\'t have 2FA configured. Enable it for an extra layer of security.',
      recommendation: 'Set up 2FA using an authenticator app for better account protection.',
    );

    return _createAlert(dto);
  }

  /// Creates alert in database
  Future<SecurityAlert> _createAlert(CreateSecurityAlertDto dto) async {
    try {
      final data = dto.toJson();
      final response = await _supabase
          .from(_securityAlertsTable)
          .insert(data)
          .select()
          .single();

      return SecurityAlert.fromJson(response);
    } catch (e) {
      throw SecurityMonitoringException('Failed to create alert: $e');
    }
  }

  // =====================================================
  // ALERT MANAGEMENT: CRUD Operations
  // =====================================================

  /// Gets all active alerts for user
  Future<List<SecurityAlert>> getActiveAlerts() async {
    try {
      final response = await _supabase
          .from(_securityAlertsTable)
          .select()
          .eq('status', 'active')
          .order('severity', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SecurityAlert.fromJson(json))
          .toList();
    } catch (e) {
      throw SecurityMonitoringException('Failed to fetch alerts: $e');
    }
  }

  /// Acknowledges an alert
  Future<SecurityAlert> acknowledgeAlert(String alertId) async {
    return _updateAlertStatus(alertId, AlertStatus.acknowledged);
  }

  /// Resolves an alert
  Future<SecurityAlert> resolveAlert(String alertId) async {
    return _updateAlertStatus(alertId, AlertStatus.resolved);
  }

  /// Dismisses an alert
  Future<SecurityAlert> dismissAlert(String alertId) async {
    return _updateAlertStatus(alertId, AlertStatus.dismissed);
  }

  /// Updates alert status
  Future<SecurityAlert> _updateAlertStatus(
    String alertId,
    AlertStatus status,
  ) async {
    try {
      final response = await _supabase
          .from(_securityAlertsTable)
          .update({'status': status.name})
          .eq('id', alertId)
          .select()
          .single();

      return SecurityAlert.fromJson(response);
    } catch (e) {
      throw SecurityMonitoringException('Failed to update alert: $e');
    }
  }

  // =====================================================
  // DASHBOARD: Security Score Calculation
  // =====================================================

  /// Calculates overall security score (0-100)
  Future<double> calculateSecurityScore({
    required List<VaultItemWithDecrypted> decryptedItems,
  }) async {
    if (decryptedItems.isEmpty) return 100.0;

    int totalScore = 0;
    int maxScore = decryptedItems.length * 100;

    for (final item in decryptedItems) {
      final password = item.decryptedPayload.password;
      if (password == null || password.isEmpty) {
        totalScore += 50; // Neutral score for items without passwords
        continue;
      }

      int itemScore = 100;

      // Deduct for weak password
      final strength = EncryptionService.analyzePasswordStrength(password);
      if (strength == PasswordHealthStatus.weak) itemScore -= 40;

      // Deduct for reused password
      if (item.vaultItem.passwordHealth == PasswordHealthStatus.reused) {
        itemScore -= 30;
      }

      // Deduct for breached password
      if (item.vaultItem.passwordHealth == PasswordHealthStatus.breached) {
        itemScore -= 50;
      }

      // Deduct for missing 2FA
      if (item.decryptedPayload.totpSecret == null) itemScore -= 10;

      // Deduct for old password (90+ days)
      final daysSinceUpdate =
          DateTime.now().difference(item.vaultItem.updatedAt).inDays;
      if (daysSinceUpdate > 90) itemScore -= 10;
      if (daysSinceUpdate > 180) itemScore -= 20;

      totalScore += itemScore.clamp(0, 100);
    }

    return (totalScore / maxScore * 100).clamp(0.0, 100.0);
  }

  /// Generates security dashboard statistics
  Future<SecurityDashboard> generateSecurityDashboard({
    required List<VaultItemWithDecrypted> decryptedItems,
  }) async {
    final alerts = await getActiveAlerts();

    int criticalAlerts = 0;
    int warningAlerts = 0;
    int infoAlerts = 0;
    int weakPasswords = 0;
    int reusedPasswords = 0;
    int breachedPasswords = 0;
    int passwordsNeedingUpdate = 0;

    for (final alert in alerts) {
      switch (alert.severity) {
        case AlertSeverity.critical:
          criticalAlerts++;
          break;
        case AlertSeverity.warning:
          warningAlerts++;
          break;
        case AlertSeverity.info:
          infoAlerts++;
          break;
      }

      switch (alert.alertType) {
        case AlertType.weakPassword:
          weakPasswords++;
          break;
        case AlertType.reusedPassword:
          reusedPasswords++;
          break;
        case AlertType.breachedPassword:
          breachedPasswords++;
          break;
        case AlertType.passwordUnchangedLong:
          passwordsNeedingUpdate++;
          break;
        default:
          break;
      }
    }

    final securityScore =
        await calculateSecurityScore(decryptedItems: decryptedItems);

    return SecurityDashboard(
      totalAlerts: alerts.length,
      criticalAlerts: criticalAlerts,
      warningAlerts: warningAlerts,
      infoAlerts: infoAlerts,
      weakPasswords: weakPasswords,
      reusedPasswords: reusedPasswords,
      breachedPasswords: breachedPasswords,
      passwordsNeedingUpdate: passwordsNeedingUpdate,
      securityScore: securityScore,
      recentAlerts: alerts.take(5).toList(),
    );
  }
}

// =====================================================
// EXCEPTION: SecurityMonitoringException
// =====================================================

class SecurityMonitoringException implements Exception {
  final String message;

  SecurityMonitoringException(this.message);

  @override
  String toString() => 'SecurityMonitoringException: $message';
}
