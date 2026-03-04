enum AppPermission {
  manageUsers,
  reviewVerifications,
  approveRejectUsers,
  viewAdminDashboard,
  viewVerificationQueue,
  approveIdentity,
  rejectIdentity,
  approveMedical,
  rejectMedical,
  requestMoreInfo,
  viewBloodRequests,
  pledgeDonation,
  updateAvailability,
  viewMyDonationHistory,
  postBloodRequest,
  viewMyRequestStatus,
  uploadMedicalProof,
  closeRequest;

  String get displayName {
    switch (this) {
      case AppPermission.manageUsers:
        return 'Manage Users';
      case AppPermission.reviewVerifications:
        return 'Review Verifications';
      case AppPermission.approveRejectUsers:
        return 'Approve/Reject Users';
      case AppPermission.viewAdminDashboard:
        return 'View Admin Dashboard';
      case AppPermission.viewVerificationQueue:
        return 'View Verification Queue';
      case AppPermission.approveIdentity:
        return 'Approve Identity';
      case AppPermission.rejectIdentity:
        return 'Reject Identity';
      case AppPermission.approveMedical:
        return 'Approve Medical';
      case AppPermission.rejectMedical:
        return 'Reject Medical';
      case AppPermission.requestMoreInfo:
        return 'Request More Info';
      case AppPermission.viewBloodRequests:
        return 'View Blood Requests';
      case AppPermission.pledgeDonation:
        return 'Pledge Donation';
      case AppPermission.updateAvailability:
        return 'Update Availability';
      case AppPermission.viewMyDonationHistory:
        return 'View My Donation History';
      case AppPermission.postBloodRequest:
        return 'Post Blood Request';
      case AppPermission.viewMyRequestStatus:
        return 'View My Request Status';
      case AppPermission.uploadMedicalProof:
        return 'Upload Medical Proof';
      case AppPermission.closeRequest:
        return 'Close Request';
    }
  }
}
