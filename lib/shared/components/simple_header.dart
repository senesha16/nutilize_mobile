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
          height: isCompactWidth ? 54 : 58,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AuthPalette.royalBlueDark, AuthPalette.royalBlue],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: isCompactWidth ? 16 : 20),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isCompactWidth ? 18 : 21,
              letterSpacing: isCompactWidth ? 1.1 : 1.25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(height: 3, color: AuthPalette.yellow),
      ],
    );
  }
}
