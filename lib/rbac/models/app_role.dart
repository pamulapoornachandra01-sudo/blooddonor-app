enum AppRole {
  superAdmin,
  admin,
  verifier,
  donor,
  receiver,
  hospital;

  String get displayName {
    switch (this) {
      case AppRole.superAdmin:
        return 'Super Admin';
      case AppRole.admin:
        return 'Admin';
      case AppRole.verifier:
        return 'Verifier';
      case AppRole.donor:
        return 'Donor';
      case AppRole.receiver:
        return 'Receiver';
      case AppRole.hospital:
        return 'Hospital';
    }
  }

  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => AppRole.donor,
    );
  }
}
