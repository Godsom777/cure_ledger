import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../screens/home/home_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/hospital_provider.dart';
import '../providers/audit_provider.dart';
import '../repositories/hospital_repository.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/audit_repository.dart';
import '../services/auth_service.dart';

class CureLedgerApp extends StatelessWidget {
  const CureLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        // Hospital provider
        ChangeNotifierProvider(
          create: (_) => HospitalProvider(HospitalRepository()),
        ),
        // Invoice provider
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider(InvoiceRepository()),
        ),
        // Audit provider (Super Admin)
        ChangeNotifierProvider(create: (_) => AuditProvider(AuditRepository())),
      ],
      child: MaterialApp(
        title: 'CureLedger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
