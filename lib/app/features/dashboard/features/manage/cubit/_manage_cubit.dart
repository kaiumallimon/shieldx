import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/manage/cubit/_manage_state.dart';

class ManageCubit extends Cubit<ManageState> {
  final SupabaseVaultService _vaultService;

  ManageCubit(this._vaultService) : super(ManageInitial());

  Future<void> loadData() async {
    try {
      emit(ManageLoading());

      final total = await _vaultService.getTotalItemsCount();
      final categoryStats = await _vaultService.getCategoryStats();

      emit(ManageLoaded(
        totalPasswords: total,
        categoryCounts: categoryStats,
      ));
    } catch (e) {
      emit(ManageError(e.toString()));
    }
  }
}
