// =====================================================
// ShieldX Zero-Knowledge Vault Models
// File: vault_item_model.dart
// =====================================================
// Description: Core data models for vault items with ZKE architecture.
// Separates encrypted payload from plain-text metadata for optimal
// performance and security.
// =====================================================

// =====================================================
// ENUMS: Type Definitions
// =====================================================

enum CredentialCategory {
  login,
  creditCard,
  identity,
  secureNote,
  apiKey,
  bankAccount,
  cryptoWallet,
  sshKey,
  license,
  custom;

  String toJson() {
    switch (this) {
      case CredentialCategory.login:
        return 'login';
      case CredentialCategory.creditCard:
        return 'credit_card';
      case CredentialCategory.identity:
        return 'identity';
      case CredentialCategory.secureNote:
        return 'secure_note';
      case CredentialCategory.apiKey:
        return 'api_key';
      case CredentialCategory.bankAccount:
        return 'bank_account';
      case CredentialCategory.cryptoWallet:
        return 'crypto_wallet';
      case CredentialCategory.sshKey:
        return 'ssh_key';
      case CredentialCategory.license:
        return 'license';
      case CredentialCategory.custom:
        return 'custom';
    }
  }

  static CredentialCategory fromJson(String value) {
    switch (value) {
      case 'login':
        return CredentialCategory.login;
      case 'credit_card':
        return CredentialCategory.creditCard;
      case 'identity':
        return CredentialCategory.identity;
      case 'secure_note':
        return CredentialCategory.secureNote;
      case 'api_key':
        return CredentialCategory.apiKey;
      case 'bank_account':
        return CredentialCategory.bankAccount;
      case 'crypto_wallet':
        return CredentialCategory.cryptoWallet;
      case 'ssh_key':
        return CredentialCategory.sshKey;
      case 'license':
        return CredentialCategory.license;
      case 'custom':
        return CredentialCategory.custom;
      default:
        return CredentialCategory.custom;
    }
  }
}

enum PasswordHealthStatus {
  strong,
  weak,
  reused,
  breached,
  expired,
  unknown;

  String toJson() => name;

  static PasswordHealthStatus fromJson(String value) {
    switch (value) {
      case 'strong':
        return PasswordHealthStatus.strong;
      case 'weak':
        return PasswordHealthStatus.weak;
      case 'reused':
        return PasswordHealthStatus.reused;
      case 'breached':
        return PasswordHealthStatus.breached;
      case 'expired':
        return PasswordHealthStatus.expired;
      default:
        return PasswordHealthStatus.unknown;
    }
  }
}

// =====================================================
// MODEL: VaultItem (Database Entity)
// =====================================================
// Represents the encrypted vault item as stored in Supabase
// Plain-text metadata for UI/filtering + encrypted payload

class VaultItem {
  final String id;
  final String userId;
  final String title;
  final CredentialCategory category;
  final String? websiteUrl;
  final String? notesPreview;
  final String encryptedPayload;
  final String encryptionAlgorithm;
  final String? encryptionKeyHint;
  final String nonce;
  final PasswordHealthStatus passwordHealth;
  final bool isFavorite;
  final bool isDeleted;
  final String? iconUrl;
  final DateTime? iconCachedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsedAt;
  final DateTime? deletedAt;
  final int version;

  VaultItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    this.websiteUrl,
    this.notesPreview,
    required this.encryptedPayload,
    this.encryptionAlgorithm = 'AES-256-GCM',
    this.encryptionKeyHint,
    required this.nonce,
    this.passwordHealth = PasswordHealthStatus.unknown,
    this.isFavorite = false,
    this.isDeleted = false,
    this.iconUrl,
    this.iconCachedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastUsedAt,
    this.deletedAt,
    this.version = 1,
  });

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: CredentialCategory.fromJson(json['category'] as String),
      websiteUrl: json['website_url'] as String?,
      notesPreview: json['notes_preview'] as String?,
      encryptedPayload: json['encrypted_payload'] as String,
      encryptionAlgorithm: json['encryption_algorithm'] as String? ?? 'AES-256-GCM',
      encryptionKeyHint: json['encryption_key_hint'] as String?,
      nonce: json['nonce'] as String,
      passwordHealth: PasswordHealthStatus.fromJson(json['password_health'] as String? ?? 'unknown'),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      iconUrl: json['icon_url'] as String?,
      iconCachedAt: json['icon_cached_at'] != null ? DateTime.parse(json['icon_cached_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at'] as String) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category.toJson(),
      'website_url': websiteUrl,
      'notes_preview': notesPreview,
      'encrypted_payload': encryptedPayload,
      'encryption_algorithm': encryptionAlgorithm,
      'encryption_key_hint': encryptionKeyHint,
      'nonce': nonce,
      'password_health': passwordHealth.toJson(),
      'is_favorite': isFavorite,
      'is_deleted': isDeleted,
      'icon_url': iconUrl,
      'icon_cached_at': iconCachedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_used_at': lastUsedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'version': version,
    };
  }

  VaultItem copyWith({
    String? id,
    String? userId,
    String? title,
    CredentialCategory? category,
    String? websiteUrl,
    String? notesPreview,
    String? encryptedPayload,
    String? encryptionAlgorithm,
    String? encryptionKeyHint,
    String? nonce,
    PasswordHealthStatus? passwordHealth,
    bool? isFavorite,
    bool? isDeleted,
    String? iconUrl,
    DateTime? iconCachedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    DateTime? deletedAt,
    int? version,
  }) {
    return VaultItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      notesPreview: notesPreview ?? this.notesPreview,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      encryptionAlgorithm: encryptionAlgorithm ?? this.encryptionAlgorithm,
      encryptionKeyHint: encryptionKeyHint ?? this.encryptionKeyHint,
      nonce: nonce ?? this.nonce,
      passwordHealth: passwordHealth ?? this.passwordHealth,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      iconUrl: iconUrl ?? this.iconUrl,
      iconCachedAt: iconCachedAt ?? this.iconCachedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
    );
  }
}

// =====================================================
// MODEL: VaultItemPayload (Decrypted Content)
// =====================================================
// Represents the decrypted sensitive data (never sent to server in plain-text)
// Client-side only model for encryption/decryption operations

class VaultItemPayload {
  final String? username;
  final String? email;
  final String? password;
  final String? totpSecret;
  final String? cardNumber;
  final String? cardholderName;
  final String? expirationMonth;
  final String? expirationYear;
  final String? cvv;
  final String? pin;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? dateOfBirth;
  final String? ssn;
  final String? passportNumber;
  final String? licenseNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? phoneNumber;
  final String? apiKey;
  final String? apiSecret;
  final String? privateKey;
  final String? publicKey;
  final String? walletAddress;
  final String? seedPhrase;
  final String? notes;
  final Map<String, dynamic>? customFields;
  final List<VaultAttachment>? attachments;

  VaultItemPayload({
    this.username,
    this.email,
    this.password,
    this.totpSecret,
    this.cardNumber,
    this.cardholderName,
    this.expirationMonth,
    this.expirationYear,
    this.cvv,
    this.pin,
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
    this.ssn,
    this.passportNumber,
    this.licenseNumber,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phoneNumber,
    this.apiKey,
    this.apiSecret,
    this.privateKey,
    this.publicKey,
    this.walletAddress,
    this.seedPhrase,
    this.notes,
    this.customFields,
    this.attachments,
  });

  factory VaultItemPayload.fromJson(Map<String, dynamic> json) {
    return VaultItemPayload(
      username: json['username'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      totpSecret: json['totp_secret'] as String?,
      cardNumber: json['card_number'] as String?,
      cardholderName: json['cardholder_name'] as String?,
      expirationMonth: json['expiration_month'] as String?,
      expirationYear: json['expiration_year'] as String?,
      cvv: json['cvv'] as String?,
      pin: json['pin'] as String?,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      ssn: json['ssn'] as String?,
      passportNumber: json['passport_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      phoneNumber: json['phone_number'] as String?,
      apiKey: json['api_key'] as String?,
      apiSecret: json['api_secret'] as String?,
      privateKey: json['private_key'] as String?,
      publicKey: json['public_key'] as String?,
      walletAddress: json['wallet_address'] as String?,
      seedPhrase: json['seed_phrase'] as String?,
      notes: json['notes'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((e) => VaultAttachment.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (totpSecret != null) 'totp_secret': totpSecret,
      if (cardNumber != null) 'card_number': cardNumber,
      if (cardholderName != null) 'cardholder_name': cardholderName,
      if (expirationMonth != null) 'expiration_month': expirationMonth,
      if (expirationYear != null) 'expiration_year': expirationYear,
      if (cvv != null) 'cvv': cvv,
      if (pin != null) 'pin': pin,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (ssn != null) 'ssn': ssn,
      if (passportNumber != null) 'passport_number': passportNumber,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (apiKey != null) 'api_key': apiKey,
      if (apiSecret != null) 'api_secret': apiSecret,
      if (privateKey != null) 'private_key': privateKey,
      if (publicKey != null) 'public_key': publicKey,
      if (walletAddress != null) 'wallet_address': walletAddress,
      if (seedPhrase != null) 'seed_phrase': seedPhrase,
      if (notes != null) 'notes': notes,
      if (customFields != null) 'custom_fields': customFields,
      if (attachments != null) 'attachments': attachments!.map((e) => e.toJson()).toList(),
    };
  }
}

// =====================================================
// MODEL: VaultAttachment (Encrypted Files)
// =====================================================

class VaultAttachment {
  final String id;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String encryptedStoragePath;
  final DateTime uploadedAt;

  VaultAttachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.encryptedStoragePath,
    required this.uploadedAt,
  });

  factory VaultAttachment.fromJson(Map<String, dynamic> json) {
    return VaultAttachment(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      encryptedStoragePath: json['encrypted_storage_path'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'mime_type': mimeType,
      'file_size': fileSize,
      'encrypted_storage_path': encryptedStoragePath,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

// =====================================================
// DTO: CreateVaultItemDto (Client -> Server)
// =====================================================

class CreateVaultItemDto {
  final String title;
  final CredentialCategory category;
  final String? websiteUrl;
  final String? notesPreview;
  final String encryptedPayload;
  final String nonce;
  final String? encryptionKeyHint;
  final PasswordHealthStatus? passwordHealth;
  final bool? isFavorite;

  CreateVaultItemDto({
    required this.title,
    required this.category,
    this.websiteUrl,
    this.notesPreview,
    required this.encryptedPayload,
    required this.nonce,
    this.encryptionKeyHint,
    this.passwordHealth,
    this.isFavorite,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.toJson(),
      if (websiteUrl != null) 'website_url': websiteUrl,
      if (notesPreview != null) 'notes_preview': notesPreview,
      'encrypted_payload': encryptedPayload,
      'nonce': nonce,
      if (encryptionKeyHint != null) 'encryption_key_hint': encryptionKeyHint,
      if (passwordHealth != null) 'password_health': passwordHealth!.toJson(),
      if (isFavorite != null) 'is_favorite': isFavorite,
    };
  }
}

// =====================================================
// DTO: UpdateVaultItemDto (Client -> Server)
// =====================================================

class UpdateVaultItemDto {
  final String? title;
  final CredentialCategory? category;
  final String? websiteUrl;
  final String? notesPreview;
  final String? encryptedPayload;
  final String? nonce;
  final PasswordHealthStatus? passwordHealth;
  final bool? isFavorite;
  final bool? isDeleted;

  UpdateVaultItemDto({
    this.title,
    this.category,
    this.websiteUrl,
    this.notesPreview,
    this.encryptedPayload,
    this.nonce,
    this.passwordHealth,
    this.isFavorite,
    this.isDeleted,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (category != null) 'category': category!.toJson(),
      if (websiteUrl != null) 'website_url': websiteUrl,
      if (notesPreview != null) 'notes_preview': notesPreview,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (nonce != null) 'nonce': nonce,
      if (passwordHealth != null) 'password_health': passwordHealth!.toJson(),
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isDeleted != null) 'is_deleted': isDeleted,
    };
  }
}

// =====================================================
// MODEL: VaultItemWithDecrypted (Client-Side Only)
// =====================================================
// Combines vault item with decrypted payload for UI display
// NEVER serialize this to JSON or send to server

class VaultItemWithDecrypted {
  final VaultItem vaultItem;
  final VaultItemPayload decryptedPayload;

  VaultItemWithDecrypted({
    required this.vaultItem,
    required this.decryptedPayload,
  });
}

// =====================================================
// EXTENSION: VaultItem Helpers
// =====================================================

extension VaultItemExtensions on VaultItem {
  /// Returns category display name
  String get categoryDisplayName {
    switch (category) {
      case CredentialCategory.login:
        return 'Login';
      case CredentialCategory.creditCard:
        return 'Credit Card';
      case CredentialCategory.identity:
        return 'Identity';
      case CredentialCategory.secureNote:
        return 'Secure Note';
      case CredentialCategory.apiKey:
        return 'API Key';
      case CredentialCategory.bankAccount:
        return 'Bank Account';
      case CredentialCategory.cryptoWallet:
        return 'Crypto Wallet';
      case CredentialCategory.sshKey:
        return 'SSH Key';
      case CredentialCategory.license:
        return 'License';
      case CredentialCategory.custom:
        return 'Custom';
    }
  }

  /// Returns category icon
  String get categoryIcon {
    switch (category) {
      case CredentialCategory.login:
        return '🔐';
      case CredentialCategory.creditCard:
        return '💳';
      case CredentialCategory.identity:
        return '🆔';
      case CredentialCategory.secureNote:
        return '📝';
      case CredentialCategory.apiKey:
        return '🔑';
      case CredentialCategory.bankAccount:
        return '🏦';
      case CredentialCategory.cryptoWallet:
        return '₿';
      case CredentialCategory.sshKey:
        return '🔧';
      case CredentialCategory.license:
        return '📄';
      case CredentialCategory.custom:
        return '📦';
    }
  }

  /// Returns password health color
  String get passwordHealthColor {
    switch (passwordHealth) {
      case PasswordHealthStatus.strong:
        return '#22C55E'; // Green
      case PasswordHealthStatus.weak:
        return '#EF4444'; // Red
      case PasswordHealthStatus.reused:
        return '#F59E0B'; // Orange
      case PasswordHealthStatus.breached:
        return '#DC2626'; // Dark Red
      case PasswordHealthStatus.expired:
        return '#6B7280'; // Gray
      case PasswordHealthStatus.unknown:
        return '#9CA3AF'; // Light Gray
    }
  }

  /// Returns domain from website URL
  String? get domain {
    if (websiteUrl == null) return null;
    try {
      final uri = Uri.parse(websiteUrl!);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  /// Check if item is active (not deleted)
  bool get isActive => !isDeleted;

  /// Check if item needs attention (weak/reused/breached)
  bool get needsAttention =>
      passwordHealth == PasswordHealthStatus.weak ||
      passwordHealth == PasswordHealthStatus.reused ||
      passwordHealth == PasswordHealthStatus.breached;

  /// Check if icon cache is expired (30 days)
  bool get isIconCacheExpired {
    if (iconCachedAt == null) return true;
    return DateTime.now().difference(iconCachedAt!).inDays > 30;
  }
}
