import 'package:flutter/material.dart';
import '../theme/mada_luxury_theme.dart';

/// UI shell for owner/admin pages. This widget does not grant permissions:
/// pass `role` only after validating it from the trusted auth/database layer.
class MadaAdminShell extends StatefulWidget {
  const MadaAdminShell({
    super.key,
    required this.role,
    this.onSignOut,
  });

  final String role;
  final VoidCallback? onSignOut;

  @override
  State<MadaAdminShell> createState() => _MadaAdminShellState();
}

class _MadaAdminShellState extends State<MadaAdminShell> {
  int _index = 0;

  bool get _allowed {
    final normalized = widget.role.trim().toUpperCase();
    return normalized == 'OWNER' ||
        normalized == 'ADMIN' ||
        normalized == 'SUPER_ADMIN';
  }

  static const _sections = <_AdminSection>[
    _AdminSection('الرئيسية', Icons.home_rounded, Icons.home_outlined),
    _AdminSection('المستخدمون', Icons.groups_rounded, Icons.groups_outlined),
    _AdminSection('المعاملات', Icons.receipt_long_rounded, Icons.receipt_long_outlined),
    _AdminSection('التقارير', Icons.bar_chart_rounded, Icons.bar_chart_outlined),
    _AdminSection('الملف الشخصي', Icons.person_rounded, Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_allowed) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 56, color: MadaLuxuryTheme.gold),
                  const SizedBox(height: 16),
                  const Text('ليس لديك صلاحية الوصول إلى لوحة الإدارة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('يرجى تسجيل الدخول بحساب مخوّل.',
                      style: TextStyle(color: MadaLuxuryTheme.muted)),
                  const SizedBox(height: 20),
                  OutlinedButton(onPressed: widget.onSignOut, child: const Text('تسجيل الخروج')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('وكالة مدى باي المركزية',
              style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: () => _showMessage('ستُربط الإشعارات بمصدرها الفعلي لاحقاً.'),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              tooltip: 'الإعدادات',
              onPressed: () => setState(() => _index = 5),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.35,
              colors: [Color(0xFF1D2A3C), MadaLuxuryTheme.navy],
            ),
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _pageForIndex(_index),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index > 4 ? 0 : _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: _sections.map((item) => NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          )).toList(),
        ),
      ),
    );
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 1:
        return const _PlaceholderPage(
          key: ValueKey('users'),
          title: 'إدارة المستخدمين',
          subtitle: 'البحث والمراجعة وإدارة حالة الحساب والصلاحيات',
          icon: Icons.groups_rounded,
          items: ['قائمة المستخدمين', 'طلبات التسجيل', 'الأدوار والصلاحيات'],
        );
      case 2:
        return const _PlaceholderPage(
          key: ValueKey('transactions'),
          title: 'المعاملات',
          subtitle: 'عرض المعاملات وحالاتها من قاعدة البيانات الفعلية',
          icon: Icons.receipt_long_rounded,
          items: ['سجل المعاملات', 'التحويلات', 'السحب والإيداع'],
        );
      case 3:
        return const _PlaceholderPage(
          key: ValueKey('reports'),
          title: 'التقارير',
          subtitle: 'ملخصات وتقارير مالية وفق صلاحية المستخدم',
          icon: Icons.bar_chart_rounded,
          items: ['ملخص النشاط', 'تقارير المعاملات', 'تقارير الخدمات'],
        );
      case 4:
        return const _PlaceholderPage(
          key: ValueKey('profile'),
          title: 'الملف الشخصي',
          subtitle: 'بيانات الحساب وإعدادات الجلسة',
          icon: Icons.person_rounded,
          items: ['بيانات الحساب', 'تغيير كلمة المرور', 'الجلسات النشطة'],
        );
      case 5:
        return const _PlaceholderPage(
          key: ValueKey('settings'),
          title: 'إعدادات التطبيق',
          subtitle: 'إعدادات الأمان واللغة والإشعارات والربط',
          icon: Icons.settings_rounded,
          items: ['إعدادات الأمان', 'الإشعارات', 'اللغة والمنطقة', 'إدارة الأجهزة', 'النسخ الاحتياطي', 'واجهات الربط API'],
        );
      default:
        return const _DashboardPage(key: ValueKey('dashboard'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AdminSection {
  const _AdminSection(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text('مرحباً بك في لوحة الإدارة',
            style: TextStyle(color: MadaLuxuryTheme.gold, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('إدارة خدمات الدفع الرقمي من مكان واحد',
            style: TextStyle(color: MadaLuxuryTheme.cyan, fontSize: 14)),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(title: 'عدد المستخدمين', value: '—', caption: 'من قاعدة البيانات', icon: Icons.groups_rounded),
            _MetricCard(title: 'إجمالي المعاملات', value: '—', caption: 'المعاملات المسجلة', icon: Icons.swap_horiz_rounded),
            _MetricCard(title: 'الرصيد الإجمالي', value: '—', caption: 'حسب الصلاحيات', icon: Icons.account_balance_wallet_rounded),
            _MetricCard(title: 'نشاط اليوم', value: '—', caption: 'آخر تحديث من الخادم', icon: Icons.trending_up_rounded),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionCard(
          title: 'الإجراءات السريعة',
          subtitle: 'تظهر هذه الاختصارات الواجهات فقط؛ تنفيذ العمليات يحتاج ربطاً آمناً بالخادم.',
          icon: Icons.bolt_rounded,
          children: [
            _QuickAction(icon: Icons.people_alt_rounded, label: 'المستخدمون'),
            _QuickAction(icon: Icons.receipt_long_rounded, label: 'المعاملات'),
            _QuickAction(icon: Icons.hub_rounded, label: 'ربط API'),
            _QuickAction(icon: Icons.settings_rounded, label: 'الإعدادات'),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionCard(
          title: 'آخر الأنشطة',
          subtitle: 'ستظهر البيانات بعد ربط هذا القسم باستعلامات قاعدة البيانات المحمية.',
          icon: Icons.history_rounded,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.shield_outlined, color: MadaLuxuryTheme.gold),
              title: Text('حماية البيانات أولاً'),
              subtitle: Text('لا يتم عرض معاملات أو أرصدة تجريبية على أنها بيانات حقيقية.'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.caption, required this.icon});
  final String title;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 44) / 2,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: MadaLuxuryTheme.gold, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: MadaLuxuryTheme.cyan, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: MadaLuxuryTheme.gold, fontSize: 25, fontWeight: FontWeight.w900)),
          Text(caption, style: const TextStyle(color: MadaLuxuryTheme.muted, fontSize: 11)),
        ]),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.icon, required this.children});
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: MadaLuxuryTheme.gold),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: MadaLuxuryTheme.muted, fontSize: 12)),
        const SizedBox(height: 12),
        ...children,
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 80) / 2,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: MadaLuxuryTheme.gold,
          side: BorderSide(color: MadaLuxuryTheme.gold.withValues(alpha: .45)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Icon(icon, color: MadaLuxuryTheme.gold, size: 48),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: MadaLuxuryTheme.gold)),
      const SizedBox(height: 8),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: MadaLuxuryTheme.cyan)),
      const SizedBox(height: 22),
      ...items.map((item) => Card(
        child: ListTile(
          leading: const Icon(Icons.arrow_back_ios_new_rounded, color: MadaLuxuryTheme.gold, size: 18),
          title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_left_rounded, color: MadaLuxuryTheme.muted),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('واجهة $item تحتاج ربطها بالخدمة الفعلية.')),
          ),
        ),
      )),
      const SizedBox(height: 12),
      const Text(
        'هذه بنية واجهة أولية آمنة. لا تُنفّذ عمليات مالية ولا تعرض بيانات وهمية.',
        textAlign: TextAlign.center,
        style: TextStyle(color: MadaLuxuryTheme.muted, fontSize: 12),
      ),
    ],
  );
}
