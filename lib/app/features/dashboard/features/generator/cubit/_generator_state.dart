abstract class GeneratorState {}

class GeneratorInitial extends GeneratorState {}

class GeneratorUpdated extends GeneratorState {
  final String password;
  final int strength;

  GeneratorUpdated({
    required this.password,
    required this.strength,
  });
}
