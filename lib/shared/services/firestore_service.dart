import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../rbac/models/app_role.dart';
import 'user_model.dart';
import 'blood_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<Either<Failure, User>> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
      return Right(user);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return const Left(FirestoreFailure('User not found'));
      }
      return Right(User.fromJson(doc.data()!));
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
      return Right(user);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
      return Right(users);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<User>>> getUsersByRole(AppRole role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.name)
          .get();
      final users = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
      return Right(users);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  // Blood Request operations
  Future<Either<Failure, BloodRequest>> createBloodRequest(BloodRequest request) async {
    try {
      await _firestore.collection('blood_requests').doc(request.id).set(request.toJson());
      return Right(request);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, BloodRequest>> getBloodRequest(String id) async {
    try {
      final doc = await _firestore.collection('blood_requests').doc(id).get();
      if (!doc.exists) {
        return const Left(FirestoreFailure('Request not found'));
      }
      return Right(BloodRequest.fromJson(doc.data()!));
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<BloodRequest>>> getAllBloodRequests() async {
    try {
      final snapshot = await _firestore
          .collection('blood_requests')
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs.map((doc) => BloodRequest.fromJson(doc.data())).toList();
      return Right(requests);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<BloodRequest>>> getBloodRequestsByReceiver(String receiverId) async {
    try {
      final snapshot = await _firestore
          .collection('blood_requests')
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs.map((doc) => BloodRequest.fromJson(doc.data())).toList();
      return Right(requests);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, BloodRequest>> updateBloodRequest(BloodRequest request) async {
    try {
      await _firestore.collection('blood_requests').doc(request.id).update(request.toJson());
      return Right(request);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  // Verification operations
  Future<Either<Failure, Map<String, dynamic>>> getVerification(String uid) async {
    try {
      final doc = await _firestore.collection('verifications').doc(uid).get();
      if (!doc.exists) {
        return const Left(FirestoreFailure('Verification not found'));
      }
      return Right(doc.data()!);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> createVerification(Map<String, dynamic> verification) async {
    try {
      final uid = verification['uid'] as String;
      await _firestore.collection('verifications').doc(uid).set(verification);
      return Right(verification);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateVerification(
      String uid, Map<String, dynamic> verification) async {
    try {
      await _firestore.collection('verifications').doc(uid).update(verification);
      return Right(verification);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  // Stream for real-time updates
  Stream<List<User>> usersStream() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => User.fromJson(doc.data())).toList(),
        );
  }

  Stream<List<BloodRequest>> bloodRequestsStream() {
    return _firestore
        .collection('blood_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => BloodRequest.fromJson(doc.data())).toList(),
        );
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Stream providers for real-time data
final usersStreamProvider = StreamProvider<List<User>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.usersStream();
});

final bloodRequestsStreamProvider = StreamProvider<List<BloodRequest>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.bloodRequestsStream();
});
