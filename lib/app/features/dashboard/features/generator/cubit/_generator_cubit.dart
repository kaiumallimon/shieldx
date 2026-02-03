import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/core/services/password_generator_service.dart';
import 'package:shieldx/app/features/dashboard/features/generator/cubit/_generator_state.dart';

class GeneratorCubit extends Cubit<GeneratorState> {
  GeneratorCubit() : super(GeneratorInitial());

  void generatePassword({
    bool memorableMode = false,
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    String password;

    if (memorableMode) {
      password = PasswordGeneratorService.generateMemorablePassword(
        wordCount: 3,
        includeNumbers: includeNumbers,
        includeSymbols: includeSymbols,
      );
    } else {
      password = PasswordGeneratorService.generatePassword(
        length: length,
        includeUppercase: includeUppercase,
        includeLowercase: includeLowercase,
        includeNumbers: includeNumbers,
        includeSymbols: includeSymbols,
      );
    }

    final strength = PasswordGeneratorService.calculatePasswordStrength(password);

    emit(GeneratorUpdated(password: password, strength: strength));
  }
}
