import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/core/config/_router.dart';
import 'package:shieldx/app/core/themes/_app_theme.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/features/auth/cubit/_login_cubit.dart';
import 'package:shieldx/app/features/auth/cubit/_registration_cubit.dart';
import 'package:shieldx/app/features/auth/services/_login_service.dart';
import 'package:shieldx/app/features/auth/services/_registration_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(
            LoginService(),
            AuthStorageService(),
          ),
        ),
        BlocProvider(
          create: (context) => RegistrationCubit(
            RegistrationService(),
            AuthStorageService(),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}