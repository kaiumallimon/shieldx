import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/core/config/_router.dart';
import 'package:shieldx/app/core/themes/_app_theme.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/auth/cubit/_login_cubit.dart';
import 'package:shieldx/app/features/auth/cubit/_registration_cubit.dart';
import 'package:shieldx/app/features/auth/services/_google_auth_service.dart';
import 'package:shieldx/app/features/auth/services/_login_service.dart';
import 'package:shieldx/app/features/auth/services/_registration_service.dart';
import 'package:shieldx/app/features/dashboard/features/manage/cubit/_manage_cubit.dart';
import 'package:shieldx/app/features/dashboard/features/security/cubit/_security_cubit.dart';
import 'package:shieldx/app/features/dashboard/features/generator/cubit/_generator_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(
            LoginService(),
            GoogleAuthService(),
            AuthStorageService(),
          ),
        ),
        BlocProvider(
          create: (context) => RegistrationCubit(
            RegistrationService(),
            GoogleAuthService(),
            AuthStorageService(),
          ),
        ),
        BlocProvider(
          create: (context) => ManageCubit(SupabaseVaultService()),
        ),
        BlocProvider(
          create: (context) => SecurityCubit(SupabaseVaultService()),
        ),
        BlocProvider(
          create: (context) => GeneratorCubit(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
