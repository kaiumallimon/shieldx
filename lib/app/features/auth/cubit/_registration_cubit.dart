import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/features/auth/cubit/_auth_states.dart';
import 'package:shieldx/app/features/auth/services/_google_auth_service.dart';
import 'package:shieldx/app/features/auth/services/_registration_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final RegistrationService _registrationService;
  final GoogleAuthService _googleAuthService;
  final AuthStorageService _authStorage;

  RegistrationCubit(
    this._registrationService,
    this._googleAuthService,
    this._authStorage,
  ) : super(RegistrationInitial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(RegistrationLoading());

      final result = await _registrationService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (result.user != null && result.session != null) {
        // Always store session for registration (auto-login with remember me)
        await _authStorage.saveUserSession(
          userId: result.user!.id,
          email: result.user!.email ?? email,
          name: name,
          accessToken: result.session!.accessToken,
          refreshToken: result.session!.refreshToken ?? '',
          rememberMe: true,
        );

        emit(RegistrationSuccess(
          user: result.user!,
          session: result.session!,
        ));
      } else {
        emit(const RegistrationFailure('Registration failed'));
      }
    } on AuthException catch (e) {
      emit(RegistrationFailure(e.message));
    } catch (error) {
      emit(RegistrationFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> registerWithGoogle() async {
    try {
      emit(RegistrationLoading());

      // This will wait for the OAuth callback automatically
      final result = await _googleAuthService.signInWithGoogle();

      // Always store session for registration (auto-login with remember me)
      final fullName = result.user.userMetadata?['full_name'] ??
          result.user.userMetadata?['name'] ??
          result.user.email?.split('@').first ??
          '';

      await _authStorage.saveUserSession(
        userId: result.user.id,
        email: result.user.email ?? '',
        name: fullName,
        accessToken: result.session.accessToken,
        refreshToken: result.session.refreshToken ?? '',
        rememberMe: true,
      );

      emit(RegistrationSuccess(
        user: result.user,
        session: result.session,
      ));
    } on AuthException catch (e) {
      emit(RegistrationFailure(e.message));
    } catch (error) {
      emit(RegistrationFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(RegistrationInitial());
  }
}
