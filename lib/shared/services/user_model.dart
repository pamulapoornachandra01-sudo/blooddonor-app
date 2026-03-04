import 'package:equatable/equatable.dart';
import '../../rbac/models/app_role.dart';

enum VerificationStatus {
  pending,
  inReview,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.inReview:
        return 'In Review';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

class User extends Equatable {
  final String uid;
  final String phone;
  final AppRole role;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bloodType;
  final String? name;
  final bool isAvailable;
  final bool isBanned;

  const User({
    required this.uid,
    required this.phone,
    required this.role,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.bloodType,
    this.name,
    this.isAvailable = false,
    this.isBanned = false,
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  User copyWith({
    String? uid,
    String? phone,
    AppRole? role,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bloodType,
    String? name,
    bool? isAvailable,
    bool? isBanned,
  }) {
    return User(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bloodType: bloodType ?? this.bloodType,
      name: name ?? this.name,
      isAvailable: isAvailable ?? this.isAvailable,
      isBanned: isBanned ?? this.isBanned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phone': phone,
      'role': role.name,
      'verificationStatus': verificationStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bloodType': bloodType,
      'name': name,
      'isAvailable': isAvailable,
      'isBanned': isBanned,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      phone: json['phone'] as String,
      role: AppRole.fromString(json['role'] as String),
      verificationStatus: VerificationStatus.fromString(json['verificationStatus'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bloodType: json['bloodType'] as String?,
      name: json['name'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? false,
      isBanned: json['isBanned'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        phone,
        role,
        verificationStatus,
        createdAt,
        updatedAt,
        bloodType,
        name,
        isAvailable,
        isBanned,
      ];
}
