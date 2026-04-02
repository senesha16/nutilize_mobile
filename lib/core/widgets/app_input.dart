import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
    super.key,
  });

  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
