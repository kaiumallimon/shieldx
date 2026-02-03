// =====================================================
// ShieldX Zero-Knowledge Vault Models
// File: security_alert_model.dart
// =====================================================
// Description: Models for security monitoring and alerting
// without server access to decrypted content.
// =====================================================

// =====================================================
// ENUMS: Alert Type Definitions
// =====================================================

enum AlertSeverity {
  info,
  warning,
  critical;

  String toJson() => name;

  static AlertSeverity fromJson(String value) {
    switch (value) {
      case 'info':
        return AlertSeverity.info;
      case 'warning':
        return AlertSeverity.warning;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.warning;
    }
  }
}

enum AlertType {
  weakPassword,
  reusedPassword,
  breachedPassword,
  expiredPassword,
  compromisedWebsite,
  suspiciousLogin,
  passwordUnchangedLong,
  missing2fa;

  String toJson() {
    switch (this) {
      case AlertType.weakPassword:
        return 'weak_password';
      case AlertType.reusedPassword:
        return 'reused_password';
      case AlertType.breachedPassword:
        return 'breached_password';
      case AlertType.expiredPassword:
        return 'expired_password';
      case AlertType.compromisedWebsite:
        return 'compromised_website';
      case AlertType.suspiciousLogin:
        return 'suspicious_login';
      case AlertType.passwordUnchangedLong:
        return 'password_unchanged_long';
      case AlertType.missing2fa:
        return 'missing_2fa';
    }
  }

  static AlertType fromJson(String value) {
    switch (value) {
      case 'weak_password':
        return AlertType.weakPassword;
      case 'reused_password':
        return AlertType.reusedPassword;
      case 'breached_password':
        return AlertType.breachedPassword;
      case 'expired_password':
        return AlertType.expiredPassword;
      case 'compromised_website':
        return AlertType.compromisedWebsite;
      case 'suspicious_login':
        return AlertType.suspiciousLogin;
      case 'password_unchanged_long':
        return AlertType.passwordUnchangedLong;
      case 'missing_2fa':
        return AlertType.missing2fa;
      default:
        return AlertType.weakPassword;
    }
  }
}

enum AlertStatus {
  active,
  acknowledged,
  resolved,
  dismissed;

  String toJson() => name;

  static AlertStatus fromJson(String value) {
    switch (value) {
      case 'active':
        return AlertStatus.active;
      case 'acknowledged':
        return AlertStatus.acknowledged;
      case 'resolved':
        return AlertStatus.resolved;
      case 'dismissed':
        return AlertStatus.dismissed;
      default:
        return AlertStatus.active;
    }
  }
}

// =====================================================
// MODEL: SecurityAlert (Database Entity)
// =====================================================

class SecurityAlert {
  final String id;
  final String userId;
  final String? vaultItemId;
  final AlertType alertType;
  final AlertSeverity severity;
  final AlertStatus status;
  final String title;
  final String message;
  final String? recommendation;
  final Map<String, dynamic>? metadata;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final DateTime? dismissedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  SecurityAlert({
    required this.id,
    required this.userId,
    this.vaultItemId,
    required this.alertType,
    this.severity = AlertSeverity.warning,
    this.status = AlertStatus.active,
    required this.title,
    required this.message,
    this.recommendation,
    this.metadata,
    this.acknowledgedAt,
    this.resolvedAt,
    this.dismissedAt,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vaultItemId: json['vault_item_id'] as String?,
      alertType: AlertType.fromJson(json['alert_type'] as String),
      severity: AlertSeverity.fromJson(json['severity'] as String? ?? 'warning'),
      status: AlertStatus.fromJson(json['status'] as String? ?? 'active'),
      title: json['title'] as String,
      message: json['message'] as String,
      recommendation: json['recommendation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledged_at'] != null ? DateTime.parse(json['acknowledged_at'] as String) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
      dismissedAt: json['dismissed_at'] != null ? DateTime.parse(json['dismissed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (vaultItemId != null) 'vault_item_id': vaultItemId,
      'alert_type': alertType.toJson(),
      'severity': severity.toJson(),
      'status': status.toJson(),
      'title': title,
      'message': message,
      if (recommendation != null) 'recommendation': recommendation,
      if (metadata != null) 'metadata': metadata,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt!.toIso8601String(),
      if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
      if (dismissedAt != null) 'dismissed_at': dismissedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

// =====================================================
// DTO: CreateSecurityAlertDto (Client -> Server)
// =====================================================

class CreateSecurityAlertDto {
  final String? vaultItemId;
  final AlertType alertType;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String? recommendation;
  final Map<String, dynamic>? metadata;
  final DateTime? expiresAt;

  CreateSecurityAlertDto({
    this.vaultItemId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    this.recommendation,
    this.metadata,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (vaultItemId != null) 'vault_item_id': vaultItemId,
      'alert_type': alertType.toJson(),
      'severity': severity.toJson(),
      'title': title,
      'message': message,
      if (recommendation != null) 'recommendation': recommendation,
      if (metadata != null) 'metadata': metadata,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

// =====================================================
// DTO: UpdateSecurityAlertDto (Client -> Server)
// =====================================================

class UpdateSecurityAlertDto {
  final AlertStatus? status;
  final Map<String, dynamic>? metadata;

  UpdateSecurityAlertDto({
    this.status,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      if (status != null) 'status': status!.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

// =====================================================
// MODEL: SecurityDashboard (Client-Side Analytics)
// =====================================================

class SecurityDashboard {
  final int totalAlerts;
  final int criticalAlerts;
  final int warningAlerts;
  final int infoAlerts;
  final int weakPasswords;
  final int reusedPasswords;
  final int breachedPasswords;
  final int passwordsNeedingUpdate;
  final double securityScore;
  final List<SecurityAlert> recentAlerts;

  SecurityDashboard({
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.warningAlerts,
    required this.infoAlerts,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.breachedPasswords,
    required this.passwordsNeedingUpdate,
    required this.securityScore,
    required this.recentAlerts,
  });

  factory SecurityDashboard.fromJson(Map<String, dynamic> json) {
    return SecurityDashboard(
      totalAlerts: json['total_alerts'] as int,
      criticalAlerts: json['critical_alerts'] as int,
      warningAlerts: json['warning_alerts'] as int,
      infoAlerts: json['info_alerts'] as int,
      weakPasswords: json['weak_passwords'] as int,
      reusedPasswords: json['reused_passwords'] as int,
      breachedPasswords: json['breached_passwords'] as int,
      passwordsNeedingUpdate: json['passwords_needing_update'] as int,
      securityScore: (json['security_score'] as num).toDouble(),
      recentAlerts: (json['recent_alerts'] as List)
          .map((e) => SecurityAlert.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_alerts': totalAlerts,
      'critical_alerts': criticalAlerts,
      'warning_alerts': warningAlerts,
      'info_alerts': infoAlerts,
      'weak_passwords': weakPasswords,
      'reused_passwords': reusedPasswords,
      'breached_passwords': breachedPasswords,
      'passwords_needing_update': passwordsNeedingUpdate,
      'security_score': securityScore,
      'recent_alerts': recentAlerts.map((e) => e.toJson()).toList(),
    };
  }
}

// =====================================================
// EXTENSION: SecurityAlert Helpers
// =====================================================

extension SecurityAlertExtensions on SecurityAlert {
  /// Returns severity color
  String get severityColor {
    switch (severity) {
      case AlertSeverity.info:
        return '#3B82F6'; // Blue
      case AlertSeverity.warning:
        return '#F59E0B'; // Orange
      case AlertSeverity.critical:
        return '#EF4444'; // Red
    }
  }

  /// Returns severity icon
  String get severityIcon {
    switch (severity) {
      case AlertSeverity.info:
        return 'ℹ️';
      case AlertSeverity.warning:
        return '⚠️';
      case AlertSeverity.critical:
        return '🚨';
    }
  }

  /// Returns alert type display name
  String get alertTypeDisplayName {
    switch (alertType) {
      case AlertType.weakPassword:
        return 'Weak Password';
      case AlertType.reusedPassword:
        return 'Reused Password';
      case AlertType.breachedPassword:
        return 'Breached Password';
      case AlertType.expiredPassword:
        return 'Expired Password';
      case AlertType.compromisedWebsite:
        return 'Compromised Website';
      case AlertType.suspiciousLogin:
        return 'Suspicious Login';
      case AlertType.passwordUnchangedLong:
        return 'Password Not Updated';
      case AlertType.missing2fa:
        return 'Missing 2FA';
    }
  }

  /// Returns alert type icon
  String get alertTypeIcon {
    switch (alertType) {
      case AlertType.weakPassword:
        return '🔓';
      case AlertType.reusedPassword:
        return '🔄';
      case AlertType.breachedPassword:
        return '💔';
      case AlertType.expiredPassword:
        return '⏰';
      case AlertType.compromisedWebsite:
        return '🚫';
      case AlertType.suspiciousLogin:
        return '👁️';
      case AlertType.passwordUnchangedLong:
        return '📅';
      case AlertType.missing2fa:
        return '🔐';
    }
  }

  /// Check if alert is actionable
  bool get isActionable => status == AlertStatus.active;

  /// Check if alert is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if alert is recent (last 7 days)
  bool get isRecent {
    return DateTime.now().difference(createdAt).inDays < 7;
  }

  /// Get time since alert created
  String get timeSinceCreated {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
