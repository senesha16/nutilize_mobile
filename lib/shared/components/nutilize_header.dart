import 'package:flutter/material.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class NutilizeHeader extends StatelessWidget {
  const NutilizeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Column(
      children: [
        Container(
          height: isCompactWidth ? 52 : 56,
          color: AuthPalette.royalBlue,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: isCompactWidth ? 12 : 14),
                child: SizedBox(
                  height: isCompactWidth ? 32 : 36,
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
                padding: EdgeInsets.symmetric(horizontal: isCompactWidth ? 4 : 6),
                child: Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.search,
                      onTap: () {},
                      compact: isCompactWidth,
                    ),
                    SizedBox(width: isCompactWidth ? 8 : 10),
                    Stack(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.notifications,
                          onTap: () {},
                          compact: isCompactWidth,
                        ),
                        Positioned(
                          right: isCompactWidth ? 3 : 4,
                          top: isCompactWidth ? 3 : 4,
                          child: Container(
                            width: isCompactWidth ? 8 : 10,
                            height: isCompactWidth ? 8 : 10,
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
  final bool compact;
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          child: Icon(icon, color: AuthPalette.royalBlue, size: compact ? 20 : 22),
        ),
      ),
    );
  }
}
