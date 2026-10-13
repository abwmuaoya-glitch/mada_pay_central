import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _anim;
  bool remember = false;
  bool hidePass = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                painter: LightPainter(_anim.value),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -6 * math.sin(_anim.value * 2 * math.pi),
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFE27B), Color(0xFFD4A017)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.5),
                            blurRadius: 25,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 55,
                        color: Color(0xFF070E1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "وكالة مدى باي المركزية",
                    style: AppTheme.agencyName,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "للحلول المالية وخدمات الدفع الرقمي",
                    style: AppTheme.sub1,
                  ),
                  const SizedBox(height: 3),
