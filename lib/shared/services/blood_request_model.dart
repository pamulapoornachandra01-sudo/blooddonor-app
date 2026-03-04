import 'package:equatable/equatable.dart';

class BloodRequest extends Equatable {
  final String id;
  final String receiverId;
  final String receiverName;
  final String bloodType;
  final int unitsNeeded;
  final String location;
  final String? locationDetails;
  final String urgency;
  final String? medicalProofUrl;
  final String status;
  final DateTime createdAt;
  final DateTime? fulfilledAt;
  final List<String> pledgedDonors;
  final String? hospitalName;
  final String? contactPhone;

  const BloodRequest({
    required this.id,
    required this.receiverId,
    required this.receiverName,
    required this.bloodType,
    required this.unitsNeeded,
    required this.location,
    this.locationDetails,
    required this.urgency,
    this.medicalProofUrl,
    required this.status,
    required this.createdAt,
    this.fulfilledAt,
    this.pledgedDonors = const [],
    this.hospitalName,
    this.contactPhone,
  });

  bool get isUrgent => urgency == 'urgent';
  bool get isPosted => status == 'posted';
  bool get isVerified => status == 'verified';
  bool get isMatched => status == 'matched';
  bool get isFulfilled => status == 'fulfilled';

  int get pledgedCount => pledgedDonors.length;
  bool get needsMoreDonors => pledgedCount < unitsNeeded;

  BloodRequest copyWith({
    String? id,
    String? receiverId,
    String? receiverName,
    String? bloodType,
    int? unitsNeeded,
    String? location,
    String? locationDetails,
    String? urgency,
    String? medicalProofUrl,
    String? status,
    DateTime? createdAt,
    DateTime? fulfilledAt,
    List<String>? pledgedDonors,
    String? hospitalName,
    String? contactPhone,
  }) {
    return BloodRequest(
      id: id ?? this.id,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      bloodType: bloodType ?? this.bloodType,
      unitsNeeded: unitsNeeded ?? this.unitsNeeded,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      urgency: urgency ?? this.urgency,
      medicalProofUrl: medicalProofUrl ?? this.medicalProofUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      fulfilledAt: fulfilledAt ?? this.fulfilledAt,
      pledgedDonors: pledgedDonors ?? this.pledgedDonors,
      hospitalName: hospitalName ?? this.hospitalName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'bloodType': bloodType,
      'unitsNeeded': unitsNeeded,
      'location': location,
      'locationDetails': locationDetails,
      'urgency': urgency,
      'medicalProofUrl': medicalProofUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'fulfilledAt': fulfilledAt?.toIso8601String(),
      'pledgedDonors': pledgedDonors,
      'hospitalName': hospitalName,
      'contactPhone': contactPhone,
    };
  }

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      bloodType: json['bloodType'] as String,
      unitsNeeded: json['unitsNeeded'] as int,
      location: json['location'] as String,
      locationDetails: json['locationDetails'] as String?,
      urgency: json['urgency'] as String,
      medicalProofUrl: json['medicalProofUrl'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fulfilledAt: json['fulfilledAt'] != null ? DateTime.parse(json['fulfilledAt'] as String) : null,
      pledgedDonors: (json['pledgedDonors'] as List<dynamic>?)?.cast<String>() ?? [],
      hospitalName: json['hospitalName'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        receiverId,
        receiverName,
        bloodType,
        unitsNeeded,
        location,
        locationDetails,
        urgency,
        medicalProofUrl,
        status,
        createdAt,
        fulfilledAt,
        pledgedDonors,
        hospitalName,
        contactPhone,
      ];
}

class BloodType {
  static const List<String> all = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  
  static const Map<String, List<String>> compatibility = {
    'A+': ['A+', 'A-', 'AB+', 'AB-'],
    'A-': ['A-', 'O-'],
    'B+': ['B+', 'B-', 'AB+', 'AB-'],
    'B-': ['B-', 'O-'],
    'AB+': ['AB+', 'AB-'],
    'AB-': ['AB-'],
    'O+': ['O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-'],
    'O-': ['O-'],
  };
  
  static List<String> getCompatible(String bloodType) {
    return compatibility[bloodType] ?? [];
  }
}
