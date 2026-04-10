import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this line!
import 'package:nutilize/app/app.dart';

void main() async {
  // 1. This makes sure the app is ready to talk to the database before starting
  WidgetsFlutterBinding.ensureInitialized();

  // 2. This connects your app to the Supabase project your friend made
  await Supabase.initialize(
    url: 'https://uszlgigsuseomkwmqwan.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzemxnaWdzdXNlb21rd21xd2FuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1MDM5OTAsImV4cCI6MjA5MDA3OTk5MH0.XjNGiVTnq03gA8MSxeG8udWAnaqXfz_zuNFpNXZzKWk',
  );

  // 3. This starts your actual NUtilize app
  runApp(const NutilizeApp());
}