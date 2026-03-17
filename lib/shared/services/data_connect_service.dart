import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../rbac/models/app_role.dart';
import 'user_model.dart';
import 'blood_request_model.dart';

// Data Connect Service - Wrapper around generated SDK
// Once SDK is generated via Firebase CLI, replace with actual generated imports
class DataConnectService {
  // User operations
  Future<Either<Failure, User>> createUser({
    required String firebaseUid,
    required String phone,
    required AppRole role,
  }) async {
    // TODO: Replace with generated SDK call:
    // final result = await UsersConnector.instance.createUser(
    //   firebaseUid: firebaseUid,
    //   phone: phone,
    //   role: role.name,
    // );
    // return Right(result.data);
    
    // Placeholder - returns mock data
    final now = DateTime.now();
    return Right(User(
      uid: firebaseUid,
      phone: phone,
      role: role,
      verificationStatus: VerificationStatus.pending,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<Either<Failure, User>> getUser(String uid) async {
    // TODO: Replace with generated SDK call:
    // final result = await UsersConnector.instance.getUser(id: UUID.fromString(uid));
    // return Right(result.data);
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, User>> getUserByFirebaseUid(String firebaseUid) async {
    // TODO: Replace with generated SDK call:
    // final result = await UsersConnector.instance.getUserByFirebaseUid(firebaseUid: firebaseUid);
    // return Right(result.data.firstOrNull ?? User(...));
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, User>> updateUser(User user) async {
    // TODO: Replace with generated SDK call:
    // final result = await UsersConnector.instance.updateUser(
    //   id: UUID.fromString(user.uid),
    //   name: user.name,
    //   bloodType: user.bloodType,
    //   role: user.role.name,
    //   verificationStatus: user.verificationStatus.name,
    //   isAvailable: user.isAvailable,
    //   isBanned: user.isBanned,
    // );
    // return Right(result.data);
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, List<User>>> getAllUsers() async {
    // TODO: Replace with generated SDK call:
    // final result = await UsersConnector.instance.listUsers();
    // return Right(result.data.map((u) => u).toList());
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, List<User>>> getUsersByRole(AppRole role) async {
    // TODO: Replace with generated SDK call:
    // final result = await UsersConnector.instance.listUsersByRole(role: role.name);
    // return Right(result.data.map((u) => u).toList());
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  // Blood Request operations
  Future<Either<Failure, BloodRequest>> createBloodRequest(BloodRequest request) async {
    // TODO: Replace with generated SDK call:
    // final result = await BloodRequestsConnector.instance.createBloodRequest(
    //   receiverId: UUID.fromString(request.receiverId),
    //   receiverName: request.receiverName,
    //   bloodType: request.bloodType,
    //   unitsNeeded: request.unitsNeeded,
    //   location: request.location,
    //   locationDetails: request.locationDetails,
    //   urgency: request.urgency,
    //   medicalProofUrl: request.medicalProofUrl,
    //   hospitalName: request.hospitalName,
    //   contactPhone: request.contactPhone,
    // );
    // return Right(result.data);
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, BloodRequest>> getBloodRequest(String id) async {
    // TODO: Replace with generated SDK call:
    // final result = await BloodRequestsConnector.instance.getBloodRequest(id: UUID.fromString(id));
    // return Right(result.data);
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, List<BloodRequest>>> getAllBloodRequests() async {
    // TODO: Replace with generated SDK call:
    // final result = await BloodRequestsConnector.instance.listBloodRequests();
    // return Right(result.data.map((r) => r).toList());
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, List<BloodRequest>>> getBloodRequestsByReceiver(String receiverId) async {
    // TODO: Replace with generated SDK call:
    // final result = await BloodRequestsConnector.instance.listBloodRequestsByReceiver(
    //   receiverId: UUID.fromString(receiverId),
    // );
    // return Right(result.data.map((r) => r).toList());
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, BloodRequest>> updateBloodRequest(BloodRequest request) async {
    // TODO: Replace with generated SDK call:
    // final result = await BloodRequestsConnector.instance.updateBloodRequest(
    //   id: UUID.fromString(request.id),
    //   status: request.status,
    //   pledgedDonors: request.pledgedDonors,
    //   fulfilledAt: request.fulfilledAt,
    // );
    // return Right(result.data);
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  // Verification operations
  Future<Either<Failure, Map<String, dynamic>>> createVerification({
    required String userId,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
    String? medicalDocUrl,
  }) async {
    // TODO: Replace with generated SDK call:
    // final result = await VerificationsConnector.instance.createVerification(
    //   userId: UUID.fromString(userId),
    //   idFrontUrl: idFrontUrl,
    //   idBackUrl: idBackUrl,
    //   selfieUrl: selfieUrl,
    //   medicalDocUrl: medicalDocUrl,
    // );
    // return Right(result.data.toJson());
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, Map<String, dynamic>>> getVerification(String userId) async {
    // TODO: Replace with generated SDK call:
    // final result = await VerificationsConnector.instance.getVerification(userId: UUID.fromString(userId));
    // return Right(result.data.firstOrNull?.toJson() ?? {});
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  Future<Either<Failure, Map<String, dynamic>>> updateVerification({
    required String userId,
    required String status,
    String? rejectionReason,
  }) async {
    // TODO: Replace with generated SDK call:
    // final result = await VerificationsConnector.instance.updateVerification(
    //   userId: UUID.fromString(userId),
    //   status: status,
    //   rejectionReason: rejectionReason,
    // );
    // return Right(result.data.toJson());
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }

  // Notification operations
  Future<Either<Failure, void>> createNotification({
    required String userId,
    required String title,
    String? body,
    String? type,
  }) async {
    // TODO: Replace with generated SDK call:
    // await NotificationsConnector.instance.createNotification(
    //   userId: UUID.fromString(userId),
    //   title: title,
    //   body: body,
    //   type: type,
    // );
    
    return const Left(FirestoreFailure('Data Connect SDK not generated yet'));
  }
}

final dataConnectServiceProvider = Provider<DataConnectService>((ref) {
  return DataConnectService();
});
