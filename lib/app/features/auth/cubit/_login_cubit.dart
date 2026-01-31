import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/features/auth/cubit/_auth_states.dart';
import 'package:shieldx/app/features/auth/services/_login_service.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginService _loginService;

  LoginCubit(this._loginService) : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(LoginLoading());

      final result = await _loginService.loginUser(
        email: email,
        password: password,
      );

      emit(LoginSuccess(
        user: result.user,
        session: result.session,
      ));
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _loginService.logout();
      emit(LoginInitial());
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }

  void reset() {
    emit(LoginInitial());
  }
}
