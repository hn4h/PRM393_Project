/// Auth status enum used to control navigation.
enum AuthStatus { initial, authenticated, emailNotConfirmed, unauthenticated }

/// Holds the current authentication state of the app.
class AuthStateModel {
  const AuthStateModel({
    this.status = AuthStatus.initial,
    this.userId,
    this.role,
    this.email,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? role; // 'customer' | 'worker' | 'admin'
  final String? email;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthStateModel copyWith({
    AuthStatus? status,
    String? userId,
    String? role,
    String? email,
    String? errorMessage,
  }) {
    return AuthStateModel(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() =>
      'AuthStateModel(status: $status, role: $role, email: $email)';
}
