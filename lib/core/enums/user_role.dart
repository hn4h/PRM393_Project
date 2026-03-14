/// User roles in the system.
/// Must match the 'role' column values in Supabase 'profiles' table.
enum UserRole {
  admin,
  customer,
  worker;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.customer,
    );
  }

  bool get isAdmin    => this == UserRole.admin;
  bool get isCustomer => this == UserRole.customer;
  bool get isWorker   => this == UserRole.worker;
}
