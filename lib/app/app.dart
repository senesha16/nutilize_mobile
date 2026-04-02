import 'package:flutter/material.dart';
import 'package:nutilize/app/shell/main_shell.dart';
import 'package:nutilize/core/design/app_theme.dart';
import 'package:nutilize/features/auth/login/presentation/screens/login_screen.dart';
import 'package:nutilize/features/auth/register/presentation/screens/register_screen.dart';

class NutilizeApp extends StatelessWidget {
  const NutilizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutilize',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        MainShell.routeName: (context) => const MainShell(),
      },
    );
  }
}
