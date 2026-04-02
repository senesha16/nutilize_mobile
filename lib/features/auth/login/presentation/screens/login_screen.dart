import 'package:flutter/material.dart';
import 'package:nutilize/app/shell/main_shell.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              hint: 'Enter your username',
              icon: Icons.person_outline,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            AuthInput(
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              text: 'Login',
              onPressed: () {
                Navigator.pushReplacementNamed(context, MainShell.routeName);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
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
