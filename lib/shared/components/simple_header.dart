import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutilize/features/auth/shared/presentation/widgets/auth_ui.dart';

class SimpleHeader extends StatelessWidget {
  final String title;
  const SimpleHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final isCompactWidth = MediaQuery.sizeOf(context).width < 420;

    return Column(
      children: [
        Container(
          height: isCompactWidth ? 52 : 56,
          color: AuthPalette.royalBlue,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: isCompactWidth ? 16 : 20),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isCompactWidth ? 18 : 22,
              letterSpacing: isCompactWidth ? 1.0 : 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(height: 4, color: AuthPalette.yellow),
      ],
    );
  }
}
