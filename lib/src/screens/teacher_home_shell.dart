import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/teacher_models.dart';
import '../school_brand.dart';
import '../state/auth_bloc.dart';
import '../state/teacher_bloc.dart';
import 'teacher_workflow_pages.dart';

const _navy = Color(0xFF10203F);
const _blue = SchoolBrand.teacherAccent;
const _muted = Color(0xFF68758A);

class TeacherHomeShell extends StatefulWidget {
  const TeacherHomeShell({super.key});

  @override
  State<TeacherHomeShell> createState() => _TeacherHomeShellState();
}

class _TeacherHomeShellState extends State<TeacherHomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) => BlocConsumer<TeacherBloc, TeacherState>(
        listenWhen: (previous, current) =>
            current is TeacherReady && current.message != null,
        listener: (context, state) {
          if (state is TeacherReady && state.message != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state is TeacherInitial || state is TeacherLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is TeacherFailure) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 44, color: _muted),
                    const SizedBox(height: 12),
                    Text(state.message),
                    TextButton(
                      onPressed: () => context
                          .read<TeacherBloc>()
                          .add(const TeacherLoaded('TCH-001')),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final ready = state as TeacherReady;
          final pages = [
            TeacherDashboardPage(data: ready.data),
            TeacherClassesPage(data: ready.data),
            TeacherTasksPage(data: ready.data),
            TeacherMorePage(data: ready.data),
          ];
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              title: const Row(
                children: [
                  SchoolLogo(size: 36),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SchoolBrand.shortName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Teacher workspace',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Staff notices',
                  onPressed: () => _open(
                    context,
                    TeacherNoticesPage(notices: ready.data.notices),
                  ),
                  icon: Badge(
                    label: Text(
                      '${ready.data.notices.where((item) => item.unread).length}',
                    ),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => _open(
                    context,
                    TeacherSettingsPage(profile: ready.data.profile),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.co_present_outlined),
                  selectedIcon: Icon(Icons.co_present_rounded),
                  label: 'Classes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt_outlined),
                  selectedIcon: Icon(Icons.task_alt_rounded),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'More',
                ),
              ],
            ),
          );
        },
      );
}

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({required this.data, super.key});

  final TeacherSnapshot data;

  @override
  Widget build(BuildContext context) {
    final next = data.periods.firstWhere((item) => item.status == 'Next class');
    final pendingTasks = data.tasks.where((item) => !item.completed).length;
    final attendanceClass =
        data.classes.firstWhere((item) => item.canTakeAttendance);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _TeacherHero(profile: data.profile, next: next),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.schedule_rounded,
                color: _blue,
                value: '${data.periods.length}',
                label: 'Periods today',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF00A878),
                value: attendanceClass.attendanceMarked ? 'Done' : 'Pending',
                label: 'First-period class',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.pending_actions_rounded,
                color: const Color(0xFFE89718),
                value: '$pendingTasks',
                label: 'Open tasks',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Quick actions',
          subtitle: 'Your most-used teaching tools',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: .78,
          mainAxisSpacing: 14,
          crossAxisSpacing: 8,
          children: [
            _QuickAction(
              icon: Icons.how_to_reg_rounded,
              label: 'Attendance',
              color: const Color(0xFF00A878),
              onTap: () => _open(context, TeacherAttendancePage(data: data)),
            ),
            _QuickAction(
              icon: Icons.assignment_add,
              label: 'Homework',
              color: const Color(0xFF7A4CE0),
              onTap: () =>
                  _open(context, TeacherHomeworkWorkspacePage(data: data)),
            ),
            _QuickAction(
              icon: Icons.calendar_month_rounded,
              label: 'Timetable',
              color: const Color(0xFFDF3E80),
              onTap: () =>
                  _open(context, DynamicTeacherTimetablePage(data: data)),
            ),
            _QuickAction(
              icon: Icons.insights_rounded,
              label: 'Insights',
              color: _blue,
              onTap: () =>
                  _open(context, AdvancedStudentInsightsPage(data: data)),
            ),
            _QuickAction(
              icon: Icons.menu_book_rounded,
              label: 'Lesson plans',
              color: const Color(0xFF008B95),
              onTap: () => _open(context, const TeacherLessonPlansPage()),
            ),
            _QuickAction(
              icon: Icons.beach_access_rounded,
              label: 'Apply leave',
              color: const Color(0xFF607D3B),
              onTap: () => _open(context, const TeacherLeavePage()),
            ),
            _QuickAction(
              icon: Icons.campaign_rounded,
              label: 'Staff notices',
              color: SchoolBrand.primary,
              onTap: () =>
                  _open(context, TeacherNoticesPage(notices: data.notices)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Today’s teaching plan',
          subtitle: 'Tuesday · 18 August',
        ),
        const SizedBox(height: 12),
        ...data.periods.map((period) => _PeriodCard(period: period)),
        const SizedBox(height: 20),
        _PriorityPanel(tasks: data.tasks),
        const SizedBox(height: 20),
        _NoticePreview(notice: data.notices.first, all: data.notices),
      ],
    );
  }
}

class _TeacherHero extends StatelessWidget {
  const _TeacherHero({required this.profile, required this.next});
  final TeacherProfile profile;
  final TeacherPeriod next;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_navy, Color(0xFF18346B), Color(0xFF2459AF)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3010203F),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GOOD MORNING',
                        style: TextStyle(
                          color: Color(0xFFB9C9E7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.designation}  •  ${profile.classTeacherOf}',
                        style: const TextStyle(
                          color: Color(0xFFD6E0F2),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: .14)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7D3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.science_rounded, color: _navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEXT CLASS  •  STARTS IN 18 MIN',
                          style: TextStyle(
                            color: Color(0xFFBFD0ED),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${next.classLabel} · ${next.subject}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${next.startTime} – ${next.endTime}  •  ${next.room}',
                          style: const TextStyle(
                            color: Color(0xFFD2DCEF),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 13, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7EAF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 9.5, color: _muted)),
          ],
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: color.withValues(alpha: .18)),
              ),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: _muted)),
              ],
            ),
          ),
        ],
      );
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.period});
  final TeacherPeriod period;

  @override
  Widget build(BuildContext context) {
    final active = period.status == 'Next class';
    final done = period.status == 'Completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEEF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? const Color(0xFFBCD0F5) : const Color(0xFFE7EAF0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('P${period.period}',
                    style: TextStyle(
                        color: active ? _blue : _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w900)),
                Text(
                    period.startTime
                        .replaceAll(' AM', '')
                        .replaceAll(' PM', ''),
                    style: const TextStyle(
                        fontSize: 10,
                        color: _muted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
              width: 3,
              height: 38,
              color: active ? _blue : const Color(0xFFDCE1E9)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${period.classLabel} · ${period.subject}',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${period.room}  •  ${period.endTime}',
                    style: const TextStyle(fontSize: 10.5, color: _muted)),
              ],
            ),
          ),
          Icon(
            done
                ? Icons.check_circle_rounded
                : active
                    ? Icons.play_circle_fill_rounded
                    : Icons.schedule_rounded,
            color: done
                ? const Color(0xFF00A878)
                : active
                    ? _blue
                    : const Color(0xFF9AA4B4),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _PriorityPanel extends StatelessWidget {
  const _PriorityPanel({required this.tasks});
  final List<TeacherTask> tasks;

  @override
  Widget build(BuildContext context) {
    final open = tasks.where((item) => !item.completed).take(3).toList();
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFFFD66B), size: 20),
              SizedBox(width: 8),
              Text('Priority actions',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          ...open.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.priority == 'Urgent'
                            ? const Color(0xFFFF6B72)
                            : const Color(0xFFFFD66B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(task.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(task.dueLabel,
                        style: const TextStyle(
                            color: Color(0xFFBCC8DE), fontSize: 9.5)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _NoticePreview extends StatelessWidget {
  const _NoticePreview({required this.notice, required this.all});
  final TeacherNotice notice;
  final List<TeacherNotice> all;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _open(context, TeacherNoticesPage(notices: all)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFDFD1)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFE1D4),
                child: Icon(Icons.campaign_rounded, color: SchoolBrand.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(notice.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, color: _muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      );
}

class TeacherClassesPage extends StatelessWidget {
  const TeacherClassesPage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          const _PageIntro(
            eyebrow: 'MY TEACHING GROUPS',
            title: 'Classes & students',
            subtitle: 'Attendance, academics and communication in one place.',
            icon: Icons.co_present_rounded,
          ),
          const SizedBox(height: 18),
          ...data.classes.map((item) => _ClassCard(item: item, data: data)),
        ],
      );
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.item, required this.data});
  final TeacherClass item;
  final TeacherSnapshot data;

  @override
  Widget build(BuildContext context) {
    final attendanceLabel = item.canTakeAttendance
        ? item.attendanceMarked
            ? 'Marked'
            : 'Your duty'
        : 'Not assigned';
    final attendanceColor = item.canTakeAttendance
        ? item.attendanceMarked
            ? const Color(0xFF00A878)
            : const Color(0xFFE89718)
        : _muted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF3FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.science_rounded, color: _blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                    Text('${item.subjects.join(' · ')}  •  ${item.room}',
                        style: const TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
              ),
              _StatusPill(
                text: attendanceLabel,
                color: attendanceColor,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _ClassMetric(
                      value: '${item.studentCount}', label: 'Students')),
              Expanded(
                  child: _ClassMetric(
                      value: '${item.average.toStringAsFixed(1)}%',
                      label: 'Class average')),
              Expanded(
                  child: _ClassMetric(
                      value: item.canTakeAttendance
                          ? item.attendanceMarked
                              ? 'Done'
                              : 'Open'
                          : 'View only',
                      label: 'Attendance')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: item.canTakeAttendance
                      ? () => _open(
                          context,
                          TeacherAttendancePage(
                              data: data, initialClassId: item.id))
                      : null,
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Attendance'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      _open(context, AdvancedStudentInsightsPage(data: data)),
                  icon: const Icon(Icons.groups_rounded, size: 18),
                  label: const Text('Students'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassMetric extends StatelessWidget {
  const _ClassMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9.5, color: _muted)),
        ],
      );
}

class TeacherTasksPage extends StatelessWidget {
  const TeacherTasksPage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  Widget build(BuildContext context) {
    final completed = data.tasks.where((item) => item.completed).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _PageIntro(
          eyebrow: 'WORK QUEUE',
          title: 'Today’s priorities',
          subtitle:
              '${data.tasks.length - completed} open · $completed completed',
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 18),
        ...data.tasks.map((task) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E9F0)),
              ),
              child: CheckboxListTile(
                value: task.completed,
                onChanged: (_) => context
                    .read<TeacherBloc>()
                    .add(TeacherTaskToggled(task.id)),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(task.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                    )),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text('${task.category}  •  ${task.dueLabel}',
                      style: const TextStyle(fontSize: 10.5, color: _muted)),
                ),
                secondary: _StatusPill(
                  text: task.priority,
                  color: task.priority == 'Urgent'
                      ? SchoolBrand.primary
                      : const Color(0xFFE89718),
                ),
              ),
            )),
      ],
    );
  }
}

class TeacherMorePage extends StatelessWidget {
  const TeacherMorePage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  Widget build(BuildContext context) {
    final items = [
      _TeacherService(
          Icons.assignment_add,
          'Homework',
          'Class, subject and attachments',
          const Color(0xFF7A4CE0),
          TeacherHomeworkWorkspacePage(data: data)),
      _TeacherService(
          Icons.insights_rounded,
          'Student insights',
          'Progress and support signals',
          _blue,
          AdvancedStudentInsightsPage(data: data)),
      _TeacherService(
          Icons.calendar_month_rounded,
          'My timetable',
          'Periods, rooms and timings',
          const Color(0xFFDF3E80),
          DynamicTeacherTimetablePage(data: data)),
      _TeacherService(
          Icons.campaign_rounded,
          'Staff notices',
          'Circulars and announcements',
          SchoolBrand.primary,
          TeacherNoticesPage(notices: data.notices)),
      const _TeacherService(
          Icons.menu_book_rounded,
          'Lesson plans',
          'Today, timeline and completion',
          Color(0xFF008B95),
          TeacherLessonPlansPage()),
      const _TeacherService(Icons.beach_access_rounded, 'Staff leave',
          'Apply and track approvals', Color(0xFF607D3B), TeacherLeavePage()),
      const _TeacherService(
          Icons.chat_bubble_outline_rounded,
          'Parent communication',
          'Secure student conversations',
          Color(0xFF7A4CE0),
          _TeacherInfoPage(
              title: 'Parent communication',
              icon: Icons.chat_bubble_outline_rounded,
              headline: 'School-approved communication',
              description:
                  'Send class updates and respond to parent requests with a complete audit trail.')),
      const _TeacherService(
          Icons.support_agent_rounded,
          'Help desk',
          'School and app support',
          Color(0xFF526177),
          _TeacherInfoPage(
              title: 'Help desk',
              icon: Icons.support_agent_rounded,
              headline: 'How can we help?',
              description:
                  'Raise a school request or report an app issue to the Orison support team.')),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        const _PageIntro(
          eyebrow: 'TEACHER SERVICES',
          title: 'Everything you need',
          subtitle: 'Academic, administrative and support tools.',
          icon: Icons.grid_view_rounded,
        ),
        const SizedBox(height: 18),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.05,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
          ),
          itemBuilder: (context, index) => _ServiceTile(item: items[index]),
        ),
        const SizedBox(height: 16),
        ListTile(
          tileColor: _navy,
          textColor: Colors.white,
          iconColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: const Icon(Icons.settings_rounded),
          title: const Text('App & account settings',
              style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('Profile, security and notifications',
              style: TextStyle(color: Color(0xFFBCC8DE), fontSize: 11)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              _open(context, TeacherSettingsPage(profile: data.profile)),
        ),
      ],
    );
  }
}

class _TeacherService {
  const _TeacherService(
      this.icon, this.title, this.subtitle, this.color, this.page);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.item});
  final _TeacherService item;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _open(context, item.page),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(item.icon, color: item.color),
              ),
              const Spacer(),
              Text(item.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(item.subtitle,
                  style: const TextStyle(fontSize: 9.5, color: _muted)),
            ],
          ),
        ),
      );
}

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage(
      {required this.data, this.initialClassId, super.key});
  final TeacherSnapshot data;
  final String? initialClassId;

  @override
  State<TeacherAttendancePage> createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  late String classId;
  late Map<String, String> statuses;
  final search = TextEditingController();
  DateTime selectedDate = DateUtils.dateOnly(DateTime.now());
  String query = '';

  @override
  void initState() {
    super.initState();
    final assignedClass =
        widget.data.classes.firstWhere((item) => item.canTakeAttendance);
    classId = assignedClass.id;
    statuses = {
      for (final student in widget.data.students) student.id: 'Present'
    };
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _markAll(String status) => setState(() {
        for (final student in widget.data.students) {
          statuses[student.id] = status;
        }
      });

  Future<void> _selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final value = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: today.subtract(const Duration(days: 90)),
      lastDate: today,
      helpText: 'Select attendance date',
    );
    if (value != null) setState(() => selectedDate = value);
  }

  String get _dateLabel {
    final today = DateUtils.dateOnly(DateTime.now());
    if (DateUtils.isSameDay(selectedDate, today)) return 'Today';
    return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final present = statuses.values.where((value) => value == 'Present').length;
    final absent = statuses.values.where((value) => value == 'Absent').length;
    final assignedClass =
        widget.data.classes.firstWhere((item) => item.id == classId);
    final filteredStudents = widget.data.students.where((student) {
      final normalized = query.trim().toLowerCase();
      return normalized.isEmpty ||
          student.name.toLowerCase().contains(normalized) ||
          student.roll.toLowerCase().contains(normalized);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Mark attendance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _PageIntro(
              eyebrow: 'LIVE CLASS REGISTER',
              title: assignedClass.label,
              subtitle:
                  '${assignedClass.subject} · First-period attendance responsibility',
              icon: Icons.how_to_reg_rounded),
          const SizedBox(height: 15),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFE1E5EC)),
              ),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: _blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attendance date',
                          style: TextStyle(fontSize: 10, color: _muted)),
                      const SizedBox(height: 2),
                      Text(
                        '$_dateLabel · ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_calendar_rounded, color: _blue),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _AttendanceSummary(
                      label: 'Present',
                      value: present,
                      color: const Color(0xFF00A878))),
              const SizedBox(width: 8),
              Expanded(
                  child: _AttendanceSummary(
                      label: 'Absent',
                      value: absent,
                      color: SchoolBrand.primary)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Bulk update',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _markAll('Present'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00A878),
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.done_all_rounded, size: 19),
                label: const Text('All present'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _markAll('Absent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SchoolBrand.primary,
                  side: const BorderSide(color: SchoolBrand.primary),
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.person_off_rounded, size: 19),
                label: const Text('All absent'),
              ),
            ),
          ]),
          const SizedBox(height: 17),
          TextField(
            controller: search,
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              labelText: 'Search student name or roll number',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        search.clear();
                        setState(() => query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(
              child: Text('Student register',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            ),
            Text('${filteredStudents.length} students',
                style: const TextStyle(fontSize: 10.5, color: _muted)),
          ]),
          const SizedBox(height: 9),
          if (filteredStudents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: Text('No students match your search.')),
            ),
          ...filteredStudents.map((student) => _AttendanceStudent(
                student: student,
                value: statuses[student.id]!,
                onChanged: (value) =>
                    setState(() => statuses[student.id] = value),
              )),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            context.read<TeacherBloc>().add(
                TeacherAttendanceSubmitted(classId, selectedDate, statuses));
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          icon: const Icon(Icons.cloud_done_rounded),
          label: Text('Save ${_dateLabel.toLowerCase()} attendance'),
        ),
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 9.5, color: _muted)),
        ]),
      );
}

class _AttendanceStudent extends StatelessWidget {
  const _AttendanceStudent(
      {required this.student, required this.value, required this.onChanged});
  final TeacherStudent student;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE5E9F0))),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: const Color(0xFFEDF3FF),
              child: Text(student.name.substring(0, 1),
                  style: const TextStyle(
                      color: _blue, fontWeight: FontWeight.w900))),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(student.name,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800)),
                Text('Roll ${student.roll}',
                    style: const TextStyle(fontSize: 10, color: _muted)),
              ])),
          SegmentedButton<String>(
            showSelectedIcon: false,
            style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
            segments: const [
              ButtonSegment(
                  value: 'Present',
                  icon: Icon(Icons.check_rounded, size: 15),
                  label: Text('Present')),
              ButtonSegment(
                  value: 'Absent',
                  icon: Icon(Icons.close_rounded, size: 15),
                  label: Text('Absent')),
            ],
            selected: {value},
            onSelectionChanged: (selected) => onChanged(selected.first),
          ),
        ]),
      );
}

class AssignHomeworkPage extends StatefulWidget {
  const AssignHomeworkPage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  State<AssignHomeworkPage> createState() => _AssignHomeworkPageState();
}

class _AssignHomeworkPageState extends State<AssignHomeworkPage> {
  late String classId = widget.data.classes.first.id;
  final title = TextEditingController();
  final instructions = TextEditingController();
  DateTime dueDate = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    title.dispose();
    instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assign homework')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageIntro(
                eyebrow: 'CREATE & PUBLISH',
                title: 'New homework',
                subtitle: 'Parents and students receive the update instantly.',
                icon: Icons.assignment_add),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: classId,
              decoration: const InputDecoration(
                  labelText: 'Class & subject',
                  prefixIcon: Icon(Icons.class_outlined)),
              items: widget.data.classes
                  .map((item) => DropdownMenuItem(
                      value: item.id,
                      child: Text('${item.label} · ${item.subject}')))
                  .toList(),
              onChanged: (value) => setState(() => classId = value ?? classId),
            ),
            const SizedBox(height: 13),
            TextField(
                controller: title,
                decoration: const InputDecoration(
                    labelText: 'Homework title',
                    prefixIcon: Icon(Icons.title_rounded))),
            const SizedBox(height: 13),
            TextField(
                controller: instructions,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                    labelText: 'Instructions & learning outcome',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded))),
            const SizedBox(height: 13),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFFE1E1E5))),
              leading: const Icon(Icons.event_rounded, color: _blue),
              title: const Text('Submission due',
                  style: TextStyle(fontSize: 11, color: _muted)),
              subtitle: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: const Icon(Icons.edit_calendar_rounded),
              onTap: () async {
                final value = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    initialDate: dueDate);
                if (value != null) setState(() => dueDate = value);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (title.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please enter a homework title.')));
                  return;
                }
                context.read<TeacherBloc>().add(TeacherHomeworkAssigned(
                    classId: classId,
                    subject: widget.data.classes
                        .firstWhere((item) => item.id == classId)
                        .subject,
                    title: title.text,
                    instructions: instructions.text,
                    dueDate: dueDate,
                    attachmentNames: const []));
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Publish to class'),
            ),
          ],
        ),
      );
}

class TeacherMarksPage extends StatefulWidget {
  const TeacherMarksPage({required this.data, super.key});
  final TeacherSnapshot data;
  @override
  State<TeacherMarksPage> createState() => _TeacherMarksPageState();
}

class _TeacherMarksPageState extends State<TeacherMarksPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Exam & marks')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageIntro(
                eyebrow: 'ASSESSMENT WORKSPACE',
                title: 'Unit Test III',
                subtitle: 'Grade 11 · Section B · Physics · Maximum 100',
                icon: Icons.score_rounded),
            const SizedBox(height: 16),
            ...widget.data.students.map((student) => Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xFFE5E9F0))),
                  child: Row(children: [
                    CircleAvatar(
                        backgroundColor: const Color(0xFFFFF0E8),
                        child: Text(student.roll,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE66A2C),
                                fontWeight: FontWeight.w900))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(student.name,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w800))),
                    SizedBox(
                        width: 72,
                        child: TextFormField(
                            initialValue:
                                student.performance.round().toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                isDense: true, suffixText: '/100'))),
                  ]),
                )),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Marks saved as a secure draft.'))),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save marks draft'),
            ),
          ],
        ),
      );
}

class TeacherTimetablePage extends StatelessWidget {
  const TeacherTimetablePage({required this.data, super.key});
  final TeacherSnapshot data;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My timetable')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageIntro(
                eyebrow: 'WEEKLY SCHEDULE',
                title: 'Tuesday · 18 August',
                subtitle: '4 teaching periods · 2 free periods',
                icon: Icons.calendar_month_rounded),
            const SizedBox(height: 16),
            ...data.periods.map((period) => _PeriodCard(period: period)),
          ],
        ),
      );
}

class StudentInsightsPage extends StatelessWidget {
  const StudentInsightsPage({required this.students, super.key});
  final List<TeacherStudent> students;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Student insights')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageIntro(
                eyebrow: 'SMART CLASS SIGNALS',
                title: 'Progress & support',
                subtitle: 'Grade 11 · Section B · AI-assisted overview',
                icon: Icons.insights_rounded),
            const SizedBox(height: 16),
            ...students.map((student) {
              final needsSupport = student.status == 'Needs support';
              final color = needsSupport
                  ? SchoolBrand.primary
                  : student.status == 'Strong'
                      ? const Color(0xFF00A878)
                      : _blue;
              return Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: const Color(0xFFE5E9F0))),
                child: Column(children: [
                  Row(children: [
                    CircleAvatar(
                        backgroundColor: color.withValues(alpha: .1),
                        child: Text(student.name.substring(0, 1),
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(student.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900)),
                          Text('Roll ${student.roll}',
                              style:
                                  const TextStyle(fontSize: 10, color: _muted)),
                        ])),
                    _StatusPill(text: student.status, color: color),
                  ]),
                  const SizedBox(height: 13),
                  Row(children: [
                    Expanded(
                        child: _InsightValue(
                            label: 'Performance',
                            value: '${student.performance.round()}%',
                            color: color)),
                    const SizedBox(width: 9),
                    Expanded(
                        child: _InsightValue(
                            label: 'Attendance',
                            value: '${student.attendance.toStringAsFixed(1)}%',
                            color: student.attendance < 75
                                ? SchoolBrand.primary
                                : const Color(0xFF00A878))),
                  ]),
                  if (needsSupport) ...[
                    const SizedBox(height: 11),
                    const Row(children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 16, color: SchoolBrand.primary),
                      SizedBox(width: 7),
                      Expanded(
                          child: Text(
                              'Support suggested: concepts, attendance and parent follow-up.',
                              style: TextStyle(fontSize: 10.5, color: _muted)))
                    ]),
                  ],
                ]),
              );
            }),
          ],
        ),
      );
}

class _InsightValue extends StatelessWidget {
  const _InsightValue(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(13)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 9.5, color: _muted)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ]),
      );
}

class TeacherNoticesPage extends StatelessWidget {
  const TeacherNoticesPage({required this.notices, super.key});
  final List<TeacherNotice> notices;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Staff notices')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageIntro(
                eyebrow: 'SCHOOL COMMUNICATION',
                title: 'Notices & circulars',
                subtitle: 'Important updates from school administration.',
                icon: Icons.campaign_rounded),
            const SizedBox(height: 16),
            ...notices.map((notice) => Card(
                  margin: const EdgeInsets.only(bottom: 11),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              backgroundColor: const Color(0xFFFFECEC),
                              child: Icon(
                                  notice.priority == 'Important'
                                      ? Icons.priority_high_rounded
                                      : Icons.notifications_rounded,
                                  color: SchoolBrand.primary)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(notice.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 5),
                                Text(notice.body,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        height: 1.4,
                                        color: _muted)),
                                const SizedBox(height: 8),
                                Text(notice.timeLabel,
                                    style: const TextStyle(
                                        fontSize: 9.5, color: _muted)),
                              ])),
                        ]),
                  ),
                )),
          ],
        ),
      );
}

class TeacherSettingsPage extends StatelessWidget {
  const TeacherSettingsPage({required this.profile, super.key});
  final TeacherProfile profile;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [_navy, Color(0xFF244F9C)]),
                  borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_rounded,
                        color: Colors.white, size: 30)),
                const SizedBox(width: 13),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(profile.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                      Text('${profile.employeeId} · ${profile.department}',
                          style: const TextStyle(
                              color: Color(0xFFCBD8ED), fontSize: 10.5)),
                    ])),
              ]),
            ),
            const SizedBox(height: 16),
            const _SettingTile(
                icon: Icons.person_outline_rounded,
                title: 'My profile',
                subtitle: 'Personal and employment information'),
            const _SettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Classes, tasks and school alerts'),
            const _SettingTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English'),
            const _SettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & security',
                subtitle: 'Device and sign-in controls'),
            const _SettingTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & support',
                subtitle: 'App support and school contact'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(SignedOut());
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: SchoolBrand.primary,
                  minimumSize: const Size.fromHeight(52)),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out securely'),
            ),
          ],
        ),
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          leading: Icon(icon, color: _blue),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 10, color: _muted)),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}

class _TeacherInfoPage extends StatelessWidget {
  const _TeacherInfoPage(
      {required this.title,
      required this.icon,
      required this.headline,
      required this.description});
  final String title;
  final IconData icon;
  final String headline;
  final String description;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _PageIntro(
              eyebrow: 'TEACHER WORKSPACE',
              title: headline,
              subtitle: description,
              icon: icon),
        ),
      );
}

class _PageIntro extends StatelessWidget {
  const _PageIntro(
      {required this.eyebrow,
      required this.title,
      required this.subtitle,
      required this.icon});
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, Color(0xFF244F9C)]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Color(0x2510203F), blurRadius: 20, offset: Offset(0, 9))
          ],
        ),
        child: Row(children: [
          Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white, size: 28)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(eyebrow,
                    style: const TextStyle(
                        color: Color(0xFFB8C9E6),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .9)),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFFD1DBEC),
                        fontSize: 10.5,
                        height: 1.35)),
              ])),
        ]),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 8.5, fontWeight: FontWeight.w900)),
      );
}

void _open(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}
