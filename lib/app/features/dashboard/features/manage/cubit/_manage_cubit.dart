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

      // Get all items to count by credential type
      final allItems = await _vaultService.getAllVaultItems();
      final typeCounts = <String, int>{
        'login': allItems.length,
        'api-key': 0,
        'credit-card': 0,
        'note': 0,
        'identity': 0,
      };

      emit(ManageLoaded(
        totalPasswords: total,
        categoryCounts: categoryStats,
        typeCounts: typeCounts,
      ));
    } catch (e) {
      emit(ManageError(e.toString()));
    }
  }
}
