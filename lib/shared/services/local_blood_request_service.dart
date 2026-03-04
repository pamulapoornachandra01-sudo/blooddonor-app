import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import 'blood_request_model.dart';

class LocalBloodRequestService {
  final List<BloodRequest> _requests = [];
  int _idCounter = 1;

  Future<Either<Failure, BloodRequest>> createRequest({
    required String receiverId,
    required String receiverName,
    required String bloodType,
    required int unitsNeeded,
    required String location,
    required String urgency,
    String? hospitalName,
    String? contactPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (bloodType.isEmpty || unitsNeeded < 1 || location.isEmpty) {
      return const Left(ValidationFailure('Invalid request data'));
    }

    final request = BloodRequest(
      id: 'req_${_idCounter++}',
      receiverId: receiverId,
      receiverName: receiverName,
      bloodType: bloodType,
      unitsNeeded: unitsNeeded,
      location: location,
      urgency: urgency,
      status: 'posted',
      createdAt: DateTime.now(),
      hospitalName: hospitalName,
      contactPhone: contactPhone,
    );

    _requests.add(request);
    return Right(request);
  }

  Future<Either<Failure, List<BloodRequest>>> getAllRequests({String? bloodType}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _requests.where((r) => r.status != 'fulfilled').toList();
    
    if (bloodType != null && bloodType.isNotEmpty) {
      filtered = filtered.where((r) => r.bloodType == bloodType).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(filtered);
  }

  Future<Either<Failure, List<BloodRequest>>> getMyRequests(String receiverId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final myRequests = _requests.where((r) => r.receiverId == receiverId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return Right(myRequests);
  }

  Future<Either<Failure, BloodRequest>> getRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final request = _requests.where((r) => r.id == requestId).firstOrNull;
    if (request == null) {
      return const Left(NotFoundFailure('Request not found'));
    }
    return Right(request);
  }

  Future<Either<Failure, BloodRequest>> pledgeDonation(String requestId, String donorId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      return const Left(NotFoundFailure('Request not found'));
    }

    final request = _requests[index];
    if (request.pledgedDonors.contains(donorId)) {
      return const Left(ValidationFailure('You have already pledged'));
    }

    final updated = request.copyWith(
      pledgedDonors: [...request.pledgedDonors, donorId],
      status: request.pledgedDonors.length + 1 >= request.unitsNeeded ? 'matched' : 'verified',
    );

    _requests[index] = updated;
    return Right(updated);
  }

  Future<Either<Failure, BloodRequest>> cancelPledge(String requestId, String donorId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      return const Left(NotFoundFailure('Request not found'));
    }

    final request = _requests[index];
    final updated = request.copyWith(
      pledgedDonors: request.pledgedDonors.where((d) => d != donorId).toList(),
      status: request.pledgedDonors.length - 1 < request.unitsNeeded ? 'verified' : 'matched',
    );

    _requests[index] = updated;
    return Right(updated);
  }

  Future<Either<Failure, BloodRequest>> fulfillRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      return const Left(NotFoundFailure('Request not found'));
    }

    final updated = _requests[index].copyWith(
      status: 'fulfilled',
      fulfilledAt: DateTime.now(),
    );

    _requests[index] = updated;
    return Right(updated);
  }

  Future<Either<Failure, BloodRequest>> closeRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      return const Left(NotFoundFailure('Request not found'));
    }

    final updated = _requests[index].copyWith(
      status: 'fulfilled',
    );

    _requests[index] = updated;
    return Right(updated);
  }

  // Seed some demo data
  void seedDemoData() {
    if (_requests.isEmpty) {
      _requests.addAll([
        BloodRequest(
          id: 'req_1',
          receiverId: 'user_123',
          receiverName: 'John Doe',
          bloodType: 'A+',
          unitsNeeded: 2,
          location: 'Mumbai, Maharashtra',
          urgency: 'urgent',
          status: 'posted',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          hospitalName: 'Fortis Hospital',
          contactPhone: '+919876543210',
        ),
        BloodRequest(
          id: 'req_2',
          receiverId: 'user_124',
          receiverName: 'Jane Smith',
          bloodType: 'O-',
          unitsNeeded: 1,
          location: 'Delhi, NCR',
          urgency: 'normal',
          status: 'verified',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          hospitalName: 'Apollo Hospital',
          contactPhone: '+919876543211',
          pledgedDonors: ['donor_1'],
        ),
        BloodRequest(
          id: 'req_3',
          receiverId: 'user_125',
          receiverName: 'Rahul Kumar',
          bloodType: 'B+',
          unitsNeeded: 3,
          location: 'Bangalore, Karnataka',
          urgency: 'urgent',
          status: 'matched',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          hospitalName: 'Manipal Hospital',
          contactPhone: '+919876543212',
          pledgedDonors: ['donor_1', 'donor_2'],
        ),
      ]);
      _idCounter = 4;
    }
  }
}

final localBloodRequestServiceProvider = Provider<LocalBloodRequestService>((ref) {
  final service = LocalBloodRequestService();
  service.seedDemoData();
  return service;
});
