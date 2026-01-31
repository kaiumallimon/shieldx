import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/features/auth/cubit/_auth_states.dart';
import 'package:shieldx/app/features/auth/cubit/_registration_cubit.dart';
import 'package:shieldx/app/features/auth/widgets/_auth_text_field.dart';
import 'package:toastification/toastification.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool acceptTerms = false;

  void toggleAcceptTerms(bool? value) {
    setState(() {
      acceptTerms = value ?? false;
    });
  }

  void _handleRegistration() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      toastification.show(
        context: context,
        title: const Text('Please fill in all fields'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    if (password != confirmPassword) {
      toastification.show(
        context: context,
        title: const Text('Passwords do not match'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    if (!acceptTerms) {
      toastification.show(
        context: context,
        title: const Text('Please accept the terms and conditions'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    context.read<RegistrationCubit>().register(
          name: name,
          email: email,
          password: password,
        );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return BlocListener<RegistrationCubit, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccess) {
          toastification.show(
            context: context,
            title: const Text('Registration successful!'),
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 2),
          );
          context.go('/home');
        } else if (state is RegistrationFailure) {
          toastification.show(
            context: context,
            title: Text(state.error),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20 : 32,
          vertical: 8,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              hint: 'Enter your full name',
              label: 'Full Name',
              controller: nameController,
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              hint: 'Enter your email',
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              hint: 'Enter your password',
              label: 'Password',
              isPassword: true,
              controller: passwordController,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              hint: 'Confirm your password',
              label: 'Confirm Password',
              isPassword: true,
              controller: confirmPasswordController,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => toggleAcceptTerms(!acceptTerms),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: acceptTerms,
                        onChanged: toggleAcceptTerms,
                        fillColor: WidgetStateProperty.resolveWith(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.colorScheme.primary;
                            }
                            return Colors.transparent;
                          },
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withAlpha(40),
                          width: 1.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<RegistrationCubit, RegistrationState>(
              builder: (context, state) {
                final isLoading = state is RegistrationLoading;
                return ElevatedButton(
                  onPressed: (acceptTerms && !isLoading) ? _handleRegistration : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    disabledBackgroundColor:
                        theme.colorScheme.onSurface.withAlpha(40),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CupertinoActivityIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Register',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: acceptTerms
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withAlpha(100),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.onSurface.withAlpha(40),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or continue with',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.onSurface.withAlpha(40),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                // Handle registration with Google
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withAlpha(40),
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: theme.colorScheme.onSurface,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Register with Google',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ));
  }
}
