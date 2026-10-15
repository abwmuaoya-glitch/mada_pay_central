
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/dependency_mediator.dart';
import 'theme/mada_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/services_screens.dart';

const gold = MadaColors.gold;
const lightGold = MadaColors.lightGold;
const navy = MadaColors.navy;
const deepNavy = MadaColors.deepNavy;
const cardDark = MadaColors.cardDark;

bool _supabaseReady = false;
SupabaseClient? get db => _supabaseReady ? Supabase.instance.client : null;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_KEY');
  if (url.isNotEmpty && key.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: key);
    _supabaseReady = true;
  }
  runApp(const MadaCentralApp());
}

Future<String> getMadaDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  const k = 'mada_pay_installation_device_id';
  final existing = prefs.getString(k);
  if (existing != null && existing.isNotEmpty) return existing;
  final r = math.Random.secure();
  final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final salt = List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
  final created = 'MADA-\$stamp-\$salt';
  await prefs.setString(k, created);
  return created;
}

class MadaCentralApp extends StatefulWidget {
  const MadaCentralApp({super.key});
  @override State<MadaCentralApp> createState() => _MadaCentralAppState();
}
class _MadaCentralAppState extends State<MadaCentralApp> {
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وكالة مدى باي المركزية',
      theme: MadaTheme.darkTheme,
      home: db == null ? const SetupScreen() : const AuthGate(),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(body: Container(
    decoration: const BoxDecoration(gradient: RadialGradient(colors: [Color(0xFF132347), deepNavy], center: Alignment.topCenter, radius: 1.2)),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width:92,height:92,decoration: BoxDecoration(gradient: const LinearGradient(colors: [lightGold, gold]), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.account_balance_wallet, size: 48, color: navy)),
      const SizedBox(height: 18),
      Text('وكالة مدى باي المركزية', style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: lightGold)),
    ])),
  ));
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (context, _) => Supabase.instance.client.auth.currentSession == null ? const LoginScreen(onTheme: {}, dark: true) : const OwnerShell(),
  );
}

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});
  @override State<OwnerShell> createState()=> _OwnerShellState();
}
class _OwnerShellState extends State<OwnerShell> {
  int idx = 2;
  final pages = [
    const TransactionsPage(),
    const UsersManagementPage(),
    const OwnerDashboardPage(),
    const ReportsPage(),
    const ProfilePage(),
  ];
  @override Widget build(BuildContext context){
    return Scaffold(
      body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B35), deepNavy])), child: pages[idx]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: deepNavy, border: Border(top: BorderSide(color: gold.withOpacity(0.22)))),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i)=>setState(()=>idx=i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: deepNavy,
          selectedItemColor: gold,
          unselectedItemColor: Colors.white.withOpacity(0.55),
          selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'المعاملات'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'المستخدمون'),
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home, size: 28), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'التقارير'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'الملف الشخصي'),
          ],
        ),
      ),
    );
  }
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});
  @override Widget build(BuildContext context)=> SafeArea(child: Center(child: Text('المعاملات - مربوطة بـ Supabase', style: GoogleFonts.cairo(color: Colors.white70))));
}
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override Widget build(BuildContext context)=> SafeArea(child: Center(child: Text('التقارير المالية', style: GoogleFonts.cairo(color: Colors.white70))));
}
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context)=> SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(22), border: Border.all(color: gold.withOpacity(0.2))), child: Column(children: [
      const CircleAvatar(radius: 36, backgroundColor: gold, child: Icon(Icons.person, size: 36, color: navy)),
      const SizedBox(height: 10),
      Text('مالك المنظومة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      Text('owner@mada-pay.com', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 14),
      _ProfileTile(icon: Icons.security_outlined, title: 'إعدادات الأمان'),
      _ProfileTile(icon: Icons.notifications_outlined, title: 'الإشعارات'),
      _ProfileTile(icon: Icons.language, title: 'اللغة والمنطقة (SAR)'),
      _ProfileTile(icon: Icons.devices_outlined, title: 'إدارة الأجهزة'),
      _ProfileTile(icon: Icons.backup_outlined, title: 'النسخ الاحتياطي'),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () async { await Supabase.instance.client.auth.signOut(); }, icon: const Icon(Icons.logout, color: Colors.redAccent), label: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.redAccent)), style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.withOpacity(0.4))))),
    ])),
  ])));
}
class _ProfileTile extends StatelessWidget {
  final IconData icon; final String title;
  const _ProfileTile({required this.icon, required this.title});
  @override Widget build(BuildContext context)=> ListTile(leading: Container(width:38,height:38,decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: gold, size: 20)), title: Text(title, style: GoogleFonts.cairo(color: Colors.white, fontSize: 13)), trailing: const Icon(Icons.chevron_right, color: Colors.white38), onTap: (){}, contentPadding: EdgeInsets.zero);
}
