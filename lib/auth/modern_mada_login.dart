import 'package:flutter/material.dart';

class ModernMadaLogin extends StatefulWidget {
  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onCreateAccount;

  const ModernMadaLogin({
    super.key,
    required this.onLogin,
    this.onForgotPassword,
    this.onCreateAccount,
  });

  @override
  State<ModernMadaLogin> createState() => _ModernMadaLoginState();
}

class _ModernMadaLoginState extends State<ModernMadaLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _showPassword = false;
  bool _rememberMe = true;
  bool _loading = false;

  static const double _designWidth = 694;
  static const double _designHeight = 2048;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.onLogin(email, password);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تسجيل الدخول. تحقق من بياناتك وحاول مجددًا.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050D19),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = width / _designWidth;
          final height = _designHeight * scale;

          return SingleChildScrollView(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // الصورة الأصلية دون قص أو تغيير في نسب أبعادها.
                  Positioned.fill(
                    child: Image.asset(
                      'assets/mada_login_design.jpg',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // حقل البريد الإلكتروني أو رقم الهاتف.
                  Positioned(
                    left: width * (86 / _designWidth),
                    top: height * (764 / _designHeight),
                    width: width * (522 / _designWidth),
                    height: height * (99 / _designHeight),
                    child: _buildInput(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hint: 'البريد الإلكتروني أو رقم الهاتف',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_passwordFocus);
                      },
                    ),
                  ),

                  // حقل كلمة المرور.
                  Positioned(
                    left: width * (86 / _designWidth),
                    top: height * (897 / _designHeight),
                    width: width * (522 / _designWidth),
                    height: height * (94 / _designHeight),
                    child: _buildInput(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hint: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFFFD76A),
                        ),
                      ),
                    ),
                  ),

                  // زر تذكرني.
                  Positioned(
                    left: width * (91 / _designWidth),
                    top: height * (1020 / _designHeight),
                    width: width * (190 / _designWidth),
                    height: height * (54 / _designHeight),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() => _rememberMe = !_rememberMe);
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFFEAC45C),
                            checkColor: const Color(0xFF071326),
                            side: const BorderSide(
                              color: Color(0xFFFFD76A),
                            ),
                          ),
                          const Flexible(
                            child: Text(
                              'تذكرني',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // نسيت كلمة المرور؟
                  Positioned(
                    right: width * (80 / _designWidth),
                    top: height * (1020 / _designHeight),
                    width: width * (190 / _designWidth),
                    height: height * (54 / _designHeight),
                    child: TextButton(
                      onPressed: widget.onForgotPassword,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: Color(0xFF8EF4FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // زر تسجيل الدخول.
                  Positioned(
                    left: width * (87 / _designWidth),
                    top: height * (1102 / _designHeight),
                    width: width * (521 / _designWidth),
                    height: height * (96 / _designHeight),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _loading ? null : _login,
                        borderRadius: BorderRadius.circular(20 * scale),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF071326),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),

                  // عبارة التطوير أسفل الشاشة.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: height * (1870 / _designHeight),
                    child: const Center(
                      child: Text(
                        'تطوير م/ راضي الشبيبي',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Color(0xFFFFD76A),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFFFD76A),
          ),
          suffixIcon: suffix,
filled: true,
fillColor: const Color(0xFF10213A).withOpacity(0.96),
contentPadding: const EdgeInsets.symmetric(
  horizontal: 15,
  vertical: 20,
),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFFFD76A),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFFFD76A),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFF73DFFF),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
