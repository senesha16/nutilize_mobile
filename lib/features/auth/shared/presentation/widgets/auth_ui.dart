import 'package:flutter/material.dart';

class AuthPalette {
  static const royalBlue = Color(0xFF34479A);
  static const royalBlueDark = Color(0xFF2F3F8E);
  static const royalBlueLight = Color(0xFF5A6FC6);
  static const yellow = Color(0xFFF2C318);
  static const pageLight = Color(0xFFE9ECF4);
  static const cardLight = Color(0xFFF1F3F8);
  static const inputBorder = Color(0xFFCCD4E4);
  static const hint = Color(0xFF8C99C3);
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AuthPalette.pageLight, Color(0xFFF3F4F8)],
              ),
            ),
          ),
          const _TopHeader(),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            isCompactWidth ? 18 : 24,
                            16,
                            24,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: Stack(
        children: [
          Container(color: AuthPalette.royalBlue),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 4, color: AuthPalette.yellow),
          ),
          Positioned(
            right: 220,
            top: 96,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuthPalette.yellow.withValues(alpha: 0.28),
                    blurRadius: 62,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Container(
      width: MediaQuery.sizeOf(context).width >= 1024 ? 600 : double.infinity,
      padding: EdgeInsets.fromLTRB(
        isCompactWidth ? 20 : 32,
        isCompactWidth ? 20 : 28,
        isCompactWidth ? 20 : 32,
        isCompactWidth ? 18 : 24,
      ),
      decoration: BoxDecoration(
        color: AuthPalette.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8DEEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Column(
      children: [
        SizedBox(
          height: isCompactWidth ? 54 : 64,
          child: Image.asset(
            'assets/images/nutilize_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'NUTILIZE',
                style: TextStyle(
                  color: AuthPalette.royalBlue,
                  fontSize: isCompactWidth ? 36 : 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.1,
                ),
              );
            },
          ),
        ),
        SizedBox(height: isCompactWidth ? 8 : 10),
        Text(
          'Campus Resource & Reservation Management System',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthPalette.royalBlue,
            fontSize: isCompactWidth ? 15 : 38 / 2,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class AuthInput extends StatelessWidget {
  const AuthInput({
    required this.hint,
    required this.icon,
    this.controller,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.trailing,
    this.obscureText = false,
    this.enabled = true,
    super.key,
  });

  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final Widget? trailing;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Container(
      height: isCompactWidth ? 46 : 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AuthPalette.inputBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: isCompactWidth ? 48 : 52,
            color: AuthPalette.yellow,
            alignment: Alignment.center,
            child: Icon(icon, size: isCompactWidth ? 19 : 21, color: Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: enabled ? onTap : null,
              focusNode: focusNode,
              obscureText: obscureText,
              enabled: enabled,
              style: TextStyle(
                color: AuthPalette.royalBlue,
                fontSize: isCompactWidth ? 15 : 33 / 2,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: isCompactWidth ? 12 : 14),
                hintText: hint,
                hintStyle: TextStyle(
                  color: AuthPalette.hint.withOpacity(enabled ? 1.0 : 0.6),
                  fontSize: isCompactWidth ? 15 : 33 / 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (trailing != null)
            Container(
              width: isCompactWidth ? 52 : 58,
              color: AuthPalette.yellow,
              alignment: Alignment.center,
              child: trailing,
            ),
        ],
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return SizedBox(
      width: double.infinity,
      height: isCompactWidth ? 52 : 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AuthPalette.royalBlue, AuthPalette.royalBlueLight],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3A2B3B8F),
              blurRadius: 13,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isCompactWidth ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
