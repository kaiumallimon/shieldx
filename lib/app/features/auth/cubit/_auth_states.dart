import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final Session session;

  const AuthAuthenticated({
    required this.user,
    required this.session,
  });

  @override
  List<Object?> get props => [user, session];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Login State
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;
  final Session session;

  const LoginSuccess({
    required this.user,
    required this.session,
  });

  @override
  List<Object?> get props => [user, session];
}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// Registration State
abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final User user;
  final Session session;

  const RegistrationSuccess({
    required this.user,
    required this.session,
  });

  @override
  List<Object?> get props => [user, session];
}

class RegistrationFailure extends RegistrationState {
  final String error;

  const RegistrationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
