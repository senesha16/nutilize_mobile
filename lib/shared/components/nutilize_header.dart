import 'package:flutter/material.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class NutilizeHeader extends StatelessWidget {
  const NutilizeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          color: AuthPalette.royalBlue,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: SizedBox(
                  height: 36,
                  child: Image.asset(
                    'assets/images/nutilize_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'NU TILIZE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    _HeaderIconButton(icon: Icons.search, onTap: () {}),
                    const SizedBox(width: 10),
                    Stack(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.notifications,
                          onTap: () {},
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 4, color: AuthPalette.yellow),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AuthPalette.royalBlue, size: 22),
        ),
      ),
    );
  }
}
