// =====================================================
// ShieldX Zero-Knowledge Vault Models
// File: usage_history_model.dart
// =====================================================
// Description: Models for tracking credential usage patterns
// in a privacy-preserving manner.
// =====================================================

// =====================================================
// ENUMS: Usage Action Types
// =====================================================

enum UsageActionType {
  autofill,
  manualCopy,
  view,
  share;

  String toJson() {
    switch (this) {
      case UsageActionType.autofill:
        return 'autofill';
      case UsageActionType.manualCopy:
        return 'manual_copy';
      case UsageActionType.view:
        return 'view';
      case UsageActionType.share:
        return 'share';
    }
  }

  static UsageActionType fromJson(String value) {
    switch (value) {
      case 'autofill':
        return UsageActionType.autofill;
      case 'manual_copy':
        return UsageActionType.manualCopy;
      case 'view':
        return UsageActionType.view;
      case 'share':
        return UsageActionType.share;
      default:
        return UsageActionType.autofill;
    }
  }
}

// =====================================================
// MODEL: UsageHistory (Database Entity)
// =====================================================

class UsageHistory {
  final String id;
  final String userId;
  final String vaultItemId;
  final String? appPackageName;
  final String? appBundleId;
  final String? websiteDomain;
  final String? pageUrl;
  final UsageActionType actionType;
  final Map<String, dynamic>? deviceInfo;
  final DateTime usedAt;

  UsageHistory({
    required this.id,
    required this.userId,
    required this.vaultItemId,
    this.appPackageName,
    this.appBundleId,
    this.websiteDomain,
    this.pageUrl,
    this.actionType = UsageActionType.autofill,
    this.deviceInfo,
    required this.usedAt,
  });

  factory UsageHistory.fromJson(Map<String, dynamic> json) {
    return UsageHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vaultItemId: json['vault_item_id'] as String,
      appPackageName: json['app_package_name'] as String?,
      appBundleId: json['app_bundle_id'] as String?,
      websiteDomain: json['website_domain'] as String?,
      pageUrl: json['page_url'] as String?,
      actionType: UsageActionType.fromJson(json['action_type'] as String? ?? 'autofill'),
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      usedAt: DateTime.parse(json['used_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vault_item_id': vaultItemId,
      if (appPackageName != null) 'app_package_name': appPackageName,
      if (appBundleId != null) 'app_bundle_id': appBundleId,
      if (websiteDomain != null) 'website_domain': websiteDomain,
      if (pageUrl != null) 'page_url': pageUrl,
      'action_type': actionType.toJson(),
      if (deviceInfo != null) 'device_info': deviceInfo,
      'used_at': usedAt.toIso8601String(),
    };
  }
}

// =====================================================
// DTO: CreateUsageHistoryDto (Client -> Server)
// =====================================================

class CreateUsageHistoryDto {
  final String vaultItemId;
  final String? appPackageName;
  final String? appBundleId;
  final String? websiteDomain;
  final String? pageUrl;
  final UsageActionType actionType;
  final Map<String, dynamic>? deviceInfo;

  CreateUsageHistoryDto({
    required this.vaultItemId,
    this.appPackageName,
    this.appBundleId,
    this.websiteDomain,
    this.pageUrl,
    this.actionType = UsageActionType.autofill,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'vault_item_id': vaultItemId,
      if (appPackageName != null) 'app_package_name': appPackageName,
      if (appBundleId != null) 'app_bundle_id': appBundleId,
      if (websiteDomain != null) 'website_domain': websiteDomain,
      if (pageUrl != null) 'page_url': pageUrl,
      'action_type': actionType.toJson(),
      if (deviceInfo != null) 'device_info': deviceInfo,
    };
  }
}

// =====================================================
// MODEL: UsageStatistics (Analytics Aggregate)
// =====================================================

class UsageStatistics {
  final int totalUsages;
  final int autofillCount;
  final int manualCopyCount;
  final int viewCount;
  final Map<String, int> usageByDomain;
  final Map<String, int> usageByApp;
  final DateTime? lastUsedAt;
  final DateTime? mostFrequentUsageTime;

  UsageStatistics({
    required this.totalUsages,
    required this.autofillCount,
    required this.manualCopyCount,
    required this.viewCount,
    required this.usageByDomain,
    required this.usageByApp,
    this.lastUsedAt,
    this.mostFrequentUsageTime,
  });

  factory UsageStatistics.fromJson(Map<String, dynamic> json) {
    return UsageStatistics(
      totalUsages: json['total_usages'] as int,
      autofillCount: json['autofill_count'] as int,
      manualCopyCount: json['manual_copy_count'] as int,
      viewCount: json['view_count'] as int,
      usageByDomain: Map<String, int>.from(json['usage_by_domain'] as Map),
      usageByApp: Map<String, int>.from(json['usage_by_app'] as Map),
      lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at'] as String) : null,
      mostFrequentUsageTime: json['most_frequent_usage_time'] != null ? DateTime.parse(json['most_frequent_usage_time'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_usages': totalUsages,
      'autofill_count': autofillCount,
      'manual_copy_count': manualCopyCount,
      'view_count': viewCount,
      'usage_by_domain': usageByDomain,
      'usage_by_app': usageByApp,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt!.toIso8601String(),
      if (mostFrequentUsageTime != null) 'most_frequent_usage_time': mostFrequentUsageTime!.toIso8601String(),
    };
  }
}

// =====================================================
// EXTENSION: UsageHistory Helpers
// =====================================================

extension UsageHistoryExtensions on UsageHistory {
  /// Returns action type display name
  String get actionTypeDisplayName {
    switch (actionType) {
      case UsageActionType.autofill:
        return 'Autofilled';
      case UsageActionType.manualCopy:
        return 'Copied';
      case UsageActionType.view:
        return 'Viewed';
      case UsageActionType.share:
        return 'Shared';
    }
  }

  /// Returns usage context display (app or website)
  String get usageContext {
    if (websiteDomain != null) return websiteDomain!;
    if (appPackageName != null) return appPackageName!;
    if (appBundleId != null) return appBundleId!;
    return 'Unknown';
  }

  /// Returns platform icon
  String get platformIcon {
    if (websiteDomain != null) return '🌐';
    if (appPackageName != null) return '📱';
    if (appBundleId != null) return '🍎';
    return '❓';
  }

  /// Check if usage is recent (last 24 hours)
  bool get isRecent {
    return DateTime.now().difference(usedAt).inHours < 24;
  }
}
