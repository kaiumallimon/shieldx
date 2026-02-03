abstract class SecurityState {}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class SecurityLoaded extends SecurityState {
  final int totalPasswords;
  final int weakPasswords;
  final int reusedPasswords;
  final int breachedPasswords;
  final int strongPasswords;
  final int securityScore;

  SecurityLoaded({
    required this.totalPasswords,
    required this.weakPasswords,
    required this.reusedPasswords,
    required this.breachedPasswords,
    required this.strongPasswords,
    required this.securityScore,
  });
}

class SecurityError extends SecurityState {
  final String message;

  SecurityError(this.message);
}
