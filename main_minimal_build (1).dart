
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const gold = Color(0xFFD4AF37);
const lightGold = Color(0xFFF5E6A3);
const deepNavy = Color(0xFF020611);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_KEY');
  if (url.isNotEmpty && key.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: key);
  }
  runApp(const MadaApp());
}

class MadaApp extends StatelessWidget {
  const MadaApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وكالة مدى باي',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepNavy,
        colorScheme: const ColorScheme.dark(primary: lightGold, secondary: gold),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: \$e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2B4A), deepNavy],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [lightGold, gold]),
                  ),
                  child: const Icon(Icons.account_balance_wallet, size: 50, color: Color(0xFF5A4010)),
                ),
                const SizedBox(height: 20),
                const Text('وكالة مدى باي المركزية', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: lightGold)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('تسجيل الدخول', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightGold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailC,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'البريد الالكتروني',
                          prefixIcon: const Icon(Icons.person, color: gold),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passC,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock, color: gold),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : _login,
                          style: ElevatedButton.styleFrom(backgroundColor: lightGold, foregroundColor: deepNavy),
                          child: loading ? const CircularProgressIndicator() : const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                    } catch (_) {}
                  },
                  child: const Text('تسجيل خروج', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
