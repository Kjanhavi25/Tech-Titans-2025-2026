import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.user;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your account to start shopping',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Glassmorphic Signup Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_rounded),
                              hintText: 'John Doe',
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Name is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
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
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_iphone_rounded),
                              hintText: '1234567890',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Phone is required';
                              if (!AppUtils.isValidPhoneNumber(value!)) return 'Invalid phone (10 digits)';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
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
                              if (value?.isEmpty ?? true) return 'Required';
                              if (!AppUtils.isValidPassword(value!)) return 'Min 8 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.verified_user_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Account Type',
                              prefixIcon: Icon(Icons.badge_rounded),
                            ),
                            items: UserRole.values.where((role) => role != UserRole.admin).map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.toString().split('.').last.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedRole = value!),
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
                                            final success = await authProvider.signup(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text,
                                              name: _nameController.text.trim(),
                                              phoneNumber: _phoneController.text.trim(),
                                              role: _selectedRole,
                                            );
                                            if (success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Registration successful! 👋'),
                                                  backgroundColor: AppTheme.successColor,
                                                  duration: Duration(seconds: 1),
                                                ),
                                              );
                                              if (_selectedRole == UserRole.owner) {
                                                Navigator.of(context).pushReplacementNamed('/owner');
                                              } else {
                                                Navigator.of(context).pushReplacementNamed('/home');
                                              }
                                            } else if (!success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(authProvider.errorMessage ?? 'Signup failed'),
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
                                      : const Text('CREATE ACCOUNT'),
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
                        "Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w900)),
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
}
