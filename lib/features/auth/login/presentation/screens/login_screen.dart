import 'package:flutter/material.dart';
import 'package:nutilize/app/shell/main_shell.dart';
import 'package:nutilize/features/auth/data/auth_service.dart';
import 'package:nutilize/features/auth/register/presentation/screens/register_screen.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Clear error on success
      setState(() => _errorMessage = null);

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, MainShell.routeName);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${user.username}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      // Show error message in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthCard(
        child: Column(
          children: [
            const AuthBrandHeader(),
            const SizedBox(height: 34),
            AuthInput(
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              controller: _emailController,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            AuthInput(
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: _passwordController,
              enabled: !_isLoading,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red, width: 0.5),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            AuthPrimaryButton(
              text: _isLoading ? 'Logging in...' : 'Login',
              onPressed: _isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, RegisterScreen.routeName);
                    },
              child: const Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    color: AuthPalette.royalBlue,
                    fontSize: 34 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Create account',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
