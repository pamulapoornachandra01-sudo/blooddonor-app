import 'package:equatable/equatable.dart';

class Verification extends Equatable {
  final String uid;
  final String role;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;
  final String? medicalDocUrl;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? rejectionReason;
  final bool canResubmit;

  const Verification({
    required this.uid,
    required this.role,
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
    this.medicalDocUrl,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewerId,
    this.rejectionReason,
    this.canResubmit = true,
  });

  bool get isPending => status == 'pending';
  bool get isInReview => status == 'in_review';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  bool get needsMedicalDoc => role == 'receiver';

  Verification copyWith({
    String? uid,
    String? role,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
    String? medicalDocUrl,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewerId,
    String? rejectionReason,
    bool? canResubmit,
  }) {
    return Verification(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      medicalDocUrl: medicalDocUrl ?? this.medicalDocUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerId: reviewerId ?? this.reviewerId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      canResubmit: canResubmit ?? this.canResubmit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role,
      'idFrontUrl': idFrontUrl,
      'idBackUrl': idBackUrl,
      'selfieUrl': selfieUrl,
      'medicalDocUrl': medicalDocUrl,
      'status': status,
      'submittedAt': submittedAt?.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerId': reviewerId,
      'rejectionReason': rejectionReason,
      'canResubmit': canResubmit,
    };
  }

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      uid: json['uid'] as String,
      role: json['role'] as String,
      idFrontUrl: json['idFrontUrl'] as String?,
      idBackUrl: json['idBackUrl'] as String?,
      selfieUrl: json['selfieUrl'] as String?,
      medicalDocUrl: json['medicalDocUrl'] as String?,
      status: json['status'] as String? ?? 'pending',
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt'] as String) : null,
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
      reviewerId: json['reviewerId'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      canResubmit: json['canResubmit'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        role,
        idFrontUrl,
        idBackUrl,
        selfieUrl,
        medicalDocUrl,
        status,
        submittedAt,
        reviewedAt,
        reviewerId,
        rejectionReason,
        canResubmit,
      ];
}
