import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../widgets/shared/gradus_text_field.dart';
import '../../widgets/shared/gradus_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            authenticated: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.timeline);
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                ),
              );
            },
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Section
                    Column(
                      children: [
                        Text(
                          'Create Account',
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Join Gradus and start building your story',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacing40),

                    // Register Form
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing32),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: AppTheme.subtleShadow,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: AppTheme.spacing8),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppTheme.textSecondary),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                                  child: Text(
                                    'Sign In',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacing32),

                            // Email Field
                            GradusTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              errorText: _emailError,
                              prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                            ),

                            const SizedBox(height: AppTheme.spacing20),

                            // Password Field
                            GradusTextField(
                              label: 'Password',
                              hint: 'Min. 6 characters',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              errorText: _passwordError,
                              onSubmitted: (_) => _signUpWithEmail(),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: AppTheme.spacing32),

                            // Sign Up Button
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return GradusButton.primary(
                                  text: 'Create Account',
                                  isFullWidth: true,
                                  isLoading: state.isLoading,
                                  onPressed: state.isLoading ? null : _signUpWithEmail,
                                );
                              },
                            ),

                            const SizedBox(height: AppTheme.spacing20),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                                  child: Text(
                                    'or',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacing20),

                            // Google Sign In Button
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return GradusButton.social(
                                  text: 'Continue with Google',
                                  isFullWidth: true,
                                  isLoading: state.isLoading,
                                  onPressed: state.isLoading ? null : _signInWithGoogle,
                                  icon: Image.asset(
                                    'images/google_logo.webp',
                                    width: 20,
                                    height: 20,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.login, size: 20, color: AppTheme.textPrimary);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  void _signUpWithEmail() {
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    if (_emailError == null && _passwordError == null) {
      context.read<AuthCubit>().createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthCubit>().signInWithGoogle();
  }
}
