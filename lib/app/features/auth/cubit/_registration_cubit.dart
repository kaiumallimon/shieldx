import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/features/auth/cubit/_auth_states.dart';
import 'package:shieldx/app/features/auth/services/_registration_service.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final RegistrationService _registrationService;

  RegistrationCubit(this._registrationService) : super(RegistrationInitial());

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
        emit(RegistrationSuccess(
          user: result.user!,
          session: result.session!,
        ));
      } else {
        emit(const RegistrationFailure('Registration failed'));
      }
    } catch (error) {
      emit(RegistrationFailure(error.toString()));
    }
  }

  void reset() {
    emit(RegistrationInitial());
  }
}
