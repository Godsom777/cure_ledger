import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/app/app.dart';
import 'src/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Set system UI overlay style for a clean, Apple-like appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFE5E5E5),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CureLedgerApp());
}
