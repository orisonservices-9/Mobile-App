import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/auth_bloc.dart';
import '../state/parent_bloc.dart';
import 'parent_pages.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => BlocConsumer<ParentBloc, ParentState>(
        listenWhen: (a, b) => b is ParentReady && b.message != null,
        listener: (context, state) {
          if (state is ParentReady && state.message != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state is ParentLoading || state is ParentInitial) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (state is ParentFailure) {
            return Scaffold(
                body: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              TextButton(
                  onPressed: () =>
                      context.read<ParentBloc>().add(ParentLoaded()),
                  child: const Text('Retry'))
            ])));
          }
          final ready = state as ParentReady;
          final pages = [
            DashboardPage(data: ready),
            const AcademicsPage(),
            const FeesPage(),
            const MorePage()
          ];
          return Scaffold(
            appBar: AppBar(
              title: const Text('ORISON',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              actions: [
                IconButton(
                    tooltip: 'School notices',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage())),
                    icon: Badge(
                        label: Text(
                            '${ready.data.notices.where((e) => e.unread).length}'),
                        child: const Icon(Icons.notifications_none_rounded))),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
                const SizedBox(width: 6)
              ],
            ),
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: 'Academics'),
                NavigationDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet),
                    label: 'Fees'),
                NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view),
                    label: 'More'),
              ],
            ),
          );
        },
      );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.watch<ParentBloc>().state as ParentReady;
    final pendingHomework =
        ready.data.homework.where((item) => !item.completed).length;
    final unread = ready.data.notices.where((item) => item.unread).length;
    final learning = <_MoreService>[
      const _MoreService(
          Icons.school_rounded,
          'Academics',
          'Performance & insights',
          Color(0xFF3157C8),
          _MoreModulePage(title: 'Academics', child: AcademicsPage())),
      const _MoreService(Icons.fact_check_rounded, 'Attendance',
          'Calendar & trends', Color(0xFF07966C), AttendancePage()),
      const _MoreService(Icons.edit_note_rounded, 'Homework',
          'Track work status', Color(0xFF5B52D9), HomeworkPage()),
      const _MoreService(Icons.calendar_month_rounded, 'Timetable',
          'Daily class plan', Color(0xFFDB2777), TimetablePage()),
      const _MoreService(Icons.assignment_rounded, 'Exams',
          'Schedule & results', Color(0xFFE56B38), ExamsPage()),
      const _MoreService(Icons.compare_arrows_rounded, 'Compare exams',
          'Progress comparison', Color(0xFF7C3AED), ExamComparisonPage()),
    ];
    final services = <_MoreService>[
      const _MoreService(Icons.badge_rounded, 'Hall tickets',
          'Current & previous', Color(0xFF0891B2), HallTicketsPage()),
      const _MoreService(
          Icons.account_balance_wallet_rounded,
          'Fees',
          'Payments & receipts',
          Color(0xFFC4141B),
          _MoreModulePage(title: 'Fees', child: FeesPage())),
      const _MoreService(Icons.medical_information_rounded, 'Apply leave',
          'Requests & status', Color(0xFF0D9488), LeavePage()),
      const _MoreService(Icons.directions_bus_filled_rounded, 'Transport',
          'Live bus & route', Color(0xFFF59E0B), TransportPage()),
      const _MoreService(Icons.notifications_active_rounded, 'Notices',
          'School announcements', Color(0xFFDC4764), NotificationsPage()),
      const _MoreService(Icons.support_agent_rounded, 'Help desk',
          'School & app support', Color(0xFF475569), HelpDeskPage()),
      const _MoreService(Icons.person_rounded, 'Parent profile',
          'Contact & children', Color(0xFF8A43C6), ProfilePage()),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
      children: [
        _MoreHero(
          studentName: ready.student.name,
          serviceCount: learning.length + services.length,
          pendingHomework: pendingHomework,
          unreadNotices: unread,
        ),
        const SizedBox(height: 23),
        const _MoreSectionHeader(
          title: 'Learning & progress',
          subtitle: 'Everything related to your child’s academics',
        ),
        const SizedBox(height: 11),
        _MoreServicesGrid(items: learning),
        const SizedBox(height: 23),
        const _MoreSectionHeader(
          title: 'Parent services',
          subtitle: 'Requests, payments, travel and communication',
        ),
        const SizedBox(height: 11),
        _MoreServicesGrid(items: services),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF20232B),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Row(children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(Icons.settings_rounded, color: Colors.white),
              ),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App & account settings',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Preferences, privacy, support and logout',
                          style: TextStyle(color: Colors.white54, fontSize: 9)),
                    ]),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white70, size: 19),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MoreService {
  const _MoreService(
      this.icon, this.title, this.subtitle, this.color, this.page);

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;
}

class _MoreModulePage extends StatelessWidget {
  const _MoreModulePage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: child,
      );
}

class _MoreHero extends StatelessWidget {
  const _MoreHero({
    required this.studentName,
    required this.serviceCount,
    required this.pendingHomework,
    required this.unreadNotices,
  });

  final String studentName;
  final int serviceCount;
  final int pendingHomework;
  final int unreadNotices;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1B28), Color(0xFF3A294E), Color(0xFF7D2944)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF512C48).withValues(alpha: .22),
              blurRadius: 23,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(15),
              ),
              child:
                  const Icon(Icons.apps_rounded, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PARENT SERVICE CENTER',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    const SizedBox(height: 3),
                    Text('$studentName’s school life',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ]),
            ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            _MoreHeroMetric(value: '$serviceCount', label: 'Services'),
            const SizedBox(width: 8),
            _MoreHeroMetric(value: '$pendingHomework', label: 'Homework due'),
            const SizedBox(width: 8),
            _MoreHeroMetric(value: '$unreadNotices', label: 'New notices'),
          ]),
        ]),
      );
}

class _MoreHeroMetric extends StatelessWidget {
  const _MoreHeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 8)),
          ]),
        ),
      );
}

class _MoreSectionHeader extends StatelessWidget {
  const _MoreSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
        ],
      );
}

class _MoreServicesGrid extends StatelessWidget {
  const _MoreServicesGrid({required this.items});

  final List<_MoreService> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.72,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            ),
            borderRadius: BorderRadius.circular(19),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: const Color(0xFFE4E6EA)),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: .035),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF7B8796),
                              fontSize: 8,
                              height: 1.25)),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool pushNotifications;
  late bool whatsAppUpdates;
  late bool emailUpdates;
  late String preferredLanguage;

  @override
  void initState() {
    super.initState();
    final profile =
        (context.read<ParentBloc>().state as ParentReady).data.profile;
    pushNotifications = profile.pushNotifications;
    whatsAppUpdates = profile.whatsAppUpdates;
    emailUpdates = profile.emailUpdates;
    preferredLanguage = profile.preferredLanguage;
  }

  void _persistPreferences() {
    final profile =
        (context.read<ParentBloc>().state as ParentReady).data.profile;
    context.read<ParentBloc>().add(ProfileSaved(profile.copyWith(
          pushNotifications: pushNotifications,
          whatsAppUpdates: whatsAppUpdates,
          emailUpdates: emailUpdates,
          preferredLanguage: preferredLanguage,
        )));
  }

  Future<void> _chooseLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Preferred language',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 10),
            for (final language in ['English', 'Telugu', 'Hindi'])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: language == preferredLanguage
                      ? const Color(0xFFC4141B)
                      : const Color(0xFFF1F2F4),
                  child: Icon(Icons.translate_rounded,
                      color: language == preferredLanguage
                          ? Colors.white
                          : const Color(0xFF64748B)),
                ),
                title: Text(language,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: language == preferredLanguage
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFFC4141B))
                    : null,
                onTap: () => Navigator.pop(context, language),
              ),
          ]),
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => preferredLanguage = selected);
      _persistPreferences();
    }
  }

  void _showInformation({required String title, required String body}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 3, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFC4141B).withValues(alpha: .09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: Color(0xFFC4141B), size: 26),
            ),
            const SizedBox(height: 13),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 11, height: 1.55)),
            const SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final logout = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFFFECEC),
              child: Icon(Icons.logout_rounded,
                  color: Color(0xFFC4141B), size: 27),
            ),
            const SizedBox(height: 13),
            const Text('Log out of Orison?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text(
              'You will need your registered mobile number and OTP to sign in again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF64748B), fontSize: 11, height: 1.45),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Stay logged in'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Log out'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
    if (logout == true && mounted) {
      context.read<AuthBloc>().add(SignedOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = context.watch<ParentBloc>().state as ParentReady;
    final profile = ready.data.profile;
    final mobile = profile.mobile.length >= 4
        ? '••••••${profile.mobile.substring(profile.mobile.length - 4)}'
        : profile.mobile;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 34),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B1C22), Color(0xFF4A2229)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3A2227).withValues(alpha: .2),
                  blurRadius: 21,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(profile.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text('${profile.relationship} · $mobile',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10)),
                      const SizedBox(height: 7),
                      Text('Viewing ${ready.student.name}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFFFFC4C8),
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ]),
              ),
              IconButton(
                tooltip: 'Edit parent profile',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage())),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ]),
          ),
          const SizedBox(height: 23),
          const _SettingsSectionTitle('Account & family'),
          const SizedBox(height: 9),
          _SettingsPanel(children: [
            _SettingsAction(
              icon: Icons.person_outline_rounded,
              color: const Color(0xFF8A43C6),
              title: 'Parent profile',
              subtitle: 'Personal, contact and emergency details',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            _SettingsAction(
              icon: Icons.family_restroom_rounded,
              color: const Color(0xFF3157C8),
              title: 'Linked children',
              subtitle: '${ready.data.students.length} students connected',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
          ]),
          const SizedBox(height: 21),
          const _SettingsSectionTitle('Communication preferences'),
          const SizedBox(height: 9),
          _SettingsPanel(children: [
            _SettingsSwitch(
              icon: Icons.notifications_active_outlined,
              color: const Color(0xFFC4141B),
              title: 'App notifications',
              subtitle: 'Attendance, notices and school alerts',
              value: pushNotifications,
              onChanged: (value) {
                setState(() => pushNotifications = value);
                _persistPreferences();
              },
            ),
            _SettingsSwitch(
              icon: Icons.chat_outlined,
              color: const Color(0xFF07966C),
              title: 'WhatsApp updates',
              subtitle: 'Fee reminders and urgent messages',
              value: whatsAppUpdates,
              onChanged: (value) {
                setState(() => whatsAppUpdates = value);
                _persistPreferences();
              },
            ),
            _SettingsSwitch(
              icon: Icons.alternate_email_rounded,
              color: const Color(0xFF3157C8),
              title: 'Email updates',
              subtitle: 'Reports, receipts and newsletters',
              value: emailUpdates,
              onChanged: (value) {
                setState(() => emailUpdates = value);
                _persistPreferences();
              },
            ),
            _SettingsAction(
              icon: Icons.language_rounded,
              color: const Color(0xFFE56B38),
              title: 'Communication language',
              subtitle: 'School updates · $preferredLanguage',
              value: preferredLanguage,
              onTap: _chooseLanguage,
            ),
          ]),
          const SizedBox(height: 21),
          const _SettingsSectionTitle('Support & privacy'),
          const SizedBox(height: 9),
          _SettingsPanel(children: [
            _SettingsAction(
              icon: Icons.support_agent_rounded,
              color: const Color(0xFF475569),
              title: 'Help desk',
              subtitle: 'School callback or Orison app support',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpDeskPage())),
            ),
            _SettingsAction(
              icon: Icons.shield_outlined,
              color: const Color(0xFF07966C),
              title: 'Privacy & data',
              subtitle: 'How parent and student information is protected',
              onTap: () => _showInformation(
                title: 'Privacy & data',
                body:
                    'Your parent and student information is used only to provide authorized school services. Payment proofs, contact details and academic records remain linked to your verified family account.',
              ),
            ),
            _SettingsAction(
              icon: Icons.info_outline_rounded,
              color: const Color(0xFF64748B),
              title: 'About Orison Parent',
              subtitle: 'Version 1.0.0 · Parent ERP',
              onTap: () => _showInformation(
                title: 'Orison Parent',
                body:
                    'A secure parent experience for academics, attendance, fees, transport and school communication. Version 1.0.0.',
              ),
            ),
          ]),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC4141B),
              side: const BorderSide(color: Color(0xFFF0B6B9)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log out of this account',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          const Text('ORISON · Secure parent access',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8)),
        ],
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900));
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFE3E5E8)),
        ),
        child: Column(
          children: children.indexed
              .expand((entry) => [
                    entry.$2,
                    if (entry.$1 != children.length - 1)
                      const Divider(height: 1, indent: 62),
                  ])
              .toList(),
        ),
      );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
        leading: Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF7B8796), fontSize: 9)),
        trailing: value == null
            ? const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8), size: 19)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Text(value!,
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8), size: 19),
              ]),
        onTap: onTap,
      );
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
        leading: Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF7B8796), fontSize: 9)),
        trailing: Switch.adaptive(value: value, onChanged: onChanged),
      );
}
