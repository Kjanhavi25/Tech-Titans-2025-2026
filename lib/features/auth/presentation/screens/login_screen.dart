import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.accentColor,
              AppTheme.secondaryColor,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Smart Trolley',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Precision Shopping, Smarter Stores',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Glassmorphic Login Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your details to continue',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                              hintText: 'john@example.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Email is required';
                              if (!AppUtils.isValidEmail(value!)) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_person_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Password is required';
                              if (!AppUtils.isValidPassword(value!)) return 'Too short (min 8 chars)';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Forgot Password?', 
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            final success = await authProvider.login(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text,
                                            );
                                            // Navigation and feedback logic remains same
                                            if (success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Welcome back! 👋'),
                                                  backgroundColor: AppTheme.successColor,
                                                  duration: Duration(seconds: 1),
                                                ),
                                              );
                                              final user = authProvider.currentUser;
                                              if (user != null) {
                                                if (user.role == UserRole.owner) {
                                                  Navigator.of(context).pushReplacementNamed('/owner');
                                                } else if (user.role == UserRole.admin) {
                                                  Navigator.of(context).pushReplacementNamed('/admin');
                                                } else {
                                                  Navigator.of(context).pushReplacementNamed('/home');
                                                }
                                              }
                                            } else if (!success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(authProvider.errorMessage ?? 'Login failed'),
                                                  backgroundColor: AppTheme.errorColor,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    elevation: 8,
                                    shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                      : const Text('SIGN IN'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New to Smart Trolley? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!AppUtils.isValidEmail(value!)) return 'Invalid email';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext);
                final authProvider = context.read<AuthProvider>();
                await authProvider.resetPassword(emailController.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        authProvider.errorMessage != null
                            ? authProvider.errorMessage!
                            : 'Password reset email sent! Check your inbox.',
                      ),
                      backgroundColor: authProvider.errorMessage != null
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                    ),
                  );
                  authProvider.clearError();
                }
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}
