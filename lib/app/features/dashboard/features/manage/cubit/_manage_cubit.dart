import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/manage/cubit/_manage_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageCubit extends Cubit<ManageState> {
  final SupabaseVaultService _vaultService;
  RealtimeChannel? _realtimeSubscription;

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

      // Set up realtime subscription
      _setupRealtimeSubscription();
    } catch (e) {
      emit(ManageError(e.toString()));
    }
  }

  void _setupRealtimeSubscription() {
    // Remove existing subscription if any
    _realtimeSubscription?.unsubscribe();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _realtimeSubscription = Supabase.instance.client
        .channel('manage_vault_items')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vault_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Reload data when any change occurs
            loadData();
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.unsubscribe();
    return super.close();
  }
}
