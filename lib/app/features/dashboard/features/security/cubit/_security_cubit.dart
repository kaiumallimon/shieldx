import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/security/cubit/_security_state.dart';

class SecurityCubit extends Cubit<SecurityState> {
  final SupabaseVaultService _vaultService;

  SecurityCubit(this._vaultService) : super(SecurityInitial());

  Future<void> loadSecurityData() async {
    try {
      emit(SecurityLoading());

      final stats = await _vaultService.getPasswordHealthStats();
      final total = await _vaultService.getTotalItemsCount();

      final strongPasswords = stats['strong'] ?? 0;
      final weakPasswords = stats['weak'] ?? 0;
      final reusedPasswords = stats['reused'] ?? 0;
      final breachedPasswords = stats['breached'] ?? 0;

      // Calculate security score
      int securityScore = 0;
      if (total > 0) {
        final strongPercent = (strongPasswords / total) * 100;
        final weakPercent = (weakPasswords / total) * 100;
        final reusedPercent = (reusedPasswords / total) * 100;
        final breachedPercent = (breachedPasswords / total) * 100;

        securityScore = (strongPercent -
                         (weakPercent * 0.5) -
                         (reusedPercent * 0.8) -
                         (breachedPercent * 1.5))
            .clamp(0, 100)
            .round();
      }

      emit(SecurityLoaded(
        totalPasswords: total,
        strongPasswords: strongPasswords,
        weakPasswords: weakPasswords,
        reusedPasswords: reusedPasswords,
        breachedPasswords: breachedPasswords,
        securityScore: securityScore,
      ));
    } catch (e) {
      emit(SecurityError(e.toString()));
    }
  }
}
