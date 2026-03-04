import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/services/local_blood_request_service.dart';
import '../../../shared/services/blood_request_model.dart';

final localBloodRequestServiceProvider = Provider<LocalBloodRequestService>((ref) {
  final service = LocalBloodRequestService();
  service.seedDemoData();
  return service;
});

final bloodRequestsProvider = FutureProvider.family<List<BloodRequest>, String?>((ref, bloodType) async {
  final service = ref.read(localBloodRequestServiceProvider);
  final result = await service.getAllRequests(bloodType: bloodType);
  return result.fold((l) => [], (r) => r);
});

final myRequestsProvider = FutureProvider.family<List<BloodRequest>, String>((ref, receiverId) async {
  final service = ref.read(localBloodRequestServiceProvider);
  final result = await service.getMyRequests(receiverId);
  return result.fold((l) => [], (r) => r);
});

final bloodRequestDetailProvider = FutureProvider.family<BloodRequest, String>((ref, requestId) async {
  final service = ref.read(localBloodRequestServiceProvider);
  final result = await service.getRequest(requestId);
  return result.fold((l) => throw Exception(l.message), (r) => r);
});

final bloodRequestActionsProvider = Provider<BloodRequestActions>((ref) {
  return BloodRequestActions(ref.read(localBloodRequestServiceProvider), ref);
});

class BloodRequestActions {
  final LocalBloodRequestService _service;
  final Ref _ref;

  BloodRequestActions(this._service, this._ref);

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
    final result = await _service.createRequest(
      receiverId: receiverId,
      receiverName: receiverName,
      bloodType: bloodType,
      unitsNeeded: unitsNeeded,
      location: location,
      urgency: urgency,
      hospitalName: hospitalName,
      contactPhone: contactPhone,
    );
    _ref.invalidate(bloodRequestsProvider(null));
    _ref.invalidate(myRequestsProvider(receiverId));
    return result;
  }

  Future<Either<Failure, BloodRequest>> pledgeDonation(String requestId, String donorId) async {
    final result = await _service.pledgeDonation(requestId, donorId);
    _ref.invalidate(bloodRequestsProvider(null));
    return result;
  }

  Future<Either<Failure, BloodRequest>> fulfillRequest(String requestId) async {
    final result = await _service.fulfillRequest(requestId);
    _ref.invalidate(bloodRequestsProvider(null));
    return result;
  }

  Future<Either<Failure, BloodRequest>> closeRequest(String requestId) async {
    final result = await _service.closeRequest(requestId);
    _ref.invalidate(bloodRequestsProvider(null));
    return result;
  }
}

final selectedBloodTypeProvider = StateProvider<String?>((ref) => null);
