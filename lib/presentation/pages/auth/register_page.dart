import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../widgets/shared/gradus_text_field.dart';
import '../../widgets/shared/gradus_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.slowCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.slowCurve,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    
    // Also validate confirm password if it's not empty
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (confirmPassword != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _signUpWithEmail() {
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_emailError == null && 
        _passwordError == null && 
        _confirmPasswordError == null) {
      context.read<AuthCubit>().createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            authenticated: () {
              // Navigation will be handled by main.dart
            },
            unauthenticated: () {},
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              );
            },
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
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
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Text(
                              'Join Gradus and start building your story',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: AppTheme.textSecondary,
                              ),
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
                                
                                const SizedBox(height: AppTheme.spacing32),
                                
                                // Email Field
                                GradusTextField(
                                  label: 'Email',
                                  hint: 'Enter your email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  errorText: _emailError,
                                  onChanged: _validateEmail,
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                
                                const SizedBox(height: AppTheme.spacing20),
                                
                                // Password Field
                                GradusTextField(
                                  label: 'Password',
                                  hint: 'Create a password (min. 6 characters)',
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  errorText: _passwordError,
                                  onChanged: _validatePassword,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppTheme.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: AppTheme.spacing20),
                                
                                // Confirm Password Field
                                GradusTextField(
                                  label: 'Confirm Password',
                                  hint: 'Confirm your password',
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  errorText: _confirmPasswordError,
                                  onChanged: _validateConfirmPassword,
                                  onSubmitted: (_) => _signUpWithEmail(),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppTheme.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing16,
                                      ),
                                      child: Text(
                                        'or',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
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
                                        'assets/images/google_logo.png',
                                        width: 20,
                                        height: 20,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.login,
                                            size: 20,
                                            color: AppTheme.textPrimary,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppTheme.spacing24),
                        
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                'Sign In',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
