import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _anim;
  bool remember = false;
  bool hidePass = true;

  @override
  void initState(){
    _anim = AnimationController(vsync: this, duration: Duration(seconds: 3))..repeat(reverse: true);
    super.initState();
  }
  @override void dispose(){ _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // الخلفية المتحركة - خطوط ذهبية وزرقاء
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(painter: LightPainter(_anim.value))
            )
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // المحفظة الذهبية
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, -6 * math.sin(_anim.value * 2 * math.pi)),
                      child: child
                    ),
                    child: Image.asset('assets/wallet_gold.png', width: 130, height: 90, errorBuilder: (_, __, ___) => 
                      Icon(Icons.account_balance_wallet, size: 90, color: AppTheme.gold)),
                  ),
                  SizedBox(height: 12),
                  // النصوص الثلاثة
                  Text("وكالة مدى باي المركزية", style: AppTheme.agencyName, textAlign: TextAlign.center),
                  SizedBox(height: 6),
                  Text("للحلول المالية وخدمات الدفع الرقمي", style: AppTheme.sub1),
                  SizedBox(height: 3),
                  Text("وخدمات التطبيقات والألعاب والرصيد", style: AppTheme.sub2),
                  SizedBox(height: 20),
                  // كرت تسجيل الدخول
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: AppTheme.glassCardDecoration,
                    child: Column(
                      children: [
                        Text("تسجيل الدخول", style: AppTheme.loginTitle),
                        SizedBox(height: 6),
                        Text("مرحباً! أدخل بياناتك للوصول إلى لوحة التحكم", 
                          style: TextStyle(color: AppTheme.whiteDim, fontSize: 10, fontFamily: 'Cairo'), textAlign: TextAlign.center),
                        SizedBox(height: 18),
                        // حقل البريد
                        Container(
                          decoration: AppTheme.textFieldDecoration,
                          child: TextField(
                            style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: AppTheme.goldLight, size: 20),
                              hintText: "البريد الإلكتروني أو رقم الهاتف",
                              hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14)
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // حقل كلمة المرور
                        Container(
                          decoration: AppTheme.textFieldDecoration,
                          child: TextField(
                            obscureText: hidePass,
                            style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.goldLight, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(hidePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, 
                                  color: AppTheme.goldLight, size: 20),
                                onPressed: () => setState(()=> hidePass = !hidePass)
                              ),
                              hintText: "كلمة المرور",
                              hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14)
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // تذكرني + نسيت
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Checkbox(value: remember, onChanged: (v)=>setState(()=>remember=v!), 
                                activeColor: AppTheme.gold, side: BorderSide(color: AppTheme.gold)),
                              Text("تذكرني", style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Cairo'))
                            ]),
                            Text("نسيت كلمة المرور؟", style: TextStyle(color: AppTheme.cyanLight, fontSize: 11, fontFamily: 'Cairo'))
                          ],
                        ),
                        SizedBox(height: 10),
                        // زر تسجيل الدخول
                        Container(
                          width: double.infinity, height: 48,
                          decoration: AppTheme.goldButtonDecoration,
                          child: Center(
                            child: Text("تسجيل الدخول  ->", 
                              style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'))
                          ),
                        ),
                        SizedBox(height: 14),
                        // أو المتابعة عبر
                        Row(children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), 
                            child: Text("أو المتابعة عبر", style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Cairo'))),
                          Expanded(child: Divider(color: Colors.white24)),
                        ]),
                        SizedBox(height: 12),
                        // أزرار Apple - G - بصمة
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _circleBtn(Icons.apple),
                          SizedBox(width: 10),
                          _circleBtn(Icons.g_mobiledata),
                          SizedBox(width: 10),
                          _circleBtn(Icons.fingerprint),
                        ])
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  Text("تطوير م. راضي الشبيبي", style: TextStyle(color: AppTheme.goldLight.withOpacity(0.8), fontSize: 11, fontFamily: 'Cairo')),
                  SizedBox(height: 4),
                  Text("وكالة مدى باي • جميع الحقوق محفوظة ©", style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Cairo')),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon){
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: AppTheme.borderGold.withOpacity(0.4))
      ),
      child: Icon(icon, color: AppTheme.goldLight, size: 22),
    );
  }
}

class LightPainter extends CustomPainter {
  final double v; LightPainter(this.v);
  @override void paint(Canvas c, Size s){
    final p = Paint()..color = Color(0xFFFFD700).withOpacity(0.2)..style=PaintingStyle.stroke..strokeWidth=1.2;
    final path = Path()..moveTo(0, s.height*0.4)..quadraticBezierTo(s.width*0.5, s.height*0.5 + 40*v, s.width, s.height*0.35);
    c.drawPath(path, p);
  }
  @override bool shouldRepaint(old)=>true;
}
