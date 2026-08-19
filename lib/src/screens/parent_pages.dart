import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/models.dart';
import '../state/parent_bloc.dart';
import '../theme.dart';

final money =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final shortDate = DateFormat('dd MMM yyyy');

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.data});
  final ParentReady data;
  @override
  Widget build(BuildContext context) {
    final student = data.student;
    return ListView(padding: const EdgeInsets.all(16), children: [
      _ParentGreeting(profile: data.data.profile),
      const SizedBox(height: 16),
      _PremiumStudentCard(data: data, student: student),
      const SizedBox(height: 24),
      const _Heading('Quick access'),
      const SizedBox(height: 12),
      const _ParentServicesGrid(),
      const SizedBox(height: 22),
      const _Heading('Today at school'),
      const SizedBox(height: 10),
      _PremiumTodayCard(
        pendingHomework:
            data.data.homework.where((item) => !item.completed).length,
      ),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: _Heading('Latest notice')),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          ),
          child: const Text('View all'),
        ),
      ]),
      const SizedBox(height: 6),
      _LatestNoticeSpotlight(notice: data.data.notices.first),
    ]);
  }
}

class _PremiumTodayCard extends StatelessWidget {
  const _PremiumTodayCard({required this.pendingHomework});

  final int pendingHomework;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF203E67), Color(0xFF176B75)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF203E67).withValues(alpha: .22),
              blurRadius: 23,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 18, 19, 15),
            child: Column(children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF68E0C1).withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(children: [
                    Icon(Icons.bolt_rounded,
                        color: Color(0xFF8AF1D6), size: 13),
                    SizedBox(width: 4),
                    Text('NEXT PERIOD',
                        style: TextStyle(
                            color: Color(0xFF9AF3DC),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7)),
                  ]),
                ),
                const Spacer(),
                Text(DateFormat('EEE, dd MMM').format(DateTime.now()),
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 10)),
              ]),
              const SizedBox(height: 17),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 53,
                  height: 53,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.calculate_rounded,
                      color: Colors.white, size: 27),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mathematics',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.3)),
                      SizedBox(height: 4),
                      Text('Mrs. R. Rao  ·  Period 3',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Column(children: [
                    Text('10:30',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                    Text('AM',
                        style: TextStyle(color: Colors.white54, fontSize: 8)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              const Row(children: [
                Expanded(
                  child: _TodayMeta(
                    icon: Icons.schedule_rounded,
                    label: '10:30 – 11:15 AM',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _TodayMeta(
                    icon: Icons.location_on_outlined,
                    label: 'Room 204',
                  ),
                ),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .075),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(27),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.assignment_turned_in_outlined,
                  color: Color(0xFFFFD27A), size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$pendingHomework homework ${pendingHomework == 1 ? 'task' : 'tasks'} pending today',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimetablePage()),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                iconAlignment: IconAlignment.end,
                label: const Text('Full day',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ]),
      );
}

class _TodayMeta extends StatelessWidget {
  const _TodayMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFB8D9ED), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}

class _LatestNoticeSpotlight extends StatelessWidget {
  const _LatestNoticeSpotlight({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _noticeCategoryStyle(notice.category);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: notice.unread
              ? color.withValues(alpha: .3)
              : const Color(0xFFE3E5E8),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          if (notice.unread) {
            context.read<ParentBloc>().add(NoticeOpened(notice.id));
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _NoticeDetailPage(notice: notice),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(17),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(notice.category.toUpperCase(),
                            style: TextStyle(
                                color: color,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7)),
                        if (notice.priority == 'Urgent') ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('URGENT',
                                style: TextStyle(
                                    color: Color(0xFFD14A45),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Text(_noticeTimeLabel(notice.time),
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 9)),
                    ]),
              ),
              if (notice.unread)
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: .35), blurRadius: 6),
                    ],
                  ),
                ),
            ]),
            const SizedBox(height: 13),
            Text(notice.title,
                style: const TextStyle(
                    color: Color(0xFF20242C),
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(notice.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 10, height: 1.45)),
            const SizedBox(height: 13),
            Row(children: [
              const Icon(Icons.account_balance_outlined,
                  color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(notice.issuer,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
              if (notice.attachmentName != null) ...[
                const Icon(Icons.attach_file_rounded,
                    color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 8),
              ],
              Text('Read notice',
                  style: TextStyle(
                      color: color, fontSize: 9, fontWeight: FontWeight.w900)),
              const SizedBox(width: 3),
              Icon(Icons.arrow_forward_rounded, color: color, size: 15),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ParentServicesGrid extends StatelessWidget {
  const _ParentServicesGrid();

  @override
  Widget build(BuildContext context) {
    final services = <_ParentService>[
      const _ParentService(
        label: 'Profile',
        icon: Icons.person_rounded,
        color: Color(0xFF7C3AED),
        page: ProfilePage(),
      ),
      const _ParentService(
        label: 'Attendance',
        icon: Icons.fact_check_rounded,
        color: Color(0xFF059669),
        page: AttendancePage(),
      ),
      const _ParentService(
        label: 'Academics',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF2563EB),
        page: _ParentModulePage(
          title: 'Academics',
          child: AcademicsPage(),
        ),
      ),
      const _ParentService(
        label: 'Exams',
        icon: Icons.assignment_rounded,
        color: Color(0xFFEA580C),
        page: ExamsPage(),
      ),
      const _ParentService(
        label: 'Compare',
        icon: Icons.compare_arrows_rounded,
        color: Color(0xFF6D4AFF),
        page: ExamComparisonPage(),
      ),
      const _ParentService(
        label: 'Fees',
        icon: Icons.account_balance_wallet_rounded,
        color: orisonRed,
        page: _ParentModulePage(title: 'Fees', child: FeesPage()),
      ),
      const _ParentService(
        label: 'Hall ticket',
        icon: Icons.badge_rounded,
        color: Color(0xFF0891B2),
        page: HallTicketsPage(),
      ),
      const _ParentService(
        label: 'Homework',
        icon: Icons.edit_note_rounded,
        color: Color(0xFF4F46E5),
        page: HomeworkPage(),
      ),
      const _ParentService(
        label: 'Timetable',
        icon: Icons.calendar_month_rounded,
        color: Color(0xFFDB2777),
        page: TimetablePage(),
      ),
      const _ParentService(
        label: 'Leave',
        icon: Icons.medical_information_rounded,
        color: Color(0xFF0D9488),
        page: LeavePage(),
      ),
      const _ParentService(
        label: 'Transport',
        icon: Icons.directions_bus_filled_rounded,
        color: Color(0xFFF59E0B),
        page: TransportPage(),
      ),
      const _ParentService(
        label: 'Notices',
        icon: Icons.notifications_rounded,
        color: Color(0xFFDC2626),
        page: NotificationsPage(),
      ),
      const _ParentService(
        label: 'Help desk',
        icon: Icons.support_agent_rounded,
        color: Color(0xFF475569),
        page: HelpDeskPage(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: .78,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return Semantics(
          button: true,
          label: 'Open ${service.label}',
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => service.page),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: service.color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: service.color.withValues(alpha: .16),
                    ),
                  ),
                  child: Icon(service.icon, color: service.color, size: 29),
                ),
                const SizedBox(height: 8),
                Text(
                  service.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParentService {
  const _ParentService({
    required this.label,
    required this.icon,
    required this.color,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _ParentModulePage extends StatelessWidget {
  const _ParentModulePage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: child,
      );
}

class _ParentGreeting extends StatelessWidget {
  const _ParentGreeting({required this.profile});

  final ParentProfile profile;

  @override
  Widget build(BuildContext context) {
    final firstName = profile.name.trim().split(' ').first;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: orisonRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Good evening, $firstName',
                style: const TextStyle(
                  color: ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Here’s the latest from school.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9E9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFD1D3)),
          ),
          child: Text(
            firstName.characters.first.toUpperCase(),
            style: const TextStyle(
              color: orisonRed,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumStudentCard extends StatelessWidget {
  const _PremiumStudentCard({required this.data, required this.student});

  final ParentReady data;
  final Student student;

  void _showChildPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose child',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ...data.data.students.indexed.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: entry.$1 == data.selectedStudent
                        ? orisonRed
                        : const Color(0xFFF1F1F3),
                    child: Text(
                      entry.$2.name.characters.first,
                      style: TextStyle(
                        color: entry.$1 == data.selectedStudent
                            ? Colors.white
                            : ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(entry.$2.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(entry.$2.className),
                  trailing: entry.$1 == data.selectedStudent
                      ? const Icon(Icons.check_circle, color: orisonRed)
                      : null,
                  onTap: () {
                    context.read<ParentBloc>().add(StudentSelected(entry.$1));
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF19191D), Color(0xFF3D1014), Color(0xFF8B0B13)],
            stops: [0, .62, 1],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33260003),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -42,
              top: -58,
              child: _GlowOrb(size: 170, color: Color(0x33FF535A)),
            ),
            const Positioned(
              left: -52,
              bottom: -92,
              child: _GlowOrb(size: 190, color: Color(0x1AFFFFFF)),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showChildPicker(context),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: .13)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              student.name.characters.first,
                              style: const TextStyle(
                                color: orisonRed,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${student.className} · Roll ${student.roll}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A36A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7,
                              ),
                            ),
                          ),
                          const Icon(Icons.expand_more, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OUTSTANDING BALANCE',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              money.format(student.balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _ParentModulePage(
                              title: 'Fees',
                              child: FeesPage(),
                            ),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ink,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Pay now',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Divider(
                      color: Colors.white.withValues(alpha: .14), height: 1),
                  const SizedBox(height: 15),
                  const Row(
                    children: [
                      Expanded(
                        child: _HeroMetric(
                          icon: Icons.fact_check_outlined,
                          label: 'Attendance',
                          value: '91.3%',
                        ),
                      ),
                      _HeroDivider(),
                      Expanded(
                        child: _HeroMetric(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Grade',
                          value: 'A+',
                        ),
                      ),
                      _HeroDivider(),
                      Expanded(
                        child: _HeroMetric(
                          icon: Icons.leaderboard_outlined,
                          label: 'Class rank',
                          value: '#3',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white60, size: 14),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      );
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 28,
        color: Colors.white12,
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
}

class AcademicsPage extends StatelessWidget {
  const AcademicsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ParentBloc, ParentState>(builder: (context, state) {
        final s = state as ParentReady;
        const previousScores = <String, int>{
          'Mathematics': 88,
          'Science': 90,
          'English': 91,
          'Hindi': 82,
          'Social Studies': 86,
          'Computer Science': 94,
        };
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Academic performance',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Progress since the previous examination',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('TERM I',
                    style: TextStyle(
                        color: Color(0xFF3158B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AcademicHero(student: s.student),
          const SizedBox(height: 22),
          const Text('Performance highlights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const _AcademicInsightCard(
            icon: Icons.trending_up_rounded,
            title: 'Strong improvement',
            message:
                'Mathematics improved by 8 points since the last examination. Problem-solving accuracy is now excellent.',
            tag: '+8 points',
            color: Color(0xFF059669),
          ),
          const SizedBox(height: 10),
          const _AcademicInsightCard(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Needs your support',
            message:
                'English is 4 points lower than the previous exam. Reading comprehension and written summaries need attention.',
            tag: 'Focus area',
            color: Color(0xFFEA580C),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text('Subject progress',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Text('vs Unit Test II',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...s.data.grades.map(
            (grade) => _SubjectProgressCard(
              grade: grade,
              previous: previousScores[grade.subject] ?? grade.total,
            ),
          ),
          const SizedBox(height: 12),
          const _ClassParticipationCard(),
          const SizedBox(height: 18),
          const _TeacherObservationCard(),
          const SizedBox(height: 18),
          const _ParentSupportPlan(),
        ]);
      });
}

class _AcademicHero extends StatelessWidget {
  const _AcademicHero({required this.student});
  final Student student;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF172554), Color(0xFF3730A3), Color(0xFF6D28D9)],
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x292F2A84),
                blurRadius: 22,
                offset: Offset(0, 11)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(student.name.characters.first,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(student.className,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('EXCELLENT',
                      style: TextStyle(
                          color: Color(0xFF9BF0C9),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('CURRENT ACADEMIC STANDING',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1)),
            const SizedBox(height: 4),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('9.42',
                    style: TextStyle(
                        color: Colors.white,
                        height: 1,
                        fontSize: 36,
                        fontWeight: FontWeight.w900)),
                SizedBox(width: 7),
                Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text('CGPA  ·  A+ grade',
                      style: TextStyle(color: Colors.white60, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: _AcademicHeroMetric('Class rank', '03 / 45')),
                _AcademicHeroDivider(),
                Expanded(child: _AcademicHeroMetric('Class average', '81%')),
                _AcademicHeroDivider(),
                Expanded(child: _AcademicHeroMetric('Homework', '94%')),
              ],
            ),
          ],
        ),
      );
}

class _AcademicHeroMetric extends StatelessWidget {
  const _AcademicHeroMetric(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ],
      );
}

class _AcademicHeroDivider extends StatelessWidget {
  const _AcademicHeroDivider();
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 28, color: Colors.white.withValues(alpha: .14));
}

class _AcademicInsightCard extends StatelessWidget {
  const _AcademicInsightCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.tag,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String message;
  final String tag;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .075),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(message,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 11, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SubjectProgressCard extends StatelessWidget {
  const _SubjectProgressCard({required this.grade, required this.previous});
  final Grade grade;
  final int previous;
  @override
  Widget build(BuildContext context) {
    final change = grade.total - previous;
    final positive = change >= 0;
    final color = positive ? const Color(0xFF059669) : const Color(0xFFEA580C);
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(grade.subject,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          positive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: color),
                      Text('${change.abs()} pts',
                          style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Text('${grade.total}',
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: grade.total / 100,
                minHeight: 7,
                backgroundColor: const Color(0xFFEEF0F4),
                color: color,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text('Previous $previous',
                    style:
                        const TextStyle(color: Colors.black45, fontSize: 10)),
                const Spacer(),
                Text('Current grade ${grade.grade}',
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassParticipationCard extends StatelessWidget {
  const _ClassParticipationCard();
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.groups_2_outlined,
                        color: Color(0xFF08785C)),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class participation',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        Text('Engagement during the current term',
                            style:
                                TextStyle(color: Colors.black45, fontSize: 10)),
                      ],
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('86 / 100',
                          style: TextStyle(
                              color: Color(0xFF08785C),
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                      Text('VERY GOOD',
                          style: TextStyle(
                              color: Color(0xFF08785C),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .7)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const _ParticipationMetric('Class discussions', 82),
              const SizedBox(height: 12),
              const _ParticipationMetric('Homework completion', 94),
              const SizedBox(height: 12),
              const _ParticipationMetric('Activities & teamwork', 78),
            ],
          ),
        ),
      );
}

class _ParticipationMetric extends StatelessWidget {
  const _ParticipationMetric(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
              width: 132,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 7,
                color: const Color(0xFF0D9488),
                backgroundColor: const Color(0xFFE7F1EF),
              ),
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
              width: 25,
              child: Text('$value',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800))),
        ],
      );
}

class _TeacherObservationCard extends StatelessWidget {
  const _TeacherObservationCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E8),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFF7DFA5)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.record_voice_over_outlined,
                    color: Color(0xFF9A6700), size: 20),
                SizedBox(width: 8),
                Text('Class teacher observation',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                Spacer(),
                Text('12 Aug',
                    style: TextStyle(color: Colors.black45, fontSize: 9)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '“Marcus is contributing more confidently during Mathematics and Science discussions. Encouraging him to explain English passages in his own words will improve comprehension.”',
              style:
                  TextStyle(color: Colors.black54, height: 1.5, fontSize: 11),
            ),
            SizedBox(height: 9),
            Text('— Ms. Priya Rao, Class Teacher',
                style: TextStyle(
                    color: Color(0xFF765000),
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _ParentSupportPlan extends StatelessWidget {
  const _ParentSupportPlan();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EC),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFFFD2C3)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_outline_rounded, color: Color(0xFFD34B22)),
                SizedBox(width: 8),
                Text('How you can support this week',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
            SizedBox(height: 13),
            _SupportStep('1', 'Read together for 20 minutes on four evenings.'),
            _SupportStep('2',
                'Ask Marcus to summarize each passage in three sentences.'),
            _SupportStep('3',
                'Review the teacher’s vocabulary worksheet before Friday.'),
          ],
        ),
      );
}

class _SupportStep extends StatelessWidget {
  const _SupportStep(this.number, this.text);
  final String number;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: const Color(0xFFD34B22),
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 9),
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 11, height: 1.4))),
          ],
        ),
      );
}

class FeesPage extends StatelessWidget {
  const FeesPage({super.key});

  void _openPayment(BuildContext context, FeeItem fee) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeePaymentSheet(fee: fee),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ParentBloc, ParentState>(builder: (context, state) {
        final s = state as ParentReady;
        final due =
            s.data.fees.fold<double>(0, (sum, item) => sum + item.balance);
        final previousFees =
            s.data.fees.where((fee) => fee.academicYear == '2025–26').toList();
        final currentFees =
            s.data.fees.where((fee) => fee.academicYear == '2026–27').toList();
        final overdue =
            previousFees.fold<double>(0, (sum, fee) => sum + fee.balance);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            const Text('Fees & payments',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Academic year-wise fee details for Marcus',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            _FeeSummaryHero(
              totalDue: due,
              previousYearDue: overdue,
              paidThisYear: currentFees.fold<double>(
                  0, (sum, fee) => sum + fee.paidAmount),
            ),
            const SizedBox(height: 24),
            _AcademicYearFeeSection(
              year: '2025–26',
              label: 'Previous academic year',
              fees: previousFees,
              isPreviousYear: true,
              onPay: (fee) => _openPayment(context, fee),
            ),
            const SizedBox(height: 22),
            _AcademicYearFeeSection(
              year: '2026–27',
              label: 'Present academic year',
              fees: currentFees,
              onPay: (fee) => _openPayment(context, fee),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined,
                      color: Color(0xFF475569), size: 20),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Payments are updated only after the transaction ID and attached proof are verified against the school account.',
                      style: TextStyle(
                          color: Color(0xFF64748B), fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      });
}

class _FeeSummaryHero extends StatelessWidget {
  const _FeeSummaryHero({
    required this.totalDue,
    required this.previousYearDue,
    required this.paidThisYear,
  });
  final double totalDue;
  final double previousYearDue;
  final double paidThisYear;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF21172F), Color(0xFF622250), Color(0xFFC8343F)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B263F).withValues(alpha: .22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 23),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text('TOTAL OUTSTANDING',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Marcus',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 16),
          Text(money.format(totalDue),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 17),
          Row(children: [
            Expanded(
              child: _FeeHeroMetric(
                label: 'Previous year due',
                value: money.format(previousYearDue),
                alert: previousYearDue > 0,
              ),
            ),
            Container(width: 1, height: 34, color: Colors.white24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: _FeeHeroMetric(
                  label: 'Paid this year',
                  value: money.format(paidThisYear),
                ),
              ),
            ),
          ]),
        ]),
      );
}

class _FeeHeroMetric extends StatelessWidget {
  const _FeeHeroMetric({
    required this.label,
    required this.value,
    this.alert = false,
  });
  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 3),
          Row(children: [
            if (alert) ...[
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFFC766), size: 15),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
        ],
      );
}

class _AcademicYearFeeSection extends StatelessWidget {
  const _AcademicYearFeeSection({
    required this.year,
    required this.label,
    required this.fees,
    required this.onPay,
    this.isPreviousYear = false,
  });
  final String year;
  final String label;
  final List<FeeItem> fees;
  final ValueChanged<FeeItem> onPay;
  final bool isPreviousYear;

  @override
  Widget build(BuildContext context) {
    final due = fees.fold<double>(0, (sum, fee) => sum + fee.balance);
    final accent =
        isPreviousYear ? const Color(0xFFD14A45) : const Color(0xFF3157C8);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 5,
          height: 38,
          decoration: BoxDecoration(
              color: accent, borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text('Academic year $year',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (due > 0 ? accent : const Color(0xFF07966C))
                .withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(due > 0 ? '${money.format(due)} due' : 'Fully paid',
              style: TextStyle(
                  color: due > 0 ? accent : const Color(0xFF07966C),
                  fontSize: 10,
                  fontWeight: FontWeight.w800)),
        ),
      ]),
      const SizedBox(height: 12),
      ...fees.map((fee) => _FeeItemCard(fee: fee, onPay: () => onPay(fee))),
    ]);
  }
}

class _FeeItemCard extends StatelessWidget {
  const _FeeItemCard({required this.fee, required this.onPay});
  final FeeItem fee;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final paid = fee.balance <= 0;
    final overdue = fee.status == 'Overdue';
    final color = paid
        ? const Color(0xFF07966C)
        : overdue
            ? const Color(0xFFD14A45)
            : const Color(0xFFDA8510);
    final progress = fee.amount == 0 ? 0.0 : fee.paidAmount / fee.amount;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                paid ? Icons.verified_rounded : Icons.receipt_long_rounded,
                color: color,
                size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fee.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text('Due ${shortDate.format(fee.dueDate)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(fee.status,
                style: TextStyle(
                    color: color, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 6,
            backgroundColor: const Color(0xFFEEEFF3),
            valueColor: AlwaysStoppedAnimation<Color>(
                paid ? const Color(0xFF07966C) : const Color(0xFF4664D4)),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          _FeeAmountLabel(label: 'Total', amount: fee.amount),
          const SizedBox(width: 18),
          _FeeAmountLabel(label: 'Paid', amount: fee.paidAmount),
          const Spacer(),
          _FeeAmountLabel(label: 'Balance', amount: fee.balance, strong: true),
        ]),
        if (fee.transactionId != null) ...[
          const SizedBox(height: 9),
          Text('Transaction ID  ${fee.transactionId}',
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 11),
          const Divider(height: 1),
          const SizedBox(height: 11),
          Row(children: [
            const Icon(Icons.receipt_long_rounded,
                color: Color(0xFF07966C), size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment receipt',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800)),
                    Text('Verified and ready to download',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 9)),
                  ]),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _FeeReceiptPage(fee: fee)),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 17),
              label: const Text('View'),
            ),
            IconButton(
              tooltip: 'Download receipt PDF',
              onPressed: () => _downloadFeeReceipt(context, fee),
              icon:
                  const Icon(Icons.download_rounded, color: Color(0xFF3157C8)),
            ),
          ]),
        ],
        if (!paid) ...[
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.qr_code_2_rounded, size: 19),
              label: const Text('Pay now'),
            ),
          ),
        ],
      ]),
    );
  }
}

class _FeeAmountLabel extends StatelessWidget {
  const _FeeAmountLabel({
    required this.label,
    required this.amount,
    this.strong = false,
  });
  final String label;
  final double amount;
  final bool strong;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
          const SizedBox(height: 2),
          Text(money.format(amount),
              style: TextStyle(
                  color: strong
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF64748B),
                  fontSize: strong ? 13 : 11,
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w700)),
        ],
      );
}

String _feeReceiptNumber(FeeItem fee) {
  final transaction = fee.transactionId ?? fee.id;
  final suffix = transaction.length > 6
      ? transaction.substring(transaction.length - 6)
      : transaction;
  return 'OR-${fee.academicYear.replaceAll('–', '')}-$suffix';
}

Future<Uint8List> _buildFeeReceiptPdf(FeeItem fee) async {
  final document = pw.Document(
    title: 'Orison payment receipt ${_feeReceiptNumber(fee)}',
    author: 'Orison International School',
  );
  final receiptDate = fee.paidOn ?? fee.dueDate;
  final amount = fee.receiptAmount ?? fee.paidAmount;
  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(42),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#23172E'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ORISON INTERNATIONAL SCHOOL',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 17,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Official fee payment receipt',
                        style: const pw.TextStyle(
                            color: PdfColors.grey300, fontSize: 10)),
                  ],
                ),
              ),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0A8F69'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text('PAID',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold)),
              ),
            ]),
          ),
          pw.SizedBox(height: 28),
          pw.Text('PAYMENT RECEIPT',
              style: pw.TextStyle(
                  color: PdfColor.fromHex('#C91425'),
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2)),
          pw.SizedBox(height: 6),
          pw.Text(_feeReceiptNumber(fee),
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 24),
          _pdfReceiptRow('Student', 'Marcus Thorne'),
          _pdfReceiptRow('Admission number', 'EP-2024-0812'),
          _pdfReceiptRow('Academic year', fee.academicYear),
          _pdfReceiptRow('Fee description', fee.title),
          _pdfReceiptRow('Payment date', shortDate.format(receiptDate)),
          _pdfReceiptRow('Transaction ID / UTR', fee.transactionId ?? '—'),
          pw.Divider(height: 34, color: PdfColors.grey300),
          pw.Row(children: [
            pw.Expanded(
              child: pw.Text('Amount received',
                  style: const pw.TextStyle(
                      color: PdfColors.grey700, fontSize: 13)),
            ),
            pw.Text('INR ${amount.toStringAsFixed(0)}',
                style: pw.TextStyle(
                    color: PdfColor.fromHex('#0A8F69'),
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold)),
          ]),
          pw.Spacer(),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'This is a system-generated receipt verified against the school payment record. No signature is required.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
          ),
        ],
      ),
    ),
  );
  return document.save();
}

pw.Widget _pdfReceiptRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(label,
              style:
                  const pw.TextStyle(color: PdfColors.grey600, fontSize: 11)),
        ),
        pw.Expanded(
          child: pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ),
      ]),
    );

Future<void> _downloadFeeReceipt(BuildContext context, FeeItem fee) async {
  try {
    await Printing.sharePdf(
      bytes: await _buildFeeReceiptPdf(fee),
      filename: '${_feeReceiptNumber(fee)}.pdf',
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to prepare the receipt PDF.')),
      );
    }
  }
}

class _FeeReceiptPage extends StatelessWidget {
  const _FeeReceiptPage({required this.fee});
  final FeeItem fee;

  @override
  Widget build(BuildContext context) {
    final receiptDate = fee.paidOn ?? fee.dueDate;
    final amount = fee.receiptAmount ?? fee.paidAmount;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(title: const Text('Payment receipt')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE6E5EA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF21172F), Color(0xFF6C264D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.school_rounded, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ORISON INTERNATIONAL SCHOOL',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .4)),
                          SizedBox(height: 3),
                          Text('Official fee payment receipt',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 10)),
                        ]),
                  ),
                  Icon(Icons.verified_rounded, color: Color(0xFF69E6BC)),
                ]),
              ),
              const SizedBox(height: 22),
              const Text('PAYMENT SUCCESSFUL',
                  style: TextStyle(
                      color: Color(0xFF07966C),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1)),
              const SizedBox(height: 7),
              Text(money.format(amount),
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(_feeReceiptNumber(fee),
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              const SizedBox(height: 22),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _ReceiptDetailRow(label: 'Student', value: 'Marcus Thorne'),
              _ReceiptDetailRow(label: 'Admission no.', value: 'EP-2024-0812'),
              _ReceiptDetailRow(
                  label: 'Academic year', value: fee.academicYear),
              _ReceiptDetailRow(label: 'Fee', value: fee.title),
              _ReceiptDetailRow(
                  label: 'Payment date', value: shortDate.format(receiptDate)),
              _ReceiptDetailRow(
                  label: 'Transaction ID', value: fee.transactionId ?? '—'),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(children: [
                  Icon(Icons.verified_user_rounded,
                      color: Color(0xFF07966C), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Verified against the school payment record',
                        style: TextStyle(
                            color: Color(0xFF087D68),
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _downloadFeeReceipt(context, fee),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download receipt PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDetailRow extends StatelessWidget {
  const _ReceiptDetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 102,
            child: Text(label,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ]),
      );
}

class _FeePaymentSheet extends StatefulWidget {
  const _FeePaymentSheet({required this.fee});
  final FeeItem fee;

  @override
  State<_FeePaymentSheet> createState() => _FeePaymentSheetState();
}

class _FeePaymentSheetState extends State<_FeePaymentSheet> {
  late final TextEditingController _amountController;
  final _transactionController = TextEditingController();
  final _picker = ImagePicker();
  bool _payFull = true;
  XFile? _proof;

  double get _selectedAmount => _payFull
      ? widget.fee.balance
      : double.tryParse(_amountController.text.trim()) ?? 0;

  String get _qrData =>
      'upi://pay?pa=orisonschool@upi&pn=Orison%20International%20School&am=${_selectedAmount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(widget.fee.title)}';

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.fee.balance.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionController.dispose();
    super.dispose();
  }

  Future<void> _pickProof(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 82);
    if (picked != null && mounted) setState(() => _proof = picked);
  }

  void _submit() {
    final amount = _selectedAmount;
    if (amount <= 0 || amount > widget.fee.balance) {
      _showError('Enter an amount up to ${money.format(widget.fee.balance)}.');
      return;
    }
    if (_transactionController.text.trim().length < 8) {
      _showError('Enter a valid transaction ID with at least 8 characters.');
      return;
    }
    if (_proof == null) {
      _showError('Attach a screenshot or photo of the payment proof.');
      return;
    }
    context.read<ParentBloc>().add(FeePaymentProofSubmitted(
          feeId: widget.fee.id,
          amount: amount,
          transactionId: _transactionController.text.trim().toUpperCase(),
          proofName: _proof!.name,
        ));
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Container(
        height: MediaQuery.sizeOf(context).height * .93,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD5D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
            child: Row(children: [
              const Expanded(
                child: Text('Pay school fee',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  18, 4, 18, 24 + MediaQuery.viewInsetsOf(context).bottom),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE8E7EC)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEC),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              color: orisonRed),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.fee.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                Text('Academic year ${widget.fee.academicYear}',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11)),
                              ]),
                        ),
                        Text(money.format(widget.fee.balance),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    const _PaymentStepLabel(
                        number: '1', title: 'Choose payment amount'),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: _AmountChoiceCard(
                          selected: _payFull,
                          title: 'Pay full amount',
                          value: money.format(widget.fee.balance),
                          onTap: () => setState(() => _payFull = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AmountChoiceCard(
                          selected: !_payFull,
                          title: 'Custom amount',
                          value: 'Enter manually',
                          onTap: () => setState(() => _payFull = false),
                        ),
                      ),
                    ]),
                    if (!_payFull) ...[
                      const SizedBox(height: 11),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Amount to pay',
                          prefixText: '₹  ',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    const _PaymentStepLabel(
                        number: '2', title: 'Scan the school QR and pay'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171526),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: _qrData,
                            size: 164,
                            eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF171526)),
                            dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF171526)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('ORISON INTERNATIONAL SCHOOL',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5)),
                        const SizedBox(height: 3),
                        Text(
                            'Scan using another mobile  •  ${money.format(_selectedAmount)}',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 3),
                        const Text('UPI ID: orisonschool@upi',
                            style: TextStyle(
                                color: Color(0xFFFFC766), fontSize: 10)),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    const _PaymentStepLabel(
                        number: '3', title: 'Enter transaction details'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _transactionController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Transaction ID / UTR number',
                        hintText: 'Example: 628401927364',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _proof == null
                            ? Colors.white
                            : const Color(0xFFEAF8F2),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: _proof == null
                              ? const Color(0xFFD9D9E0)
                              : const Color(0xFF80CDB3),
                        ),
                      ),
                      child: Column(children: [
                        Row(children: [
                          Icon(
                            _proof == null
                                ? Icons.cloud_upload_outlined
                                : Icons.check_circle_rounded,
                            color: _proof == null
                                ? const Color(0xFF64748B)
                                : const Color(0xFF07966C),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _proof == null
                                        ? 'Attach payment proof here'
                                        : 'Payment proof attached',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    _proof?.name ??
                                        'Screenshot or clear photo of the receipt',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFF64748B), fontSize: 10),
                                  ),
                                ]),
                          ),
                        ]),
                        const SizedBox(height: 11),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickProof(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined,
                                  size: 18),
                              label: const Text('Gallery'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickProof(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined,
                                  size: 18),
                              label: const Text('Camera'),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Submit payment for verification'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The fee status will update after the transaction details match the school payment record.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                  ]),
            ),
          ),
        ]),
      );
}

class _PaymentStepLabel extends StatelessWidget {
  const _PaymentStepLabel({required this.number, required this.title});
  final String number;
  final String title;

  @override
  Widget build(BuildContext context) => Row(children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF24172D),
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ]);
}

class _AmountChoiceCard extends StatelessWidget {
  const _AmountChoiceCard({
    required this.selected,
    required this.title,
    required this.value,
    required this.onTap,
  });
  final bool selected;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFEFEF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? orisonRed : const Color(0xFFE0E0E6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? orisonRed : const Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 7),
            Text(value,
                style: TextStyle(
                    color: selected ? orisonRed : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w900)),
          ]),
        ),
      );
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

enum _DayStatus { present, absent, late, holiday, future }

class _AttendancePageState extends State<AttendancePage> {
  late DateTime month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    month = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }

  void _moveMonth(int change) {
    final target = DateTime(month.year, month.month + change);
    final now = DateTime.now();
    if (target.isAfter(DateTime(now.year, now.month))) return;
    setState(() => month = target);
  }

  bool _isHoliday(DateTime date) {
    if (date.weekday == DateTime.sunday) return true;
    final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
    return date.weekday == DateTime.saturday &&
        (weekOfMonth == 2 || weekOfMonth == 4);
  }

  _DayStatus _statusFor(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    if (DateUtils.dateOnly(date).isAfter(today)) return _DayStatus.future;
    if (_isHoliday(date)) return _DayStatus.holiday;
    if ((date.day + date.month * 2) % 17 == 0) return _DayStatus.absent;
    if ((date.day + date.month) % 13 == 0) return _DayStatus.late;
    return _DayStatus.present;
  }

  ({int working, int holidays, int present, int absent, int late})
      _monthStats() {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    var working = 0, holidays = 0, present = 0, absent = 0, late = 0;
    for (var day = 1; day <= days; day++) {
      final date = DateTime(month.year, month.month, day);
      if (_isHoliday(date)) {
        holidays++;
      } else {
        working++;
      }
      switch (_statusFor(date)) {
        case _DayStatus.present:
          present++;
        case _DayStatus.absent:
          absent++;
        case _DayStatus.late:
          present++;
          late++;
        case _DayStatus.holiday:
        case _DayStatus.future:
          break;
      }
    }
    return (
      working: working,
      holidays: holidays,
      present: present,
      absent: absent,
      late: late,
    );
  }

  Future<void> _chooseMonth() async {
    final now = DateTime.now();
    final months =
        List.generate(12, (index) => DateTime(now.year, now.month - index));
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select month',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final value = months[index];
                    final selected =
                        value.year == month.year && value.month == month.month;
                    return ListTile(
                      leading: Icon(Icons.calendar_month_outlined,
                          color: selected ? orisonRed : Colors.black45),
                      title: Text(DateFormat('MMMM yyyy').format(value),
                          style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500)),
                      trailing: selected
                          ? const Icon(Icons.check_circle, color: orisonRed)
                          : null,
                      onTap: () {
                        setState(() => month = value);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ParentBloc>().state as ParentReady;
    final stats = _monthStats();
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12382D), Color(0xFF087856)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x24255F4B),
                    blurRadius: 20,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(state.student.name.characters.first,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.student.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text(state.student.className,
                          style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('ATTENDANCE',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 8,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700)),
                    Text(
                      stats.present + stats.absent == 0
                          ? '—'
                          : '${(stats.present / (stats.present + stats.absent) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AttendanceCalendar(
            month: month,
            isCurrentMonth: _isCurrentMonth,
            statusFor: _statusFor,
            onPrevious: () => _moveMonth(-1),
            onNext: () => _moveMonth(1),
            onChooseMonth: _chooseMonth,
          ),
          const SizedBox(height: 20),
          const Text('Monthly summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 11),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.75,
            children: [
              _AttendanceStatCard(
                title: 'Working days',
                value: '${stats.working}',
                subtitle: 'Scheduled this month',
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFF2563EB),
              ),
              _AttendanceStatCard(
                title: 'Holidays',
                value: '${stats.holidays}',
                subtitle: 'Sundays & school holidays',
                icon: Icons.celebration_outlined,
                color: const Color(0xFF7C3AED),
              ),
              _AttendanceStatCard(
                title: 'Present days',
                value: '${stats.present}',
                subtitle: '${stats.late} late arrivals included',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF059669),
              ),
              _AttendanceStatCard(
                title: 'Absent days',
                value: '${stats.absent}',
                subtitle: 'Attendance exceptions',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceCalendar extends StatelessWidget {
  const _AttendanceCalendar({
    required this.month,
    required this.isCurrentMonth,
    required this.statusFor,
    required this.onPrevious,
    required this.onNext,
    required this.onChooseMonth,
  });

  final DateTime month;
  final bool isCurrentMonth;
  final _DayStatus Function(DateTime) statusFor;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onChooseMonth;

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final leading = DateTime(month.year, month.month).weekday - 1;
    final cellCount = ((leading + days + 6) ~/ 7) * 7;
    const weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.chevron_left_rounded)),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onChooseMonth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('MMMM yyyy').format(month),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 5),
                          const Icon(Icons.expand_more_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: isCurrentMonth ? null : onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: weekDays
                  .map((day) => Expanded(
                        child: Text(day,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 5,
                mainAxisSpacing: 7,
              ),
              itemBuilder: (context, index) {
                final day = index - leading + 1;
                if (day < 1 || day > days) return const SizedBox.shrink();
                final date = DateTime(month.year, month.month, day);
                return _AttendanceDay(date: date, status: statusFor(date));
              },
            ),
            const SizedBox(height: 13),
            const Wrap(
              alignment: WrapAlignment.center,
              spacing: 13,
              runSpacing: 7,
              children: [
                _CalendarLegend('Present', Color(0xFF059669)),
                _CalendarLegend('Absent', Color(0xFFDC2626)),
                _CalendarLegend('Late', Color(0xFFF59E0B)),
                _CalendarLegend('Holiday', Color(0xFF7C3AED)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceDay extends StatelessWidget {
  const _AttendanceDay({required this.date, required this.status});
  final DateTime date;
  final _DayStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      _DayStatus.present => (const Color(0xFF059669), Icons.check_rounded),
      _DayStatus.absent => (const Color(0xFFDC2626), Icons.close_rounded),
      _DayStatus.late => (const Color(0xFFF59E0B), Icons.schedule_rounded),
      _DayStatus.holiday => (const Color(0xFF7C3AED), Icons.circle),
      _DayStatus.future => (const Color(0xFF94A3B8), Icons.circle_outlined),
    };
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: status == _DayStatus.future ? .04 : .1),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isToday ? ink : color.withValues(alpha: .18),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${date.day}',
              style: TextStyle(
                  color: status == _DayStatus.future ? Colors.black38 : ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Icon(icon,
              size: status == _DayStatus.holiday ? 5 : 11,
              color: status == _DayStatus.future ? Colors.black26 : color),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 10)),
        ],
      );
}

class _AttendanceStatCard extends StatelessWidget {
  const _AttendanceStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(value,
                          style: TextStyle(
                              color: color,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.black45, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      );
}

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(title: const Text('Homework')),
        body: BlocBuilder<ParentBloc, ParentState>(builder: (context, state) {
          final ready = state as ParentReady;
          final all = [...ready.data.homework]..sort((a, b) {
              if (a.completed != b.completed) return a.completed ? 1 : -1;
              return a.dueDate.compareTo(b.dueDate);
            });
          final pending = all.where((item) => !item.completed).length;
          final completed = all.length - pending;
          final visible = all.where((item) {
            if (_filter == 1) return !item.completed;
            if (_filter == 2) return item.completed;
            return true;
          }).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _HomeworkHero(
                total: all.length,
                pending: pending,
                completed: completed,
              ),
              const SizedBox(height: 20),
              _HomeworkFilterBar(
                selected: _filter,
                all: all.length,
                pending: pending,
                done: completed,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: Text(
                    _filter == 1
                        ? 'Pending assignments'
                        : _filter == 2
                            ? 'Completed assignments'
                            : 'All assigned homework',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                Text('${visible.length} tasks',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 11)),
              ]),
              const SizedBox(height: 11),
              if (visible.isEmpty)
                const _HomeworkEmptyState()
              else
                ...visible.map(
                  (homework) => _HomeworkAssignmentCard(
                    homework: homework,
                    onStatusChanged: (completed) =>
                        context.read<ParentBloc>().add(HomeworkStatusChanged(
                              homeworkId: homework.id,
                              completed: completed,
                            )),
                  ),
                ),
            ],
          );
        }),
      );
}

class _HomeworkHero extends StatelessWidget {
  const _HomeworkHero({
    required this.total,
    required this.pending,
    required this.completed,
  });
  final int total;
  final int pending;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2140), Color(0xFF3844A0), Color(0xFF7A4DD8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3844A0).withValues(alpha: .23),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: Colors.white, size: 27),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MARCUS’S HOMEWORK',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              SizedBox(height: 3),
              Text('Assignment tracker',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(children: [
              Icon(Icons.sync_rounded, color: Color(0xFFBBD3FF), size: 13),
              SizedBox(width: 4),
              Text('School synced',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const SizedBox(height: 21),
        Row(children: [
          Text('$completed of $total completed',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          Text('${(progress * 100).round()}%',
              style: const TextStyle(
                  color: Color(0xFFCCDDFF), fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF75E6BD)),
          ),
        ),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(
            child: _HomeworkHeroMetric(
              icon: Icons.pending_actions_rounded,
              value: '$pending',
              label: 'Pending',
              color: const Color(0xFFFFD166),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _HomeworkHeroMetric(
              icon: Icons.task_alt_rounded,
              value: '$completed',
              label: 'Done',
              color: const Color(0xFF75E6BD),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _HomeworkHeroMetric extends StatelessWidget {
  const _HomeworkHeroMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ]),
      );
}

class _HomeworkFilterBar extends StatelessWidget {
  const _HomeworkFilterBar({
    required this.selected,
    required this.all,
    required this.pending,
    required this.done,
    required this.onSelected,
  });
  final int selected;
  final int all;
  final int pending;
  final int done;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEF2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(children: [
          _HomeworkFilter(
            label: 'All',
            count: all,
            selected: selected == 0,
            onTap: () => onSelected(0),
          ),
          _HomeworkFilter(
            label: 'Pending',
            count: pending,
            selected: selected == 1,
            onTap: () => onSelected(1),
          ),
          _HomeworkFilter(
            label: 'Done',
            count: done,
            selected: selected == 2,
            onTap: () => onSelected(2),
          ),
        ]),
      );
}

class _HomeworkFilter extends StatelessWidget {
  const _HomeworkFilter({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text('$label  $count',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: selected
                        ? const Color(0xFF252943)
                        : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700)),
          ),
        ),
      );
}

class _HomeworkAssignmentCard extends StatelessWidget {
  const _HomeworkAssignmentCard({
    required this.homework,
    required this.onStatusChanged,
  });
  final Homework homework;
  final ValueChanged<bool> onStatusChanged;

  (Color, IconData) get _style => switch (homework.subject) {
        'Mathematics' => (const Color(0xFF3157C8), Icons.calculate_rounded),
        'Science' => (const Color(0xFF07966C), Icons.science_rounded),
        'English' => (const Color(0xFF8A43C6), Icons.menu_book_rounded),
        'Social Studies' => (const Color(0xFFD57912), Icons.public_rounded),
        _ => (const Color(0xFF64748B), Icons.assignment_rounded),
      };

  String get _dueText {
    if (homework.completed) {
      final updated = homework.statusUpdatedAt;
      return updated == null
          ? 'Completed'
          : 'Marked done ${shortDate.format(updated)}';
    }
    final today = DateUtils.dateOnly(DateTime.now());
    final due = DateUtils.dateOnly(homework.dueDate);
    final days = due.difference(today).inDays;
    if (days < 0) {
      return 'Overdue by ${days.abs()} ${days.abs() == 1 ? 'day' : 'days'}';
    }
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due ${shortDate.format(homework.dueDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style;
    final today = DateUtils.dateOnly(DateTime.now());
    final overdue = !homework.completed &&
        DateUtils.dateOnly(homework.dueDate).isBefore(today);
    final statusColor = homework.completed
        ? const Color(0xFF07966C)
        : overdue
            ? const Color(0xFFD14A45)
            : const Color(0xFFD57912);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: homework.completed ? const Color(0xFFFCFDFC) : Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: homework.completed
              ? const Color(0xFFCDE9DE)
              : overdue
                  ? const Color(0xFFF0C2BE)
                  : const Color(0xFFE4E5EA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(homework.subject.toUpperCase(),
                  style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7)),
              const SizedBox(height: 3),
              Text(homework.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, height: 1.25)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
                homework.completed
                    ? 'DONE'
                    : overdue
                        ? 'OVERDUE'
                        : 'PENDING',
                style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 13),
        Text(homework.instructions,
            style: const TextStyle(
                color: Color(0xFF526173), fontSize: 11, height: 1.45)),
        const SizedBox(height: 13),
        Row(children: [
          const Icon(Icons.person_outline_rounded,
              color: Color(0xFF94A3B8), size: 15),
          const SizedBox(width: 5),
          Text(homework.teacher,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
          const SizedBox(width: 13),
          const Icon(Icons.event_note_outlined,
              color: Color(0xFF94A3B8), size: 15),
          const SizedBox(width: 5),
          Expanded(
            child: Text('Assigned ${shortDate.format(homework.assignedDate)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(
                homework.completed
                    ? Icons.task_alt_rounded
                    : Icons.schedule_rounded,
                color: statusColor,
                size: 17),
            const SizedBox(width: 7),
            Expanded(
              child: Text(_dueText,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
            if (homework.completed)
              const Row(children: [
                Icon(Icons.cloud_done_outlined,
                    color: Color(0xFF07966C), size: 14),
                SizedBox(width: 4),
                Text('Shared with school',
                    style: TextStyle(
                        color: Color(0xFF07966C),
                        fontSize: 8,
                        fontWeight: FontWeight.w700)),
              ]),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: homework.completed
              ? OutlinedButton.icon(
                  onPressed: () => onStatusChanged(false),
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Mark as pending'),
                )
              : FilledButton.icon(
                  onPressed: () => onStatusChanged(true),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3157C8)),
                  icon:
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Mark as done'),
                ),
        ),
      ]),
    );
  }
}

class _HomeworkEmptyState extends StatelessWidget {
  const _HomeworkEmptyState();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(children: [
          Icon(Icons.task_alt_rounded, color: Color(0xFF07966C), size: 38),
          SizedBox(height: 10),
          Text('No assignments in this section',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );
}

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late DateTime _selectedDate;

  static const _weeklyLessons = <int, List<_TimetableLesson>>{
    DateTime.monday: [
      _TimetableLesson(1, '08:30 – 09:15', 'English', 'Ms. Wilson', 'Room 204',
          Icons.menu_book_rounded, Color(0xFF8A43C6)),
      _TimetableLesson(2, '09:15 – 10:00', 'Mathematics', 'Ms. Rao', 'Room 204',
          Icons.calculate_rounded, Color(0xFF3157C8)),
      _TimetableLesson(3, '10:20 – 11:05', 'Science', 'Mr. Sharma',
          'Science Lab', Icons.science_rounded, Color(0xFF07966C)),
      _TimetableLesson(4, '11:05 – 11:50', 'Computer Science', 'Mr. Reddy',
          'Computer Lab', Icons.computer_rounded, Color(0xFF097A9B)),
      _TimetableLesson(5, '12:30 – 01:15', 'Social Studies', 'Ms. Khan',
          'Room 204', Icons.public_rounded, Color(0xFFD57912)),
      _TimetableLesson(6, '01:15 – 02:00', 'Physical Education', 'Mr. Arjun',
          'School Ground', Icons.sports_basketball_rounded, Color(0xFFD14A45)),
    ],
    DateTime.tuesday: [
      _TimetableLesson(1, '08:30 – 09:15', 'Mathematics', 'Ms. Rao', 'Room 204',
          Icons.calculate_rounded, Color(0xFF3157C8)),
      _TimetableLesson(2, '09:15 – 10:00', 'Hindi', 'Mrs. Verma', 'Room 204',
          Icons.translate_rounded, Color(0xFFDB2777)),
      _TimetableLesson(3, '10:20 – 11:05', 'English', 'Ms. Wilson', 'Room 204',
          Icons.menu_book_rounded, Color(0xFF8A43C6)),
      _TimetableLesson(4, '11:05 – 11:50', 'Science Lab', 'Mr. Sharma',
          'Science Lab', Icons.biotech_rounded, Color(0xFF07966C)),
      _TimetableLesson(5, '12:30 – 01:15', 'Computer Science', 'Mr. Reddy',
          'Computer Lab', Icons.computer_rounded, Color(0xFF097A9B)),
      _TimetableLesson(6, '01:15 – 02:00', 'Visual Arts', 'Ms. Meera',
          'Art Studio', Icons.palette_rounded, Color(0xFFE56B38)),
    ],
    DateTime.wednesday: [
      _TimetableLesson(1, '08:30 – 09:15', 'English', 'Ms. Wilson', 'Room 204',
          Icons.menu_book_rounded, Color(0xFF8A43C6)),
      _TimetableLesson(2, '09:15 – 10:00', 'Science', 'Mr. Sharma', 'Room 204',
          Icons.science_rounded, Color(0xFF07966C)),
      _TimetableLesson(3, '10:20 – 11:05', 'Mathematics', 'Ms. Rao', 'Room 204',
          Icons.calculate_rounded, Color(0xFF3157C8)),
      _TimetableLesson(4, '11:05 – 11:50', 'Computer Science', 'Mr. Reddy',
          'Computer Lab', Icons.computer_rounded, Color(0xFF097A9B)),
      _TimetableLesson(5, '12:30 – 01:15', 'Social Studies', 'Ms. Khan',
          'Room 204', Icons.public_rounded, Color(0xFFD57912)),
      _TimetableLesson(6, '01:15 – 02:00', 'Physical Education', 'Mr. Arjun',
          'School Ground', Icons.sports_basketball_rounded, Color(0xFFD14A45)),
    ],
    DateTime.thursday: [
      _TimetableLesson(1, '08:30 – 09:15', 'Hindi', 'Mrs. Verma', 'Room 204',
          Icons.translate_rounded, Color(0xFFDB2777)),
      _TimetableLesson(2, '09:15 – 10:00', 'Mathematics', 'Ms. Rao', 'Room 204',
          Icons.calculate_rounded, Color(0xFF3157C8)),
      _TimetableLesson(3, '10:20 – 11:05', 'Science', 'Mr. Sharma', 'Room 204',
          Icons.science_rounded, Color(0xFF07966C)),
      _TimetableLesson(4, '11:05 – 11:50', 'English', 'Ms. Wilson', 'Room 204',
          Icons.menu_book_rounded, Color(0xFF8A43C6)),
      _TimetableLesson(5, '12:30 – 01:15', 'Computer Lab', 'Mr. Reddy',
          'Computer Lab', Icons.memory_rounded, Color(0xFF097A9B)),
      _TimetableLesson(6, '01:15 – 02:00', 'Library', 'Mrs. Joseph',
          'Main Library', Icons.local_library_rounded, Color(0xFF6D4AFF)),
    ],
    DateTime.friday: [
      _TimetableLesson(1, '08:30 – 09:15', 'Mathematics', 'Ms. Rao', 'Room 204',
          Icons.calculate_rounded, Color(0xFF3157C8)),
      _TimetableLesson(2, '09:15 – 10:00', 'English', 'Ms. Wilson', 'Room 204',
          Icons.menu_book_rounded, Color(0xFF8A43C6)),
      _TimetableLesson(3, '10:20 – 11:05', 'Social Studies', 'Ms. Khan',
          'Room 204', Icons.public_rounded, Color(0xFFD57912)),
      _TimetableLesson(4, '11:05 – 11:50', 'Science', 'Mr. Sharma', 'Room 204',
          Icons.science_rounded, Color(0xFF07966C)),
      _TimetableLesson(5, '12:30 – 01:15', 'Hindi', 'Mrs. Verma', 'Room 204',
          Icons.translate_rounded, Color(0xFFDB2777)),
      _TimetableLesson(6, '01:15 – 02:00', 'Life Skills', 'Ms. Nisha',
          'Activity Room', Icons.psychology_rounded, Color(0xFFE56B38)),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
  }

  DateTime get _weekStart =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  bool _isHoliday(DateTime date) =>
      (date.month == 8 && date.day == 15) ||
      (date.month == 10 && date.day == 2) ||
      (date.month == 12 && date.day == 25);

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 6),
      lastDate: DateTime(2027, 4, 30),
      helpText: 'Select timetable date',
    );
    if (selected != null && mounted) {
      setState(() => _selectedDate = DateUtils.dateOnly(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _isHoliday(_selectedDate)
        ? const <_TimetableLesson>[]
        : _weeklyLessons[_selectedDate.weekday] ?? const <_TimetableLesson>[];
    final weekDays =
        List.generate(7, (index) => _weekStart.add(Duration(days: index)));
    final today = DateUtils.dateOnly(DateTime.now());
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Class timetable'),
        actions: [
          IconButton(
            tooltip: 'Open calendar',
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _TimetableHero(
            selectedDate: _selectedDate,
            lessonCount: lessons.length,
            isToday: _sameDay(_selectedDate, today),
          ),
          const SizedBox(height: 18),
          _TimetableWeekPicker(
            weekDays: weekDays,
            selectedDate: _selectedDate,
            today: today,
            onSelect: (date) => setState(() => _selectedDate = date),
            onPreviousWeek: () => setState(() => _selectedDate =
                _selectedDate.subtract(const Duration(days: 7))),
            onNextWeek: () => setState(() =>
                _selectedDate = _selectedDate.add(const Duration(days: 7))),
            onCalendar: _pickDate,
          ),
          const SizedBox(height: 21),
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE’s periods').format(_selectedDate),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(DateFormat('dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 11)),
                  ]),
            ),
            if (!_sameDay(_selectedDate, today))
              TextButton(
                onPressed: () => setState(() => _selectedDate = today),
                child: const Text('Go to today'),
              ),
          ]),
          const SizedBox(height: 11),
          if (lessons.isEmpty)
            _NoTimetableState(
              isHoliday: _isHoliday(_selectedDate),
              isWeekend: _selectedDate.weekday >= DateTime.saturday,
            )
          else
            ...lessons.asMap().entries.expand((entry) {
              final widgets = <Widget>[
                _TimetableLessonCard(lesson: entry.value),
              ];
              if (entry.key == 1) {
                widgets.add(const _TimetableBreakRow(
                    icon: Icons.free_breakfast_rounded,
                    title: 'Morning break',
                    time: '10:00 – 10:20'));
              }
              if (entry.key == 3) {
                widgets.add(const _TimetableBreakRow(
                    icon: Icons.lunch_dining_rounded,
                    title: 'Lunch break',
                    time: '11:50 – 12:30'));
              }
              return widgets;
            }),
        ],
      ),
    );
  }
}

class _TimetableLesson {
  const _TimetableLesson(
    this.period,
    this.time,
    this.subject,
    this.teacher,
    this.room,
    this.icon,
    this.color,
  );
  final int period;
  final String time;
  final String subject;
  final String teacher;
  final String room;
  final IconData icon;
  final Color color;
}

class _TimetableHero extends StatelessWidget {
  const _TimetableHero({
    required this.selectedDate,
    required this.lessonCount,
    required this.isToday,
  });
  final DateTime selectedDate;
  final int lessonCount;
  final bool isToday;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF182C4F), Color(0xFF205A8D), Color(0xFF168A8C)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF205A8D).withValues(alpha: .23),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_view_day_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MARCUS’S SCHEDULE',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    SizedBox(height: 3),
                    Text('Grade 11 · Section B',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ]),
            ),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF70E0C0).withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('TODAY',
                    style: TextStyle(
                        color: Color(0xFF8DF0D3),
                        fontSize: 9,
                        fontWeight: FontWeight.w900)),
              ),
          ]),
          const SizedBox(height: 19),
          Text(DateFormat('EEEE').format(selectedDate),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900)),
          Text(DateFormat('dd MMMM yyyy').format(selectedDate),
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 17),
          Row(children: [
            _TimetableHeroDetail(
                icon: Icons.format_list_numbered_rounded,
                text: '$lessonCount periods'),
            const SizedBox(width: 18),
            if (lessonCount > 0)
              const _TimetableHeroDetail(
                  icon: Icons.schedule_rounded, text: '8:30 AM – 2:00 PM'),
          ]),
        ]),
      );
}

class _TimetableHeroDetail extends StatelessWidget {
  const _TimetableHeroDetail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: const Color(0xFFAED8F1), size: 16),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      ]);
}

class _TimetableWeekPicker extends StatelessWidget {
  const _TimetableWeekPicker({
    required this.weekDays,
    required this.selectedDate,
    required this.today,
    required this.onSelect,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCalendar,
  });
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCalendar;

  bool _same(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFE2E5E9)),
        ),
        child: Column(children: [
          Row(children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onPreviousWeek,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${DateFormat('dd MMM').format(weekDays.first)} – ${DateFormat('dd MMM yyyy').format(weekDays.last)}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onNextWeek,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Choose date',
              onPressed: onCalendar,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
          ]),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final selected = _same(date, selectedDate);
              final isToday = _same(date, today);
              final weekend = date.weekday >= DateTime.saturday;
              return InkWell(
                onTap: () => onSelect(date),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF205A8D)
                        : isToday
                            ? const Color(0xFFE7F4F7)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(children: [
                    Text(DateFormat('E').format(date).substring(0, 1),
                        style: TextStyle(
                            color: selected
                                ? Colors.white70
                                : weekend
                                    ? const Color(0xFFD14A45)
                                    : const Color(0xFF64748B),
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${date.day}',
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                  ]),
                ),
              );
            }).toList(),
          ),
        ]),
      );
}

class _TimetableLessonCard extends StatelessWidget {
  const _TimetableLessonCard({required this.lesson});
  final _TimetableLesson lesson;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4E6EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 60,
            decoration: BoxDecoration(
              color: lesson.color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${lesson.period}',
                  style: TextStyle(
                      color: lesson.color,
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text('PERIOD',
                  style: TextStyle(
                      color: lesson.color,
                      fontSize: 7,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: lesson.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(lesson.icon, color: lesson.color, size: 17),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(lesson.subject,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900)),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    color: Color(0xFF94A3B8), size: 14),
                const SizedBox(width: 4),
                Text(lesson.teacher,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 10)),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF94A3B8), size: 14),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(lesson.room,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 10)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text(lesson.time.replaceAll(' – ', '\n'),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 9,
                  height: 1.5,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _TimetableBreakRow extends StatelessWidget {
  const _TimetableBreakRow({
    required this.icon,
    required this.title,
    required this.time,
  });
  final IconData icon;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 11),
        child: Row(children: [
          const Expanded(child: Divider()),
          const SizedBox(width: 9),
          Icon(icon, color: const Color(0xFF94A3B8), size: 16),
          const SizedBox(width: 5),
          Text('$title  ·  $time',
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 9),
          const Expanded(child: Divider()),
        ]),
      );
}

class _NoTimetableState extends StatelessWidget {
  const _NoTimetableState({
    required this.isHoliday,
    required this.isWeekend,
  });
  final bool isHoliday;
  final bool isWeekend;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 38),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE4E6EA)),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
                color: Color(0xFFE7F4F7), shape: BoxShape.circle),
            child: Icon(
              isHoliday ? Icons.celebration_rounded : Icons.weekend_rounded,
              color: const Color(0xFF168A8C),
              size: 31,
            ),
          ),
          const SizedBox(height: 12),
          Text(isHoliday ? 'School holiday' : 'No classes scheduled',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            isHoliday
                ? 'There is no regular timetable for this holiday.'
                : isWeekend
                    ? 'Enjoy the weekend. Select another date to view classes.'
                    : 'The school has not published periods for this date.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF64748B), fontSize: 11, height: 1.4),
          ),
        ]),
      );
}

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  bool _morning = true;

  static const _morningStops = [
    _BusStop('School bus depot', '6:50 AM', _BusStopState.completed),
    _BusStop('Jubilee Hills Check Post', '7:02 AM', _BusStopState.completed),
    _BusStop('Lake View Junction', '7:12 AM', _BusStopState.current),
    _BusStop('Central Park Stop · Your stop', '7:18 AM', _BusStopState.upcoming,
        isStudentStop: true),
    _BusStop('Green Valley Circle', '7:31 AM', _BusStopState.upcoming),
    _BusStop('Orison School Campus', '8:05 AM', _BusStopState.upcoming),
  ];

  static const _eveningStops = [
    _BusStop('Orison School Campus', '2:45 PM', _BusStopState.current),
    _BusStop('Green Valley Circle', '3:02 PM', _BusStopState.upcoming),
    _BusStop('Central Park Stop · Your stop', '3:18 PM', _BusStopState.upcoming,
        isStudentStop: true),
    _BusStop('Lake View Junction', '3:25 PM', _BusStopState.upcoming),
    _BusStop('Jubilee Hills Check Post', '3:34 PM', _BusStopState.upcoming),
    _BusStop('School bus depot', '3:48 PM', _BusStopState.upcoming),
  ];

  @override
  Widget build(BuildContext context) {
    final stops = _morning ? _morningStops : _eveningStops;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(title: const Text('School transport')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _TransportHeader(),
          const SizedBox(height: 16),
          _JourneyTypeToggle(
            morning: _morning,
            onChanged: (value) => setState(() => _morning = value),
          ),
          const SizedBox(height: 14),
          _JourneyStatusCard(morning: _morning),
          const SizedBox(height: 14),
          _LiveTrackingPreview(
            morning: _morning,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _LiveBusTrackingPage(
                  morning: _morning,
                  stops: stops,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _StudentStopCard(morning: _morning),
          const SizedBox(height: 23),
          Row(children: [
            const Expanded(
              child: Text('Route progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(children: [
                Icon(Icons.gps_fixed_rounded,
                    color: Color(0xFF07966C), size: 13),
                SizedBox(width: 4),
                Text('GPS active',
                    style: TextStyle(
                        color: Color(0xFF07966C),
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ]),
          const SizedBox(height: 11),
          _BusRouteTimeline(stops: stops),
          const SizedBox(height: 23),
          const Text('Bus & route details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 11),
          const _BusDetailsCard(),
          const SizedBox(height: 14),
          const Text('Transport crew',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 11),
          const _TransportCrewCard(),
        ],
      ),
    );
  }
}

enum _BusStopState { completed, current, upcoming }

class _BusStop {
  const _BusStop(this.name, this.time, this.state,
      {this.isStudentStop = false});
  final String name;
  final String time;
  final _BusStopState state;
  final bool isStudentStop;
}

class _TransportHeader extends StatelessWidget {
  const _TransportHeader();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF112E38), Color(0xFF087D68), Color(0xFF20AA84)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF087D68).withValues(alpha: .24),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: const Row(children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white12,
            child: Icon(Icons.directions_bus_filled_rounded,
                color: Colors.white, size: 31),
          ),
          SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MARCUS’S SCHOOL BUS',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              SizedBox(height: 4),
              Text('Route 12 · Bus 24',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              Text('TS 09 AB 2412 · GPS connected',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
          Icon(Icons.verified_rounded, color: Color(0xFF87E7CA), size: 23),
        ]),
      );
}

class _JourneyTypeToggle extends StatelessWidget {
  const _JourneyTypeToggle({required this.morning, required this.onChanged});
  final bool morning;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6EAEC),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(children: [
          _JourneyChoice(
            selected: morning,
            icon: Icons.wb_sunny_outlined,
            label: 'Morning pickup',
            onTap: () => onChanged(true),
          ),
          _JourneyChoice(
            selected: !morning,
            icon: Icons.wb_twilight_outlined,
            label: 'Evening drop',
            onTap: () => onChanged(false),
          ),
        ]),
      );
}

class _JourneyChoice extends StatelessWidget {
  const _JourneyChoice({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  color: selected
                      ? const Color(0xFF087D68)
                      : const Color(0xFF64748B),
                  size: 17),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected
                          ? const Color(0xFF183F3B)
                          : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

class _JourneyStatusCard extends StatelessWidget {
  const _JourneyStatusCard({required this.morning});
  final bool morning;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDDE4E3)),
        ),
        child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  morning ? Icons.route_rounded : Icons.schedule_rounded,
                  color: const Color(0xFF07966C),
                  size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        morning
                            ? 'Bus journey in progress'
                            : 'Evening trip scheduled',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                        morning
                            ? 'Started from depot at 6:50 AM'
                            : 'Starts from school at 2:45 PM',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 10)),
                  ]),
            ),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                  color: Color(0xFF16B983), shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(morning ? 'LIVE' : 'READY',
                style: const TextStyle(
                    color: Color(0xFF07966C),
                    fontSize: 9,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _JourneyMetric(
                label: 'CURRENT LOCATION',
                value: morning ? 'Lake View Junction' : 'School Campus',
                icon: Icons.location_on_rounded,
                color: const Color(0xFF3157C8),
              ),
            ),
            Container(width: 1, height: 38, color: const Color(0xFFE4E7EA)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: _JourneyMetric(
                  label: 'YOUR STOP ETA',
                  value: morning ? '7:18 AM · 6 min' : '3:18 PM',
                  icon: Icons.timer_outlined,
                  color: const Color(0xFFD57912),
                ),
              ),
            ),
          ]),
        ]),
      );
}

class _JourneyMetric extends StatelessWidget {
  const _JourneyMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 8,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Expanded(
              child: Text(value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ]),
        ],
      );
}

class _LiveTrackingPreview extends StatelessWidget {
  const _LiveTrackingPreview({required this.morning, required this.onTap});
  final bool morning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFFDDECE8),
          border: Border.all(color: const Color(0xFFBBD6CF)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            SizedBox(
              width: double.infinity,
              height: 150,
              child: CustomPaint(
                  painter: _TransportMapPainter(progress: morning ? .47 : .08)),
            ),
            Positioned(
              left: 15,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  Icon(Icons.satellite_alt_rounded,
                      color: Color(0xFF087D68), size: 14),
                  SizedBox(width: 5),
                  Text('Live GPS map',
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ]),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: FilledButton.icon(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF142E36)),
                icon: const Icon(Icons.near_me_rounded, size: 17),
                label: const Text('Open live bus tracking'),
              ),
            ),
          ]),
        ),
      );
}

class _StudentStopCard extends StatelessWidget {
  const _StudentStopCard({required this.morning});
  final bool morning;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5DE), Color(0xFFFFFAF0)],
          ),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFF0D494)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: const BoxDecoration(
                color: Color(0xFFFFE7AD), shape: BoxShape.circle),
            child: const Icon(Icons.person_pin_circle_rounded,
                color: Color(0xFFB66B08), size: 25),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR ASSIGNED STOP',
                  style: TextStyle(
                      color: Color(0xFFB66B08),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7)),
              const SizedBox(height: 3),
              const Text('Central Park Stop',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              Text(
                  morning
                      ? 'Bus arrives in approximately 6 minutes'
                      : 'Expected drop at 3:18 PM',
                  style:
                      const TextStyle(color: Color(0xFF745D38), fontSize: 10)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(morning ? '7:18' : '3:18',
                style: const TextStyle(
                    color: Color(0xFF9A5C08),
                    fontSize: 19,
                    fontWeight: FontWeight.w900)),
            Text(morning ? 'AM' : 'PM',
                style: const TextStyle(
                    color: Color(0xFFB66B08),
                    fontSize: 9,
                    fontWeight: FontWeight.w800)),
          ]),
        ]),
      );
}

class _BusRouteTimeline extends StatelessWidget {
  const _BusRouteTimeline({required this.stops});
  final List<_BusStop> stops;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1E5E6)),
        ),
        child: Column(
          children: stops.asMap().entries.map((entry) {
            final stop = entry.value;
            final completed = stop.state == _BusStopState.completed;
            final current = stop.state == _BusStopState.current;
            final color = current
                ? const Color(0xFF3157C8)
                : completed
                    ? const Color(0xFF07966C)
                    : const Color(0xFFBCC4CC);
            return IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(children: [
                        Container(
                          width: current ? 18 : 14,
                          height: current ? 18 : 14,
                          decoration: BoxDecoration(
                            color: current ? Colors.white : color,
                            shape: BoxShape.circle,
                            border: current
                                ? Border.all(color: color, width: 4)
                                : null,
                          ),
                        ),
                        if (entry.key != stops.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: completed || current
                                  ? const Color(0xFF90CDBB)
                                  : const Color(0xFFDDE2E6),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Flexible(
                                      child: Text(stop.name,
                                          style: TextStyle(
                                              color: current
                                                  ? const Color(0xFF1E3A65)
                                                  : const Color(0xFF334155),
                                              fontSize: 11,
                                              fontWeight:
                                                  current || stop.isStudentStop
                                                      ? FontWeight.w900
                                                      : FontWeight.w700)),
                                    ),
                                    if (current) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8EEFF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text('BUS HERE',
                                            style: TextStyle(
                                                color: Color(0xFF3157C8),
                                                fontSize: 7,
                                                fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ]),
                                  if (stop.isStudentStop)
                                    const Text('Marcus’s pickup / drop point',
                                        style: TextStyle(
                                            color: Color(0xFFB66B08),
                                            fontSize: 8)),
                                ]),
                          ),
                          Text(stop.time,
                              style: TextStyle(
                                  color:
                                      current ? color : const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: current
                                      ? FontWeight.w900
                                      : FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ]),
            );
          }).toList(),
        ),
      );
}

class _BusDetailsCard extends StatelessWidget {
  const _BusDetailsCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFF17262D),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Column(children: [
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white10,
              child:
                  Icon(Icons.airport_shuttle_rounded, color: Color(0xFF82DFC4)),
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bus 24 · Route 12',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900)),
                    Text('Registration TS 09 AB 2412',
                        style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ]),
            ),
            Icon(Icons.gps_fixed_rounded, color: Color(0xFF82DFC4), size: 20),
          ]),
          SizedBox(height: 15),
          Divider(color: Colors.white12, height: 1),
          SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _DarkBusMetric(label: 'VEHICLE', value: 'Tata Starbus')),
            Expanded(
                child: _DarkBusMetric(label: 'CAPACITY', value: '42 seats')),
            Expanded(
                child:
                    _DarkBusMetric(label: 'EMERGENCY', value: '040 4455 2200')),
          ]),
        ]),
      );
}

class _DarkBusMetric extends StatelessWidget {
  const _DarkBusMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 7,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ],
      );
}

class _TransportCrewCard extends StatelessWidget {
  const _TransportCrewCard();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1E5E6)),
        ),
        child: const Column(children: [
          _CrewMember(
            initials: 'RK',
            name: 'Ramesh Kumar',
            role: 'Driver · Employee TR-1042',
            phone: '+91 90000 12345',
            color: Color(0xFF3157C8),
          ),
          Divider(height: 1, indent: 16, endIndent: 16),
          _CrewMember(
            initials: 'SL',
            name: 'Sunita Lakshmi',
            role: 'Bus attendant · Employee TR-1088',
            phone: '+91 90000 67890',
            color: Color(0xFF8A43C6),
          ),
        ]),
      );
}

class _CrewMember extends StatelessWidget {
  const _CrewMember({
    required this.initials,
    required this.name,
    required this.role,
    required this.phone,
    required this.color,
  });
  final String initials;
  final String name;
  final String role;
  final String phone;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(15),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .1),
            child: Text(initials,
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900)),
              Text(role,
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
              const SizedBox(height: 3),
              Text(phone,
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone_outlined, color: color, size: 18),
          ),
        ]),
      );
}

class _LiveBusTrackingPage extends StatefulWidget {
  const _LiveBusTrackingPage({
    required this.morning,
    required this.stops,
  });
  final bool morning;
  final List<_BusStop> stops;

  @override
  State<_LiveBusTrackingPage> createState() => _LiveBusTrackingPageState();
}

class _LiveBusTrackingPageState extends State<_LiveBusTrackingPage> {
  late Timer _refreshTimer;
  late DateTime _lastUpdated;

  @override
  void initState() {
    super.initState();
    _lastUpdated = DateTime.now();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => _lastUpdated = DateTime.now());
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        appBar: AppBar(title: const Text('Live bus tracking')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDDECE8),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFBDD4CE)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(children: [
                  SizedBox(
                    width: double.infinity,
                    height: 310,
                    child: CustomPaint(
                      painter: _TransportMapPainter(
                          progress: widget.morning ? .47 : .08),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .94),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Row(children: [
                        Icon(Icons.gps_fixed_rounded,
                            color: Color(0xFF07966C), size: 15),
                        SizedBox(width: 5),
                        Text('GPS LIVE',
                            style: TextStyle(
                                color: Color(0xFF07966C),
                                fontSize: 9,
                                fontWeight: FontWeight.w900)),
                      ]),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17262D),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(DateFormat('hh:mm:ss a').format(_lastUpdated),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .95),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFE5F7F1),
                          child: Icon(Icons.directions_bus_filled_rounded,
                              color: Color(0xFF087D68)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    widget.morning
                                        ? 'Approaching Central Park Stop'
                                        : 'Waiting at Orison School Campus',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900)),
                                Text(
                                    widget.morning
                                        ? '1.8 km away · Normal traffic'
                                        : 'Evening trip starts at 2:45 PM',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B), fontSize: 9)),
                              ]),
                        ),
                        Column(children: [
                          Text(widget.morning ? '6' : '—',
                              style: const TextStyle(
                                  color: Color(0xFFD57912),
                                  fontSize: 21,
                                  height: 1,
                                  fontWeight: FontWeight.w900)),
                          Text(widget.morning ? 'MIN' : 'MIN',
                              style: const TextStyle(
                                  color: Color(0xFFD57912),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900)),
                        ]),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 15),
            _StudentStopCard(morning: widget.morning),
            const SizedBox(height: 20),
            const Text('Complete route',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 11),
            _BusRouteTimeline(stops: widget.stops),
          ],
        ),
      );
}

class _TransportMapPainter extends CustomPainter {
  const _TransportMapPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCADBD6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (.12 + i * .16);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 24), roadPaint);
    }
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.08 + i * .23);
      canvas.drawLine(Offset(x, 0), Offset(x + 45, size.height), roadPaint);
    }

    final route = Path()
      ..moveTo(size.width * .08, size.height * .78)
      ..cubicTo(size.width * .25, size.height * .72, size.width * .24,
          size.height * .38, size.width * .46, size.height * .44)
      ..cubicTo(size.width * .67, size.height * .5, size.width * .68,
          size.height * .18, size.width * .92, size.height * .22);
    final routePaint = Paint()
      ..color = const Color(0xFF159574)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(route, routePaint);

    final metrics = route.computeMetrics().first;
    final busPosition =
        metrics.getTangentForOffset(metrics.length * progress)!.position;
    canvas.drawCircle(
        busPosition, 16, Paint()..color = Colors.white.withValues(alpha: .95));
    canvas.drawCircle(
        busPosition, 11, Paint()..color = const Color(0xFFC91425));
    canvas.drawCircle(Offset(size.width * .80, size.height * .29), 10,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * .80, size.height * .29), 6,
        Paint()..color = const Color(0xFFD57912));
  }

  @override
  bool shouldRepaint(covariant _TransportMapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _filters = [
    'All',
    'Unread',
    'Academics',
    'Fees',
    'Events',
    'Transport',
  ];
  String _filter = 'All';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        appBar: AppBar(title: const Text('School notices')),
        body: BlocBuilder<ParentBloc, ParentState>(builder: (context, state) {
          final ready = state as ParentReady;
          final notices = ready.data.notices;
          final unread = notices.where((notice) => notice.unread).length;
          final urgent =
              notices.where((notice) => notice.priority == 'Urgent').length;
          final visible = notices.where((notice) {
            if (_filter == 'All') return true;
            if (_filter == 'Unread') return notice.unread;
            return notice.category == _filter;
          }).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _NoticeCenterHero(
                total: notices.length,
                unread: unread,
                urgent: urgent,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = filter == _filter;
                    final count = filter == 'All'
                        ? notices.length
                        : filter == 'Unread'
                            ? unread
                            : notices
                                .where((notice) => notice.category == filter)
                                .length;
                    return ChoiceChip(
                      selected: selected,
                      label: Text('$filter  $count'),
                      onSelected: (_) => setState(() => _filter = filter),
                      selectedColor: const Color(0xFF29233F),
                      labelStyle: TextStyle(
                        color:
                            selected ? Colors.white : const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF29233F)
                            : const Color(0xFFDDE0E4),
                      ),
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: Text(
                    _filter == 'All' ? 'Latest notices' : '$_filter notices',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Text('${visible.length} notices',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 10)),
              ]),
              const SizedBox(height: 11),
              if (visible.isEmpty)
                const _NoticeEmptyState()
              else
                ...visible.map((notice) => _NoticeCard(
                      notice: notice,
                      onTap: () {
                        if (notice.unread) {
                          context
                              .read<ParentBloc>()
                              .add(NoticeOpened(notice.id));
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _NoticeDetailPage(notice: notice),
                          ),
                        );
                      },
                    )),
            ],
          );
        }),
      );
}

(Color, IconData) _noticeCategoryStyle(String category) => switch (category) {
      'Academics' => (const Color(0xFF3157C8), Icons.school_rounded),
      'Fees' => (const Color(0xFFD14A45), Icons.account_balance_wallet_rounded),
      'Events' => (const Color(0xFF8A43C6), Icons.event_available_rounded),
      'Transport' => (
          const Color(0xFF07966C),
          Icons.directions_bus_filled_rounded
        ),
      _ => (const Color(0xFF64748B), Icons.campaign_rounded),
    };

String _noticeTimeLabel(DateTime time) {
  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final date = DateUtils.dateOnly(time);
  final days = today.difference(date).inDays;
  if (days == 0) return 'Today · ${DateFormat('h:mm a').format(time)}';
  if (days == 1) return 'Yesterday · ${DateFormat('h:mm a').format(time)}';
  return DateFormat('dd MMM yyyy').format(time);
}

class _NoticeCenterHero extends StatelessWidget {
  const _NoticeCenterHero({
    required this.total,
    required this.unread,
    required this.urgent,
  });
  final int total;
  final int unread;
  final int urgent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF261B35), Color(0xFF642652), Color(0xFFC53246)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A294F).withValues(alpha: .23),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: Colors.white12,
              child: Icon(Icons.notifications_active_rounded,
                  color: Colors.white, size: 28),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PARENT NOTICE CENTER',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    SizedBox(height: 4),
                    Text('Stay informed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                    Text('Official updates from Orison School',
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ]),
            ),
          ]),
          const SizedBox(height: 19),
          Row(children: [
            Expanded(
              child: _NoticeHeroMetric(
                  value: '$total',
                  label: 'All notices',
                  icon: Icons.inbox_rounded),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _NoticeHeroMetric(
                  value: '$unread',
                  label: 'Unread',
                  icon: Icons.mark_email_unread_rounded,
                  accent: const Color(0xFFFFD166)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _NoticeHeroMetric(
                  value: '$urgent',
                  label: 'Urgent',
                  icon: Icons.priority_high_rounded,
                  accent: const Color(0xFFFF9B94)),
            ),
          ]),
        ]),
      );
}

class _NoticeHeroMetric extends StatelessWidget {
  const _NoticeHeroMetric({
    required this.value,
    required this.label,
    required this.icon,
    this.accent = const Color(0xFFD8CAFF),
  });
  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, color: accent, size: 17),
          const SizedBox(width: 7),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(label,
                maxLines: 2,
                style: const TextStyle(color: Colors.white60, fontSize: 8)),
          ),
        ]),
      );
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice, required this.onTap});
  final Notice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _noticeCategoryStyle(notice.category);
    final urgent = notice.priority == 'Urgent';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: urgent
              ? const Color(0xFFF0B7B2)
              : notice.unread
                  ? color.withValues(alpha: .3)
                  : const Color(0xFFE4E5E9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .028),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .09),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(notice.category.toUpperCase(),
                              style: TextStyle(
                                  color: color,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .5)),
                        ),
                        if (urgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEA),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Text('URGENT',
                                style: TextStyle(
                                    color: Color(0xFFD14A45),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ],
                        const Spacer(),
                        if (notice.unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                      ]),
                      const SizedBox(height: 7),
                      Text(notice.title,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              fontWeight: notice.unread
                                  ? FontWeight.w900
                                  : FontWeight.w800)),
                    ]),
              ),
            ]),
            const SizedBox(height: 11),
            Text(notice.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF5F6C7B), fontSize: 10, height: 1.45)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.account_balance_outlined,
                  color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(notice.issuer,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
              ),
              if (notice.attachmentName != null) ...[
                const Icon(Icons.attachment_rounded,
                    color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 8),
              ],
              Text(_noticeTimeLabel(notice.time),
                  style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8), size: 17),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _NoticeDetailPage extends StatelessWidget {
  const _NoticeDetailPage({required this.notice});
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _noticeCategoryStyle(notice.category);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('Notice details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: .95),
                  color.withValues(alpha: .7)
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .2),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white12,
                  child: Icon(icon, color: Colors.white, size: 25),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(notice.priority.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900)),
                ),
              ]),
              const SizedBox(height: 17),
              Text(notice.category.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9)),
              const SizedBox(height: 5),
              Text(notice.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.25,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE4E5E9)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF0F1F4),
                  child: Icon(Icons.account_balance_rounded,
                      color: Color(0xFF64748B), size: 18),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notice.issuer,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w900)),
                        Text(_noticeTimeLabel(notice.time),
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 9)),
                      ]),
                ),
                const Row(children: [
                  Icon(Icons.done_all_rounded,
                      color: Color(0xFF07966C), size: 16),
                  SizedBox(width: 4),
                  Text('Read',
                      style: TextStyle(
                          color: Color(0xFF07966C),
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ]),
              ]),
              const SizedBox(height: 17),
              const Divider(height: 1),
              const SizedBox(height: 17),
              Text(notice.body,
                  style: const TextStyle(
                      color: Color(0xFF334155), fontSize: 13, height: 1.65)),
              if (notice.attachmentName != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: .16)),
                  ),
                  child: Row(children: [
                    Icon(Icons.picture_as_pdf_rounded, color: color, size: 27),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Attached document',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w900)),
                            Text(notice.attachmentName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF64748B), fontSize: 9)),
                          ]),
                    ),
                    IconButton(
                      tooltip: 'Download attachment',
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Attachment will download from the school server.')),
                      ),
                      icon: Icon(Icons.download_rounded, color: color),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _NoticeEmptyState extends StatelessWidget {
  const _NoticeEmptyState();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFE4E5E9)),
        ),
        child: const Column(children: [
          Icon(Icons.notifications_off_outlined,
              color: Color(0xFF94A3B8), size: 38),
          SizedBox(height: 10),
          Text('No notices in this section',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
      );
}

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});
  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  static const _leaveTypes = [
    'Medical leave',
    'Sick leave',
    'Family event',
    'Personal leave',
    'Emergency leave',
    'Other',
  ];

  DateTimeRange? _range;
  String _leaveType = _leaveTypes.first;
  String? _attachmentName;
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final value = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: _range,
      helpText: 'Select leave dates',
      saveText: 'Use these dates',
    );
    if (value != null && mounted) {
      setState(() => _range = value);
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _attachmentName = result.files.single.name);
    }
  }

  void _submit(ParentReady ready) {
    final range = _range;
    if (range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select the leave dates from the calendar.')),
      );
      return;
    }
    context.read<ParentBloc>().add(LeaveSubmitted(
          studentId: ready.student.id,
          from: range.start,
          to: range.end,
          type: _leaveType,
          description: _description.text.trim(),
          attachmentName: _attachmentName,
        ));
    setState(() {
      _range = null;
      _leaveType = _leaveTypes.first;
      _attachmentName = null;
      _description.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = context.watch<ParentBloc>().state as ParentReady;
    final requests = ready.data.leaveRequests;
    final pending = requests.where((item) => item.status == 'Pending').length;
    final approved = requests.where((item) => item.status == 'Approved').length;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('Student leave')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _LeaveHero(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E5EA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .035),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0xFFEAF4FF),
                  child: Icon(Icons.add_task_rounded,
                      color: Color(0xFF3157C8), size: 21),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Apply new leave',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w900)),
                        Text('The class teacher will review this request',
                            style: TextStyle(
                                color: Color(0xFF64748B), fontSize: 10)),
                      ]),
                ),
              ]),
              const SizedBox(height: 18),
              const _LeaveFieldLabel(
                  number: '1', label: 'Select dates from calendar'),
              const SizedBox(height: 9),
              _LeaveDateSelector(range: _range, onTap: _pickRange),
              const SizedBox(height: 18),
              const _LeaveFieldLabel(number: '2', label: 'Choose leave type'),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: _leaveType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                  labelText: 'Type of leave',
                ),
                items: _leaveTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _leaveType = value);
                },
              ),
              const SizedBox(height: 18),
              const _LeaveFieldLabel(
                  number: '3', label: 'Description and attachment'),
              const SizedBox(height: 9),
              TextField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add any details the class teacher should know',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 66),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              _LeaveAttachmentField(
                fileName: _attachmentName,
                onAttach: _pickAttachment,
                onRemove: () => setState(() => _attachmentName = null),
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => _submit(ready),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3157C8)),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit leave request'),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Leave request summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Current academic year',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 11),
          Row(children: [
            Expanded(
              child: _LeaveSummaryCard(
                label: 'Applied',
                value: '${requests.length}',
                icon: Icons.description_outlined,
                color: const Color(0xFF3157C8),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _LeaveSummaryCard(
                label: 'Pending',
                value: '$pending',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFD57912),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _LeaveSummaryCard(
                label: 'Approved',
                value: '$approved',
                icon: Icons.verified_rounded,
                color: const Color(0xFF07966C),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            const Expanded(
              child: Text('Request history',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Text('${requests.length} requests',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
          ]),
          const SizedBox(height: 11),
          ...requests.map((request) => _LeaveRequestCard(request: request)),
        ],
      ),
    );
  }
}

class _LeaveHero extends StatelessWidget {
  const _LeaveHero();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF253657), Color(0xFF3D6692), Color(0xFF28A18B)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D6692).withValues(alpha: .22),
              blurRadius: 23,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white12,
            child: Icon(Icons.medical_information_rounded,
                color: Colors.white, size: 28),
          ),
          SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LEAVE REQUEST CENTER',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              SizedBox(height: 4),
              Text('Marcus Thorne',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              Text('Grade 11 · Section B · Roll 042',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
        ]),
      );
}

class _LeaveFieldLabel extends StatelessWidget {
  const _LeaveFieldLabel({required this.number, required this.label});
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: const Color(0xFF253657),
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 7),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ]);
}

class _LeaveDateSelector extends StatelessWidget {
  const _LeaveDateSelector({required this.range, required this.onTap});
  final DateTimeRange? range;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final days =
        range == null ? 0 : range!.end.difference(range!.start).inDays + 1;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              range == null ? const Color(0xFFF8F9FB) : const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
              color: range == null
                  ? const Color(0xFFDCDDE3)
                  : const Color(0xFFA9C7EC)),
        ),
        child: range == null
            ? const Row(children: [
                Icon(Icons.date_range_rounded, color: Color(0xFF3157C8)),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Tap to select start and end dates',
                      style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ])
            : Row(children: [
                _LeaveDateValue(label: 'FROM', date: range!.start),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: Color(0xFF7E9ABA), size: 18),
                ),
                _LeaveDateValue(label: 'TO', date: range!.end),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3157C8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$days ${days == 1 ? 'day' : 'days'}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ]),
      ),
    );
  }
}

class _LeaveDateValue extends StatelessWidget {
  const _LeaveDateValue({required this.label, required this.date});
  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF7E9ABA),
                  fontSize: 8,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(DateFormat('dd MMM').format(date),
              style: const TextStyle(
                  color: Color(0xFF253657),
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
        ],
      );
}

class _LeaveAttachmentField extends StatelessWidget {
  const _LeaveAttachmentField({
    required this.fileName,
    required this.onAttach,
    required this.onRemove,
  });
  final String? fileName;
  final VoidCallback onAttach;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fileName == null
              ? const Color(0xFFF8F9FB)
              : const Color(0xFFEAF8F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: fileName == null
                  ? const Color(0xFFDCDDE3)
                  : const Color(0xFF8BCDB8)),
        ),
        child: Row(children: [
          Icon(
              fileName == null
                  ? Icons.attach_file_rounded
                  : Icons.check_circle_rounded,
              color: fileName == null
                  ? const Color(0xFF64748B)
                  : const Color(0xFF07966C)),
          const SizedBox(width: 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fileName ?? 'Add attachment (optional)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800)),
              Text(
                  fileName == null
                      ? 'PDF, JPG or PNG · Medical proof if needed'
                      : 'Ready to submit',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
            ]),
          ),
          if (fileName != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
            )
          else
            TextButton(onPressed: onAttach, child: const Text('Browse')),
        ]),
      );
}

class _LeaveSummaryCard extends StatelessWidget {
  const _LeaveSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _LeaveRequestCard extends StatelessWidget {
  const _LeaveRequestCard({required this.request});
  final LeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final color = request.status == 'Approved'
        ? const Color(0xFF07966C)
        : request.status == 'Pending'
            ? const Color(0xFFD57912)
            : const Color(0xFFD14A45);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E5E9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                request.status == 'Approved'
                    ? Icons.verified_rounded
                    : Icons.hourglass_top_rounded,
                color: color,
                size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request.type,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(
                request.days == 1
                    ? shortDate.format(request.from)
                    : '${shortDate.format(request.from)} – ${shortDate.format(request.to)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(request.status.toUpperCase(),
                style: TextStyle(
                    color: color, fontSize: 8, fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _LeaveHistoryMeta(
              icon: Icons.calendar_view_day_rounded,
              text: '${request.days} ${request.days == 1 ? 'day' : 'days'}'),
          const SizedBox(width: 14),
          _LeaveHistoryMeta(
              icon: Icons.send_outlined,
              text: 'Applied ${shortDate.format(request.appliedOn)}'),
        ]),
        if (request.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(request.description,
              style: const TextStyle(
                  color: Color(0xFF526173), fontSize: 10, height: 1.4)),
        ],
        if (request.attachmentName != null) ...[
          const SizedBox(height: 9),
          Row(children: [
            const Icon(Icons.attachment_rounded,
                color: Color(0xFF3157C8), size: 15),
            const SizedBox(width: 4),
            Expanded(
              child: Text(request.attachmentName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF3157C8),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _LeaveHistoryMeta extends StatelessWidget {
  const _LeaveHistoryMeta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 14),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
      ]);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController name;
  late final TextEditingController mobile;
  late final TextEditingController alternateMobile;
  late final TextEditingController email;
  late final TextEditingController occupation;
  late final TextEditingController address;
  late final TextEditingController emergencyName;
  late final TextEditingController emergencyMobile;
  late String relationship;
  late String preferredLanguage;
  late bool pushNotifications;
  late bool whatsAppUpdates;
  late bool emailUpdates;

  @override
  void initState() {
    super.initState();
    final p = (context.read<ParentBloc>().state as ParentReady).data.profile;
    name = TextEditingController(text: p.name);
    mobile = TextEditingController(text: p.mobile);
    alternateMobile = TextEditingController(text: p.alternateMobile);
    email = TextEditingController(text: p.email);
    occupation = TextEditingController(text: p.occupation);
    address = TextEditingController(text: p.address);
    emergencyName = TextEditingController(text: p.emergencyName);
    emergencyMobile = TextEditingController(text: p.emergencyMobile);
    relationship = p.relationship;
    preferredLanguage = p.preferredLanguage;
    pushNotifications = p.pushNotifications;
    whatsAppUpdates = p.whatsAppUpdates;
    emailUpdates = p.emailUpdates;
  }

  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    alternateMobile.dispose();
    email.dispose();
    occupation.dispose();
    address.dispose();
    emergencyName.dispose();
    emergencyMobile.dispose();
    super.dispose();
  }

  void _save() {
    if (name.text.trim().isEmpty || mobile.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Enter a parent name and valid 10-digit mobile number.')));
      return;
    }
    context.read<ParentBloc>().add(ProfileSaved(ParentProfile(
          name: name.text.trim(),
          mobile: mobile.text.trim(),
          email: email.text.trim(),
          address: address.text.trim(),
          relationship: relationship,
          occupation: occupation.text.trim(),
          alternateMobile: alternateMobile.text.trim(),
          emergencyName: emergencyName.text.trim(),
          emergencyMobile: emergencyMobile.text.trim(),
          preferredLanguage: preferredLanguage,
          pushNotifications: pushNotifications,
          whatsAppUpdates: whatsAppUpdates,
          emailUpdates: emailUpdates,
        )));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ParentBloc>().state as ParentReady;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent profile'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF19191D), Color(0xFF591016)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    name.text.trim().characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('$relationship · Primary guardian',
                          style: const TextStyle(color: Colors.white60)),
                      const SizedBox(height: 9),
                      const Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              color: Color(0xFF7CE7B1), size: 16),
                          SizedBox(width: 5),
                          Text('Verified parent',
                              style: TextStyle(
                                  color: Color(0xFFB8F4D4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('FAMILY ID',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            letterSpacing: 1)),
                    SizedBox(height: 3),
                    Text('OR-FM-1042',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _ProfileSectionTitle(
              icon: Icons.badge_outlined, title: 'Personal details'),
          const SizedBox(height: 9),
          _ProfileSection(
            children: [
              _ProfileField(
                  controller: name,
                  label: 'Full name',
                  icon: Icons.person_outline),
              DropdownButtonFormField<String>(
                initialValue: relationship,
                decoration: const InputDecoration(
                    labelText: 'Relationship to student',
                    prefixIcon: Icon(Icons.family_restroom_outlined)),
                items: const ['Mother', 'Father', 'Guardian']
                    .map((value) =>
                        DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => relationship = value);
                },
              ),
              _ProfileField(
                  controller: occupation,
                  label: 'Occupation',
                  icon: Icons.work_outline),
            ],
          ),
          const SizedBox(height: 20),
          const _ProfileSectionTitle(
              icon: Icons.contact_phone_outlined, title: 'Contact information'),
          const SizedBox(height: 9),
          _ProfileSection(
            children: [
              _ProfileField(
                controller: mobile,
                label: 'Primary mobile',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                suffix: const Icon(Icons.verified_rounded,
                    color: Color(0xFF16A36A), size: 19),
              ),
              _ProfileField(
                controller: alternateMobile,
                label: 'Alternate mobile',
                icon: Icons.phone_iphone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _ProfileField(
                controller: email,
                label: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _ProfileField(
                controller: address,
                label: 'Residential address',
                icon: Icons.home_outlined,
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ProfileSectionTitle(
              icon: Icons.emergency_outlined, title: 'Emergency contact'),
          const SizedBox(height: 9),
          _ProfileSection(
            children: [
              _ProfileField(
                  controller: emergencyName,
                  label: 'Contact name',
                  icon: Icons.person_outline),
              _ProfileField(
                controller: emergencyMobile,
                label: 'Emergency mobile',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ProfileSectionTitle(
              icon: Icons.school_outlined, title: 'Linked children'),
          const SizedBox(height: 9),
          Card(
            child: Column(
              children: state.data.students.indexed.map((entry) {
                final child = entry.$2;
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFE9E9),
                        child: Text(child.name.characters.first,
                            style: const TextStyle(
                                color: orisonRed, fontWeight: FontWeight.w800)),
                      ),
                      title: Text(child.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${child.className} · Roll ${child.roll}'),
                      trailing: const Icon(Icons.verified_user_outlined,
                          color: Colors.green),
                    ),
                    if (entry.$1 != state.data.students.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const _ProfileSectionTitle(
              icon: Icons.tune_outlined, title: 'Communication preferences'),
          const SizedBox(height: 9),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 5),
                  child: DropdownButtonFormField<String>(
                    initialValue: preferredLanguage,
                    decoration: const InputDecoration(
                        labelText: 'Preferred language',
                        prefixIcon: Icon(Icons.language_outlined)),
                    items: const ['English', 'Telugu', 'Hindi']
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => preferredLanguage = value);
                      }
                    },
                  ),
                ),
                SwitchListTile.adaptive(
                  value: pushNotifications,
                  onChanged: (value) =>
                      setState(() => pushNotifications = value),
                  title: const Text('App notifications'),
                  subtitle: const Text('Notices, attendance and school alerts'),
                ),
                SwitchListTile.adaptive(
                  value: whatsAppUpdates,
                  onChanged: (value) => setState(() => whatsAppUpdates = value),
                  title: const Text('WhatsApp updates'),
                  subtitle: const Text('Fee reminders and urgent messages'),
                ),
                SwitchListTile.adaptive(
                  value: emailUpdates,
                  onChanged: (value) => setState(() => emailUpdates = value),
                  title: const Text('Email updates'),
                  subtitle: const Text('Reports, receipts and newsletters'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save profile changes'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 19, color: orisonRed),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      );
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      );
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
        ),
      );
}

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  static final _upcomingExams = [
    _ParentExam(
      name: 'Unit Test III',
      dateLabel: '18 – 23 Sep 2026',
      startDate: DateTime(2026, 9, 18),
      detail: 'Timetable published',
      subjects: 6,
    ),
    _ParentExam(
      name: 'Quarterly Examination',
      dateLabel: '12 – 20 Oct 2026',
      startDate: DateTime(2026, 10, 12),
      detail: 'Schedule coming soon',
      subjects: 7,
    ),
  ];

  static const _completedExams = [
    _ParentExam(
      name: 'Term I Examination',
      dateLabel: 'Completed 25 Jul 2026',
      detail: 'Report card published',
      subjects: 6,
      scores: {
        'Mathematics': 96,
        'Science': 95,
        'English': 87,
        'Hindi': 85,
        'Social Studies': 91,
        'Computer Science': 97,
      },
    ),
    _ParentExam(
      name: 'Unit Test II',
      dateLabel: 'Completed 20 May 2026',
      detail: 'Report card published',
      subjects: 6,
      scores: {
        'Mathematics': 88,
        'Science': 90,
        'English': 91,
        'Hindi': 82,
        'Social Studies': 86,
        'Computer Science': 94,
      },
    ),
    _ParentExam(
      name: 'Unit Test I',
      dateLabel: 'Completed 10 Apr 2026',
      detail: 'Report card published',
      subjects: 6,
      scores: {
        'Mathematics': 84,
        'Science': 87,
        'English': 88,
        'Hindi': 80,
        'Social Studies': 83,
        'Computer Science': 90,
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final latest = _completedExams.first;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(title: const Text('Exams & results')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ExamCenterHero(
            nextExam: _upcomingExams.first,
            latestExam: latest,
            completedCount: _completedExams.length,
          ),
          const SizedBox(height: 24),
          const _ExamSectionTitle(
            title: 'Upcoming exams',
            subtitle: 'Schedules and preparation timeline',
            icon: Icons.event_available_rounded,
            color: Color(0xFF6D4AFF),
          ),
          const SizedBox(height: 12),
          ..._upcomingExams.asMap().entries.map(
                (entry) => _UpcomingExamCard(
                  exam: entry.value,
                  isNext: entry.key == 0,
                ),
              ),
          const SizedBox(height: 20),
          const _ExamSectionTitle(
            title: 'Completed exams',
            subtitle: 'Published marks and report cards',
            icon: Icons.verified_rounded,
            color: Color(0xFF07966C),
          ),
          const SizedBox(height: 12),
          ..._completedExams
              .take(2)
              .map((exam) => _CompletedExamCard(exam: exam)),
        ],
      ),
    );
  }
}

class ExamComparisonPage extends StatefulWidget {
  const ExamComparisonPage({super.key});

  @override
  State<ExamComparisonPage> createState() => _ExamComparisonPageState();
}

class _ExamComparisonPageState extends State<ExamComparisonPage> {
  int _currentExam = 0;
  int _comparisonExam = 1;

  @override
  Widget build(BuildContext context) {
    final exams = _ExamsPageState._completedExams;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(title: const Text('Compare exams')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8FF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD7CCFF)),
            ),
            child: const Row(children: [
              Icon(Icons.insights_rounded, color: Color(0xFF6541E8), size: 30),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('See how Marcus is progressing',
                        style: TextStyle(
                            color: Color(0xFF342274),
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text(
                        'Select any two completed exams for an instant analysis.',
                        style: TextStyle(
                            color: Color(0xFF6B5A9B),
                            fontSize: 12,
                            height: 1.35)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          _ExamComparisonCard(
            exams: exams,
            currentIndex: _currentExam,
            comparisonIndex: _comparisonExam,
            onCurrentChanged: (value) {
              if (value == null || value == _comparisonExam) return;
              setState(() => _currentExam = value);
            },
            onComparisonChanged: (value) {
              if (value == null || value == _currentExam) return;
              setState(() => _comparisonExam = value);
            },
          ),
        ],
      ),
    );
  }
}

class _ParentExam {
  const _ParentExam({
    required this.name,
    required this.dateLabel,
    required this.detail,
    required this.subjects,
    this.startDate,
    this.scores = const {},
  });

  final String name;
  final String dateLabel;
  final String detail;
  final int subjects;
  final DateTime? startDate;
  final Map<String, int> scores;

  double get average => scores.isEmpty
      ? 0
      : scores.values.reduce((value, score) => value + score) / scores.length;
}

class _ExamCenterHero extends StatelessWidget {
  const _ExamCenterHero({
    required this.nextExam,
    required this.latestExam,
    required this.completedCount,
  });

  final _ParentExam nextExam;
  final _ParentExam latestExam;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final days = nextExam.startDate!.difference(DateTime.now()).inDays + 1;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24164B), Color(0xFF6B32C9), Color(0xFFEB5A45)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E2A96).withValues(alpha: .25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EXAM CENTER',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4)),
              SizedBox(height: 2),
              Text('Marcus\'s progress',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$completedCount results',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: .15)),
          ),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('NEXT EXAM',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
              const SizedBox(height: 5),
              Text(nextExam.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Text(nextExam.dateLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(children: [
                Text('${days < 0 ? 0 : days}',
                    style: const TextStyle(
                        color: Color(0xFF3A214E),
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w900)),
                const Text('DAYS',
                    style: TextStyle(
                        color: Color(0xFF3A214E),
                        fontSize: 9,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.auto_graph_rounded,
              color: Color(0xFFFFD166), size: 18),
          const SizedBox(width: 7),
          Text('Latest overall ${latestExam.average.toStringAsFixed(1)}%',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const Spacer(),
          const Text('A+ grade',
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _ExamSectionTitle extends StatelessWidget {
  const _ExamSectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ]),
        ),
      ]);
}

class _UpcomingExamCard extends StatelessWidget {
  const _UpcomingExamCard({required this.exam, required this.isNext});
  final _ParentExam exam;
  final bool isNext;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  isNext ? const Color(0xFFB6A3FF) : const Color(0xFFE8E7EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 50,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF0ECFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.edit_calendar_rounded,
                  color: Color(0xFF6D4AFF), size: 27),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(exam.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                      if (isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE8FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('NEXT',
                              style: TextStyle(
                                  color: Color(0xFF6541E8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900)),
                        ),
                    ]),
                    const SizedBox(height: 5),
                    Text(exam.dateLabel,
                        style: const TextStyle(
                            color: Color(0xFF6541E8),
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${exam.subjects} subjects  •  ${exam.detail}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ]),
            ),
          ]),
          if (isNext) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 11),
            const Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: Color(0xFF07966C), size: 17),
              SizedBox(width: 7),
              Expanded(
                child: Text('Timetable is ready to view',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              Text('View schedule',
                  style: TextStyle(
                      color: Color(0xFF6541E8),
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ]),
          ],
        ]),
      );
}

class _CompletedExamCard extends StatelessWidget {
  const _CompletedExamCard({required this.exam});
  final _ParentExam exam;

  String get grade => exam.average >= 90
      ? 'A+'
      : exam.average >= 80
          ? 'A'
          : 'B+';

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E7EC)),
        ),
        child: Row(children: [
          Container(
            width: 58,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF07A77A), Color(0xFF087D68)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(exam.average.toStringAsFixed(0),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900)),
              const Text('PERCENT',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 7,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exam.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(exam.dateLabel,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F8F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Grade $grade',
                      style: const TextStyle(
                          color: Color(0xFF087D68),
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Text('${exam.subjects} subjects',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ]),
            ]),
          ),
          const Icon(Icons.picture_as_pdf_rounded,
              color: Color(0xFFD94A48), size: 24),
        ]),
      );
}

class _ExamComparisonCard extends StatelessWidget {
  const _ExamComparisonCard({
    required this.exams,
    required this.currentIndex,
    required this.comparisonIndex,
    required this.onCurrentChanged,
    required this.onComparisonChanged,
  });

  final List<_ParentExam> exams;
  final int currentIndex;
  final int comparisonIndex;
  final ValueChanged<int?> onCurrentChanged;
  final ValueChanged<int?> onComparisonChanged;

  @override
  Widget build(BuildContext context) {
    final current = exams[currentIndex];
    final previous = exams[comparisonIndex];
    final changes = current.scores.entries
        .map((entry) => MapEntry(entry.key,
            entry.value - (previous.scores[entry.key] ?? entry.value)))
        .toList();
    final biggestGain = changes.reduce((a, b) => a.value > b.value ? a : b);
    final declined = changes.where((entry) => entry.value < 0).toList();
    final difference = current.average - previous.average;
    final stronger = difference >= 0 ? current : previous;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171526),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF171526).withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFB59AFF).withValues(alpha: .18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFFC9B9FF), size: 21),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Smart exam comparison',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              Text('Auto-generated from published marks',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: _ExamSelectField(
              label: 'LATEST EXAM',
              value: currentIndex,
              exams: exams,
              blockedIndex: comparisonIndex,
              onChanged: onCurrentChanged,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 20, 8, 0),
            child: Icon(Icons.compare_arrows_rounded, color: Colors.white54),
          ),
          Expanded(
            child: _ExamSelectField(
              label: 'COMPARE WITH',
              value: comparisonIndex,
              exams: exams,
              blockedIndex: currentIndex,
              onChanged: onComparisonChanged,
            ),
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: difference >= 0
                  ? [const Color(0xFF0B745D), const Color(0xFF125046)]
                  : [const Color(0xFF9E453D), const Color(0xFF672F37)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Icon(
                difference >= 0
                    ? Icons.trending_up_rounded
                    : Icons.insights_rounded,
                color: Colors.white,
                size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${stronger.name} scored higher',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(
                      '${current.average.toStringAsFixed(1)}% vs ${previous.average.toStringAsFixed(1)}% overall',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                  '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ExamInsightTile(
              icon: Icons.rocket_launch_rounded,
              iconColor: const Color(0xFF69E6BC),
              label: 'BIGGEST IMPROVEMENT',
              title: biggestGain.value > 0
                  ? '${biggestGain.key}  +${biggestGain.value}'
                  : 'Scores remained steady',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ExamInsightTile(
              icon: Icons.support_rounded,
              iconColor: const Color(0xFFFF8B86),
              label: 'NEEDS SUPPORT',
              title: declined.isEmpty
                  ? 'No subject declined'
                  : '${declined.first.key}  ${declined.first.value}',
            ),
          ),
        ]),
        const SizedBox(height: 19),
        Row(children: [
          const Expanded(
            child: Text('Subject performance',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          Text('${current.name.replaceAll(' Examination', '')}  /  Previous',
              style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ]),
        const SizedBox(height: 10),
        ...changes.map((entry) => _ExamScoreRow(
              subject: entry.key,
              currentScore: current.scores[entry.key]!,
              previousScore: previous.scores[entry.key]!,
              change: entry.value,
            )),
        if (declined.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6F68).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: const Color(0xFFFF7770).withValues(alpha: .2)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_rounded,
                  color: Color(0xFFFFB35C), size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '${declined.first.key} decreased by ${declined.first.value.abs()} marks. A focused weekly revision plan can help recover this gap before ${_ExamsPageState._upcomingExams.first.name}.',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _ExamSelectField extends StatelessWidget {
  const _ExamSelectField({
    required this.label,
    required this.value,
    required this.exams,
    required this.blockedIndex,
    required this.onChanged,
  });
  final String label;
  final int value;
  final List<_ParentExam> exams;
  final int blockedIndex;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF27243A),
                iconEnabledColor: Colors.white54,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
                items: exams.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    enabled: entry.key != blockedIndex,
                    child: Text(entry.value.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );
}

class _ExamInsightTile extends StatelessWidget {
  const _ExamInsightTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.title,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: .07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
        ]),
      );
}

class _ExamScoreRow extends StatelessWidget {
  const _ExamScoreRow({
    required this.subject,
    required this.currentScore,
    required this.previousScore,
    required this.change,
  });
  final String subject;
  final int currentScore;
  final int previousScore;
  final int change;

  @override
  Widget build(BuildContext context) {
    final color =
        change >= 0 ? const Color(0xFF69E6BC) : const Color(0xFFFF8B86);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Text(subject,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          width: 62,
          child: Text('$currentScore  /  $previousScore',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 9),
        Container(
          width: 38,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('${change >= 0 ? '+' : ''}$change',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        ),
      ]),
    );
  }
}

const _unitTestThreeTicket = _HallTicketExam(
  title: 'Unit Test III',
  dates: '18 – 23 Sep 2026',
  venue: 'Senior Wing · Hall B',
  papers: [
    _HallTicketPaper('18 Sep', 'Mathematics', '9:00 – 10:30 AM'),
    _HallTicketPaper('19 Sep', 'English', '9:00 – 10:30 AM'),
    _HallTicketPaper('20 Sep', 'Science', '9:00 – 10:30 AM'),
    _HallTicketPaper('21 Sep', 'Social Studies', '9:00 – 10:30 AM'),
    _HallTicketPaper('22 Sep', 'Hindi', '9:00 – 10:30 AM'),
    _HallTicketPaper('23 Sep', 'Computer Science', '9:00 – 10:30 AM'),
  ],
);

const _termOneTicket = _HallTicketExam(
  title: 'Term I Examination',
  dates: '15 – 25 Jul 2026',
  venue: 'Senior Wing · Hall A',
  papers: [
    _HallTicketPaper('15 Jul', 'Mathematics', '9:00 – 11:00 AM'),
    _HallTicketPaper('17 Jul', 'English', '9:00 – 11:00 AM'),
    _HallTicketPaper('19 Jul', 'Science', '9:00 – 11:00 AM'),
    _HallTicketPaper('21 Jul', 'Social Studies', '9:00 – 11:00 AM'),
    _HallTicketPaper('23 Jul', 'Hindi', '9:00 – 11:00 AM'),
    _HallTicketPaper('25 Jul', 'Computer Science', '9:00 – 11:00 AM'),
  ],
);

const _unitTestTwoTicket = _HallTicketExam(
  title: 'Unit Test II',
  dates: '14 – 20 May 2026',
  venue: 'Senior Wing · Hall C',
  papers: [
    _HallTicketPaper('14 May', 'Mathematics', '9:00 – 10:30 AM'),
    _HallTicketPaper('15 May', 'Science', '9:00 – 10:30 AM'),
    _HallTicketPaper('16 May', 'English', '9:00 – 10:30 AM'),
    _HallTicketPaper('18 May', 'Hindi', '9:00 – 10:30 AM'),
    _HallTicketPaper('19 May', 'Social Studies', '9:00 – 10:30 AM'),
    _HallTicketPaper('20 May', 'Computer Science', '9:00 – 10:30 AM'),
  ],
);

class HallTicketsPage extends StatelessWidget {
  const HallTicketsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(title: const Text('Hall tickets')),
        body: BlocBuilder<ParentBloc, ParentState>(
          builder: (context, state) {
            final ready = state as ParentReady;
            final now = DateTime.now();
            final overdueTuition = ready.data.fees
                .where((fee) =>
                    fee.title.toLowerCase().contains('tuition') &&
                    fee.balance > 0 &&
                    fee.dueDate.isBefore(now))
                .toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            final blocked = overdueTuition.isNotEmpty;
            final overdueAmount =
                overdueTuition.fold<double>(0, (sum, fee) => sum + fee.balance);
            final overdueDays = blocked
                ? now.difference(overdueTuition.first.dueDate).inDays
                : 0;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              children: [
                const _HallTicketHero(),
                if (blocked) ...[
                  const SizedBox(height: 16),
                  _HallTicketFeeWarning(
                    amount: overdueAmount,
                    overdueDays: overdueDays,
                    onPay: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _ParentModulePage(
                          title: 'Fees',
                          child: FeesPage(),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 23),
                Text(blocked ? 'Current hall ticket' : 'Available hall ticket',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 11),
                _HallTicketCard(
                  exam: _unitTestThreeTicket,
                  available: !blocked,
                  status: blocked ? 'BLOCKED' : 'ISSUED',
                  onTap: blocked
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const _HallTicketDetailPage(
                                exam: _unitTestThreeTicket,
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 22),
                const _ExamSchedulePanel(exam: _unitTestThreeTicket),
                const SizedBox(height: 23),
                const Text('Previous hall tickets',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('View entry passes from completed examinations',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                const SizedBox(height: 11),
                _HallTicketCard(
                  exam: _termOneTicket,
                  available: true,
                  status: 'COMPLETED',
                  actionLabel: 'View previous ticket',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _HallTicketDetailPage(
                        exam: _termOneTicket,
                        previous: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                _HallTicketCard(
                  exam: _unitTestTwoTicket,
                  available: true,
                  status: 'COMPLETED',
                  actionLabel: 'View previous ticket',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _HallTicketDetailPage(
                        exam: _unitTestTwoTicket,
                        previous: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Upcoming issuance',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 11),
                const _HallTicketCard(
                  exam: _HallTicketExam(
                    title: 'Quarterly Examination',
                    dates: '12 – 20 Oct 2026',
                    venue: 'Venue will be announced',
                    papers: [],
                  ),
                  available: false,
                  status: 'COMING SOON',
                ),
              ],
            );
          },
        ),
      );
}

class _HallTicketExam {
  const _HallTicketExam({
    required this.title,
    required this.dates,
    required this.venue,
    required this.papers,
  });
  final String title;
  final String dates;
  final String venue;
  final List<_HallTicketPaper> papers;
}

class _HallTicketPaper {
  const _HallTicketPaper(this.date, this.subject, this.time);
  final String date;
  final String subject;
  final String time;
}

class _HallTicketHero extends StatelessWidget {
  const _HallTicketHero();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF123D57), Color(0xFF087D87), Color(0xFF19A790)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF087D87).withValues(alpha: .22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white12,
            child: Icon(Icons.badge_rounded, color: Colors.white, size: 29),
          ),
          SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EXAM ENTRY PASSES',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              SizedBox(height: 4),
              Text('Marcus Thorne',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              Text('Grade 11 · Section B · Roll 042',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
        ]),
      );
}

class _HallTicketFeeWarning extends StatelessWidget {
  const _HallTicketFeeWarning({
    required this.amount,
    required this.overdueDays,
    required this.onPay,
  });
  final double amount;
  final int overdueDays;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFECEB), Color(0xFFFFF6F0)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1A7A1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFFFD7D3),
              child:
                  Icon(Icons.lock_rounded, color: Color(0xFFC73832), size: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text('Hall ticket not generated',
                  style: TextStyle(
                      color: Color(0xFF9D2C28),
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ),
          ]),
          const SizedBox(height: 11),
          Text(
            'Tuition fee payment of ${money.format(amount)} is overdue by $overdueDays days. Clear the overdue tuition fee to generate the current hall ticket.',
            style: const TextStyle(
                color: Color(0xFF85403B), fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC73832)),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: const Text('View tuition fee and pay'),
            ),
          ),
        ]),
      );
}

class _HallTicketCard extends StatelessWidget {
  const _HallTicketCard({
    required this.exam,
    required this.available,
    required this.status,
    this.actionLabel = 'View hall ticket',
    this.onTap,
  });
  final _HallTicketExam exam;
  final bool available;
  final String status;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = available ? const Color(0xFF087D87) : const Color(0xFF94A3B8);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE3E7EB)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.confirmation_number_rounded, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exam.title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(exam.dates,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              Text(exam.venue,
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(status,
                style: TextStyle(
                    color: color, fontSize: 8, fontWeight: FontWeight.w900)),
          ),
        ]),
        if (available) ...[
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.visibility_outlined),
              label: Text(actionLabel),
            ),
          ),
        ],
      ]),
    );
  }
}

class _ExamSchedulePanel extends StatelessWidget {
  const _ExamSchedulePanel({required this.exam});
  final _HallTicketExam exam;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1E5E9)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE7F6F5),
              child: Icon(Icons.calendar_month_rounded,
                  color: Color(0xFF087D87), size: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exam schedule',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    Text('Subject-wise dates and reporting time',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          ...exam.papers.asMap().entries.map((entry) {
            final paper = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: entry.key == exam.papers.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFEEF0F2))),
              ),
              child: Row(children: [
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(paper.date,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF087D87),
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(paper.subject,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800)),
                ),
                Text(paper.time,
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
              ]),
            );
          }),
        ]),
      );
}

class _HallTicketDetailPage extends StatelessWidget {
  const _HallTicketDetailPage({required this.exam, this.previous = false});
  final _HallTicketExam exam;
  final bool previous;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(title: Text('${exam.title} hall ticket')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDDE3E8)),
              ),
              child: Column(children: [
                const Icon(Icons.school_rounded,
                    color: Color(0xFF087D87), size: 34),
                const SizedBox(height: 8),
                const Text('ORISON INTERNATIONAL SCHOOL',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${exam.title.toUpperCase()} · HALL TICKET',
                    style: TextStyle(
                        color: Color(0xFF087D87),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7)),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const _ReceiptDetailRow(
                    label: 'Student', value: 'Marcus Thorne'),
                const _ReceiptDetailRow(
                    label: 'Admission no.', value: 'EP-2024-0812'),
                const _ReceiptDetailRow(
                    label: 'Class', value: 'Grade 11 · Section B'),
                const _ReceiptDetailRow(label: 'Roll number', value: '042'),
                _ReceiptDetailRow(label: 'Exam dates', value: exam.dates),
                _ReceiptDetailRow(label: 'Exam venue', value: exam.venue),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F6F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFF087D87)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          previous
                              ? 'Previous hall ticket · School verified'
                              : 'Valid digital hall ticket · School verified',
                          style: TextStyle(
                              color: Color(0xFF087D87),
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            _ExamSchedulePanel(exam: exam),
          ],
        ),
      );
}

class HelpDeskPage extends StatefulWidget {
  const HelpDeskPage({super.key});

  @override
  State<HelpDeskPage> createState() => _HelpDeskPageState();
}

class _HelpDeskPageState extends State<HelpDeskPage> {
  static const _academicCategories = [
    'Academics & performance',
    'Attendance & leave',
    'Homework concern',
    'Fees & payments',
    'Transport service',
    'School administration',
    'Safety or wellbeing',
    'Other school concern',
  ];
  static const _appCategories = [
    'Login & OTP',
    'Payment & receipts',
    'Transport tracking',
    'Notifications',
    'Documents & downloads',
    'App crash or slowness',
    'Other app issue',
  ];
  static const _callbackTimes = [
    '9:00 AM – 12:00 PM',
    '12:00 PM – 3:00 PM',
    '4:00 PM – 6:00 PM',
  ];

  int _service = 0;
  String _academicCategory = _academicCategories.first;
  String _appCategory = _appCategories.first;
  String _callbackTime = _callbackTimes.last;
  String _priority = 'Normal';
  String? _attachmentName;
  final _details = TextEditingController();
  late final TextEditingController _parentName;
  late final TextEditingController _studentName;
  late final TextEditingController _mobile;

  @override
  void initState() {
    super.initState();
    final ready = context.read<ParentBloc>().state as ParentReady;
    _parentName = TextEditingController(text: ready.data.profile.name);
    _studentName = TextEditingController(text: ready.student.name);
    _mobile = TextEditingController(text: ready.data.profile.mobile);
  }

  @override
  void dispose() {
    _details.dispose();
    _parentName.dispose();
    _studentName.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _attachmentName = result.files.single.name);
    }
  }

  void _submit() {
    final details = _details.text.trim();
    if (details.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please explain your concern in at least 10 characters.')),
      );
      return;
    }
    final callback = _service == 0;
    if (!callback &&
        (_parentName.text.trim().isEmpty ||
            _studentName.text.trim().isEmpty ||
            _mobile.text.trim().length != 10)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Enter the parent name, student name and valid 10-digit mobile number.')),
      );
      return;
    }
    context.read<ParentBloc>().add(HelpRequestSubmitted(
          kind: callback ? 'School callback' : 'App support',
          category: callback ? _academicCategory : _appCategory,
          description: details,
          priority: callback ? 'Normal' : _priority,
          preferredTime: _callbackTime,
          attachmentName: callback ? null : _attachmentName,
          parentName: callback ? null : _parentName.text.trim(),
          studentName: callback ? null : _studentName.text.trim(),
          mobile: callback ? null : _mobile.text.trim(),
        ));
    setState(() {
      _details.clear();
      _attachmentName = null;
      _priority = 'Normal';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(title: const Text('Parent help desk')),
        body: BlocBuilder<ParentBloc, ParentState>(builder: (context, state) {
          final ready = state as ParentReady;
          final requests = ready.data.helpRequests;
          final active = requests
              .where((item) =>
                  item.status == 'Open' || item.status == 'Pending callback')
              .length;
          final scheduled =
              requests.where((item) => item.status == 'Scheduled').length;
          final resolved =
              requests.where((item) => item.status == 'Resolved').length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const _HelpDeskHero(),
              const SizedBox(height: 18),
              const Text('How can we help?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Select the service you need',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              const SizedBox(height: 11),
              Row(children: [
                Expanded(
                  child: _HelpServiceCard(
                    selected: _service == 0,
                    icon: Icons.phone_callback_rounded,
                    title: 'School callback',
                    subtitle: 'Talk with the right school department',
                    color: const Color(0xFF3157C8),
                    onTap: () => setState(() => _service = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HelpServiceCard(
                    selected: _service == 1,
                    icon: Icons.app_settings_alt_rounded,
                    title: 'App support',
                    subtitle: 'Raise a ticket with the Orison team',
                    color: const Color(0xFF8A43C6),
                    onTap: () => setState(() => _service = 1),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _service == 0
                    ? _AcademicCallbackForm(
                        key: const ValueKey('callback'),
                        category: _academicCategory,
                        categories: _academicCategories,
                        callbackTime: _callbackTime,
                        callbackTimes: _callbackTimes,
                        details: _details,
                        onCategoryChanged: (value) =>
                            setState(() => _academicCategory = value),
                        onTimeChanged: (value) =>
                            setState(() => _callbackTime = value),
                        onSubmit: _submit,
                      )
                    : _AppSupportForm(
                        key: const ValueKey('app-support'),
                        category: _appCategory,
                        categories: _appCategories,
                        priority: _priority,
                        details: _details,
                        attachmentName: _attachmentName,
                        parentName: _parentName,
                        studentName: _studentName,
                        mobile: _mobile,
                        callbackTime: _callbackTime,
                        callbackTimes: _callbackTimes,
                        onCategoryChanged: (value) =>
                            setState(() => _appCategory = value),
                        onPriorityChanged: (value) =>
                            setState(() => _priority = value),
                        onTimeChanged: (value) =>
                            setState(() => _callbackTime = value),
                        onAttach: _pickAttachment,
                        onRemoveAttachment: () =>
                            setState(() => _attachmentName = null),
                        onSubmit: _submit,
                      ),
              ),
              const SizedBox(height: 24),
              const Text('Support overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 11),
              Row(children: [
                Expanded(
                  child: _HelpSummaryCard(
                    value: '$active',
                    label: 'Active',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFD57912),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _HelpSummaryCard(
                    value: '$scheduled',
                    label: 'Scheduled',
                    icon: Icons.event_available_rounded,
                    color: const Color(0xFF3157C8),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _HelpSummaryCard(
                    value: '$resolved',
                    label: 'Resolved',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFF07966C),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                const Expanded(
                  child: Text('Your requests',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                Text('${requests.length} total',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 10)),
              ]),
              const SizedBox(height: 11),
              ...requests.map((request) => _HelpRequestCard(request: request)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F7),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Row(children: [
                  Icon(Icons.access_time_rounded,
                      color: Color(0xFF32677A), size: 19),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Help desk hours: Monday–Saturday, 8:30 AM–6:00 PM. Urgent app issues are monitored continuously.',
                      style: TextStyle(
                          color: Color(0xFF466573), fontSize: 10, height: 1.4),
                    ),
                  ),
                ]),
              ),
            ],
          );
        }),
      );
}

class _HelpDeskHero extends StatelessWidget {
  const _HelpDeskHero();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E2440), Color(0xFF3E4389), Color(0xFF7850B5)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF45468B).withValues(alpha: .23),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: const Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white12,
            child: Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 30),
          ),
          SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ORISON PARENT SUPPORT',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              SizedBox(height: 4),
              Text('We’re here to help',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              Text('Academic guidance and technical assistance',
                  style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          Icon(Icons.verified_user_rounded, color: Color(0xFFD2C2FF), size: 23),
        ]),
      );
}

class _HelpServiceCard extends StatelessWidget {
  const _HelpServiceCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .08) : Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? color : const Color(0xFFE1E3E8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? color : const Color(0xFFB4BBC4),
                size: 18,
              ),
            ]),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle,
                maxLines: 2,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 9, height: 1.35)),
          ]),
        ),
      );
}

class _AcademicCallbackForm extends StatelessWidget {
  const _AcademicCallbackForm({
    super.key,
    required this.category,
    required this.categories,
    required this.callbackTime,
    required this.callbackTimes,
    required this.details,
    required this.onCategoryChanged,
    required this.onTimeChanged,
    required this.onSubmit,
  });
  final String category;
  final List<String> categories;
  final String callbackTime;
  final List<String> callbackTimes;
  final TextEditingController details;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTimeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => _HelpFormShell(
        color: const Color(0xFF3157C8),
        icon: Icons.phone_callback_rounded,
        title: 'Request a school callback',
        subtitle:
            'The relevant school team will call the registered parent number.',
        children: [
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: 'Reason for callback',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
            items: categories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 14),
          const Text('Preferred callback time',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...callbackTimes.map((time) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: InkWell(
                  onTap: () => onTimeChanged(time),
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: callbackTime == time
                          ? const Color(0xFFEAF0FF)
                          : const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: callbackTime == time
                            ? const Color(0xFF9EB2F0)
                            : const Color(0xFFE1E3E8),
                      ),
                    ),
                    child: Row(children: [
                      Icon(Icons.schedule_rounded,
                          color: callbackTime == time
                              ? const Color(0xFF3157C8)
                              : const Color(0xFF94A3B8),
                          size: 17),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(time,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      Icon(
                        callbackTime == time
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: callbackTime == time
                            ? const Color(0xFF3157C8)
                            : const Color(0xFFB4BBC4),
                        size: 17,
                      ),
                    ]),
                  ),
                ),
              )),
          const SizedBox(height: 7),
          TextField(
            controller: details,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Your doubts or concerns',
              hintText: 'Explain what you would like to discuss',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 10),
          const Row(children: [
            Icon(Icons.phone_iphone_rounded,
                color: Color(0xFF64748B), size: 15),
            SizedBox(width: 5),
            Text('Callback number: +91 98765 43210',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 9)),
          ]),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3157C8)),
              icon: const Icon(Icons.phone_callback_rounded, size: 18),
              label: const Text('Request callback'),
            ),
          ),
        ],
      );
}

class _AppSupportForm extends StatelessWidget {
  const _AppSupportForm({
    super.key,
    required this.category,
    required this.categories,
    required this.priority,
    required this.details,
    required this.attachmentName,
    required this.parentName,
    required this.studentName,
    required this.mobile,
    required this.callbackTime,
    required this.callbackTimes,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onTimeChanged,
    required this.onAttach,
    required this.onRemoveAttachment,
    required this.onSubmit,
  });
  final String category;
  final List<String> categories;
  final String priority;
  final TextEditingController details;
  final String? attachmentName;
  final TextEditingController parentName;
  final TextEditingController studentName;
  final TextEditingController mobile;
  final String callbackTime;
  final List<String> callbackTimes;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onTimeChanged;
  final VoidCallback onAttach;
  final VoidCallback onRemoveAttachment;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => _HelpFormShell(
        color: const Color(0xFF8A43C6),
        icon: Icons.bug_report_rounded,
        title: 'Raise an Orison app ticket',
        subtitle: 'Tell our technical team where you are facing a problem.',
        children: [
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: 'Where is the issue?',
              prefixIcon: Icon(Icons.app_settings_alt_rounded),
            ),
            items: categories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value != null) onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 14),
          const Text('Parent and student details',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: parentName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Parent name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: studentName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Student name',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              prefixText: '+91  ',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: callbackTime,
            decoration: const InputDecoration(
              labelText: 'Preferred time (if a call is required)',
              prefixIcon: Icon(Icons.schedule_rounded),
            ),
            items: callbackTimes
                .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                .toList(),
            onChanged: (value) {
              if (value != null) onTimeChanged(value);
            },
          ),
          const SizedBox(height: 14),
          const Text('Issue urgency',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            for (final item in ['Low', 'Normal', 'Urgent']) ...[
              Expanded(
                child: _PriorityChoice(
                  label: item,
                  selected: priority == item,
                  onTap: () => onPriorityChanged(item),
                ),
              ),
              if (item != 'Urgent') const SizedBox(width: 7),
            ],
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: details,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Describe the app problem',
              hintText: 'What happened, and what were you trying to do?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 11),
          _LeaveAttachmentField(
            fileName: attachmentName,
            onAttach: onAttach,
            onRemove: onRemoveAttachment,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8A43C6)),
              icon: const Icon(Icons.confirmation_number_rounded, size: 18),
              label: const Text('Raise support ticket'),
            ),
          ),
        ],
      );
}

class _HelpFormShell extends StatelessWidget {
  const _HelpFormShell({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: color.withValues(alpha: .2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 9)),
                  ]),
            ),
          ]),
          const SizedBox(height: 17),
          ...children,
        ]),
      );
}

class _PriorityChoice extends StatelessWidget {
  const _PriorityChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = label == 'Urgent'
        ? const Color(0xFFD14A45)
        : label == 'Low'
            ? const Color(0xFF07966C)
            : const Color(0xFF8A43C6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color:
              selected ? color.withValues(alpha: .1) : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : const Color(0xFFE1E3E8)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: selected ? color : const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _HelpSummaryCard extends StatelessWidget {
  const _HelpSummaryCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _HelpRequestCard extends StatelessWidget {
  const _HelpRequestCard({required this.request});
  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final callback = request.kind == 'School callback';
    final color = request.status == 'Resolved'
        ? const Color(0xFF07966C)
        : request.status == 'Scheduled'
            ? const Color(0xFF3157C8)
            : const Color(0xFFD57912);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E4E8)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color:
                  (callback ? const Color(0xFF3157C8) : const Color(0xFF8A43C6))
                      .withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              callback
                  ? Icons.phone_callback_rounded
                  : Icons.bug_report_rounded,
              color:
                  callback ? const Color(0xFF3157C8) : const Color(0xFF8A43C6),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request.category,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900)),
              Text('${request.kind} · ${request.id}',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(request.status.toUpperCase(),
                style: TextStyle(
                    color: color, fontSize: 7, fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 11),
        Text(request.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Color(0xFF526173), fontSize: 10, height: 1.4)),
        if (!callback && request.parentName != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF8A43C6).withValues(alpha: .055),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.parentName}  ·  ${request.studentName ?? 'Student'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3B2A47),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (request.mobile != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.phone_iphone_rounded,
                        size: 12, color: Color(0xFF8A43C6)),
                    const SizedBox(width: 4),
                    Text('+91 ${request.mobile}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 9)),
                  ]),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.schedule_rounded,
              color: Color(0xFF94A3B8), size: 14),
          const SizedBox(width: 4),
          Text(_noticeTimeLabel(request.createdAt),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
          if (request.preferredTime != null) ...[
            const SizedBox(width: 12),
            const Icon(Icons.phone_in_talk_outlined,
                color: Color(0xFF3157C8), size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(request.preferredTime!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF3157C8),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ] else
            const Spacer(),
          if (request.attachmentName != null)
            const Icon(Icons.attachment_rounded,
                color: Color(0xFF8A43C6), size: 15),
        ]),
      ]),
    );
  }
}
