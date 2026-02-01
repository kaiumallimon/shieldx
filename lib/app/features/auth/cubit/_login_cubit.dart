import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/features/auth/cubit/_auth_states.dart';
import 'package:shieldx/app/features/auth/services/_google_auth_service.dart';
import 'package:shieldx/app/features/auth/services/_login_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginService _loginService;
  final GoogleAuthService _googleAuthService;
  final AuthStorageService _authStorage;

  LoginCubit(
    this._loginService,
    this._googleAuthService,
    this._authStorage,
  ) : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      emit(LoginLoading());

      final result = await _loginService.loginUser(
        email: email,
        password: password,
      );

      // Store session if remember me is enabled
      if (rememberMe) {
        await _authStorage.saveUserSession(
          userId: result.user.id,
          email: result.user.email ?? email,
          name: result.user.userMetadata?['full_name'] ?? '',
          avatarUrl: result.avatarUrl,
          accessToken: result.session.accessToken,
          refreshToken: result.session.refreshToken ?? '',
          rememberMe: rememberMe,
        );
      }

      emit(LoginSuccess(
        user: result.user,
        session: result.session,
      ));
    } on AuthException catch (e) {
      emit(LoginFailure(e.message));
    } catch (error) {
      emit(LoginFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginWithGoogle({bool rememberMe = true}) async {
    try {
      emit(LoginLoading());

      // This will wait for the OAuth callback automatically
      final result = await _googleAuthService.signInWithGoogle();

      // Store session if remember me is enabled
      if (rememberMe) {
        final fullName = result.user.userMetadata?['full_name'] ??
            result.user.userMetadata?['name'] ??
            result.user.email?.split('@').first ??
            '';

        await _authStorage.saveUserSession(
          userId: result.user.id,
          email: result.user.email ?? '',
          name: fullName,
          avatarUrl: result.avatarUrl,
          accessToken: result.session.accessToken,
          refreshToken: result.session.refreshToken ?? '',
          rememberMe: rememberMe,
        );
      }

      emit(LoginSuccess(
        user: result.user,
        session: result.session,
      ));
    } on AuthException catch (e) {
      emit(LoginFailure(e.message));
    } catch (error) {
      emit(LoginFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    try {
      await _loginService.logout();
      await _authStorage.clearUserSession();
      emit(LoginInitial());
    } on AuthException catch (e) {
      emit(LoginFailure(e.message));
    } catch (error) {
      emit(LoginFailure(error.toString().replaceAll('Exception: ', '')));
    }
  }

  void reset() {
    emit(LoginInitial());
  }
}
