import 'package:flutter/material.dart';
import 'package:nutilize/app/shell/main_shell.dart';
import 'package:nutilize/features/auth/login/presentation/screens/login_screen.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  String _passwordValue = '';
  String _confirmPasswordValue = '';

  bool get _hasMinLength => _passwordValue.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordValue);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordValue);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordValue);
  bool get _hasSpecial => RegExp(r'[^A-Za-z0-9]').hasMatch(_passwordValue);

  int get _strengthScore {
    var score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecial) score++;
    return score;
  }

  String get _strengthLabel {
    if (_passwordValue.isEmpty || _strengthScore <= 1) return 'Weak';
    if (_strengthScore <= 2) return 'Fair';
    if (_strengthScore <= 3) return 'Good';
    return 'Strong';
  }

  int get _strengthBars {
    if (_passwordValue.isEmpty || _strengthScore <= 1) return 1;
    if (_strengthScore <= 2) return 2;
    if (_strengthScore <= 3) return 3;
    return 4;
  }

  Color get _strengthColor {
    switch (_strengthLabel) {
      case 'Fair':
        return const Color(0xFFE9A91F);
      case 'Good':
        return const Color(0xFF3D7EC9);
      case 'Strong':
        return const Color(0xFF2E9E63);
      default:
        return const Color(0xFFCC6E6E);
    }
  }

  bool get _isStrong => _strengthLabel == 'Strong';
  bool get _isConfirmMatched =>
      _confirmPasswordValue.isNotEmpty &&
      _confirmPasswordValue == _passwordValue;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthCard(
        child: Column(
          children: [
            const AuthBrandHeader(),
            const SizedBox(height: 24),
            AuthInput(
              hint: 'Enter your full name',
              icon: Icons.badge_outlined,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            AuthInput(
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            AuthInput(
              hint: 'Choose a username',
              icon: Icons.person_outline,
              controller: _usernameController,
            ),
            const SizedBox(height: 16),
            AuthInput(
              hint: 'Create a password',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              onChanged: (value) {
                setState(() => _passwordValue = value);
              },
              trailing: _isStrong
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8B4D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 19,
                      ),
                    )
                  : null,
            ),
            if (_passwordFocusNode.hasFocus) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: _strengthBars / 4,
                  backgroundColor: const Color(0xFFD5D5D8),
                  valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password strength: $_strengthLabel',
                  style: const TextStyle(
                    color: AuthPalette.royalBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RequirementLine(
                      text: 'At least 8 characters',
                      met: _hasMinLength,
                    ),
                    _RequirementLine(
                      text: 'At least 1 uppercase letter',
                      met: _hasUppercase,
                    ),
                    _RequirementLine(
                      text: 'At least 1 lowercase letter',
                      met: _hasLowercase,
                    ),
                    _RequirementLine(
                      text: 'At least 1 number',
                      met: _hasNumber,
                    ),
                    _RequirementLine(
                      text: 'At least 1 special character',
                      met: _hasSpecial,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            AuthInput(
              hint: 'Confirm your password',
              icon: Icons.shield_outlined,
              obscureText: true,
              controller: _confirmPasswordController,
              onChanged: (value) {
                setState(() => _confirmPasswordValue = value);
              },
              trailing: _isConfirmMatched
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E8B4D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 19,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              text: 'Register',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MainShell.routeName,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
              child: const Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                    color: AuthPalette.royalBlue,
                    fontSize: 34 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementLine extends StatelessWidget {
  const _RequirementLine({required this.text, required this.met});

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF2E9E63) : const Color(0xFF6D79AB);
    final bullet = met ? '✓' : '○';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$bullet   $text',
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
