abstract class ManageState {}

class ManageInitial extends ManageState {}

class ManageLoading extends ManageState {}

class ManageLoaded extends ManageState {
  final int totalPasswords;
  final Map<String, int> categoryCounts;

  ManageLoaded({
    required this.totalPasswords,
    required this.categoryCounts,
  });
}

class ManageError extends ManageState {
  final String message;

  ManageError(this.message);
}
