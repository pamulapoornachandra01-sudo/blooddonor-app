import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donate/shared/services/local_blood_request_service.dart';

void main() {
  group('LocalBloodRequestService', () {
    late LocalBloodRequestService service;

    setUp(() {
      service = LocalBloodRequestService();
    });

    test('createRequest creates new blood request', () async {
      final result = await service.createRequest(
        receiverId: 'user_1',
        receiverName: 'John Doe',
        bloodType: 'A+',
        unitsNeeded: 2,
        location: 'Mumbai',
        urgency: 'urgent',
        hospitalName: 'Fortis',
        contactPhone: '+919876543210',
      );
      
      result.fold(
        (failure) => fail('Expected success'),
        (request) {
          expect(request.bloodType, equals('A+'));
          expect(request.unitsNeeded, equals(2));
          expect(request.status, equals('posted'));
          expect(request.pledgedDonors.isEmpty, isTrue);
        },
      );
    });

    test('getAllRequests returns all requests', () async {
      await service.createRequest(
        receiverId: 'user_1',
        receiverName: 'John',
        bloodType: 'A+',
        unitsNeeded: 1,
        location: 'Mumbai',
        urgency: 'normal',
      );
      
      await service.createRequest(
        receiverId: 'user_2',
        receiverName: 'Jane',
        bloodType: 'O-',
        unitsNeeded: 2,
        location: 'Delhi',
        urgency: 'urgent',
      );

      final result = await service.getAllRequests();
      
      result.fold(
        (failure) => fail('Expected success'),
        (requests) {
          expect(requests.length, equals(2));
        },
      );
    });

    test('filter by blood type works', () async {
      await service.createRequest(
        receiverId: 'user_1',
        receiverName: 'John',
        bloodType: 'A+',
        unitsNeeded: 1,
        location: 'Mumbai',
        urgency: 'normal',
      );
      
      await service.createRequest(
        receiverId: 'user_2',
        receiverName: 'Jane',
        bloodType: 'O-',
        unitsNeeded: 2,
        location: 'Delhi',
        urgency: 'urgent',
      );

      final result = await service.getAllRequests(bloodType: 'A+');
      
      result.fold(
        (failure) => fail('Expected success'),
        (requests) {
          expect(requests.length, equals(1));
          expect(requests.first.bloodType, equals('A+'));
        },
      );
    });

    test('pledgeDonation adds donor to request', () async {
      final createResult = await service.createRequest(
        receiverId: 'user_1',
        receiverName: 'John',
        bloodType: 'A+',
        unitsNeeded: 2,
        location: 'Mumbai',
        urgency: 'normal',
      );

      final requestId = createResult.fold((l) => '', (r) => r.id);
      final pledgeResult = await service.pledgeDonation(requestId, 'donor_1');
      
      pledgeResult.fold(
        (failure) => fail('Expected success'),
        (request) {
          expect(request.pledgedDonors.contains('donor_1'), isTrue);
        },
      );
    });

    test('cannot pledge twice', () async {
      final createResult = await service.createRequest(
        receiverId: 'user_1',
        receiverName: 'John',
        bloodType: 'A+',
        unitsNeeded: 2,
        location: 'Mumbai',
        urgency: 'normal',
      );

      final requestId = createResult.fold((l) => '', (r) => r.id);
      await service.pledgeDonation(requestId, 'donor_1');
      final result = await service.pledgeDonation(requestId, 'donor_1');
      
      result.fold(
        (failure) => expect(failure.message, contains('already pledged')),
        (request) => fail('Expected failure'),
      );
    });

    test('fulfillRequest marks request as fulfilled', () async {
      final createResult = await service.createRequest(
        receiverId: 'user_1',
        receiverName: 'John',
        bloodType: 'A+',
        unitsNeeded: 1,
        location: 'Mumbai',
        urgency: 'normal',
      );

      final requestId = createResult.fold((l) => '', (r) => r.id);
      final result = await service.fulfillRequest(requestId);
      
      result.fold(
        (failure) => fail('Expected success'),
        (request) {
          expect(request.status, equals('fulfilled'));
          expect(request.fulfilledAt, isNotNull);
        },
      );
    });
  });
}
