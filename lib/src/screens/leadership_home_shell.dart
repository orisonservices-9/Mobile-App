import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/leadership_models.dart';
import '../school_brand.dart';
import '../state/auth_bloc.dart';
import '../state/leadership_bloc.dart';

const _midnight = Color(0xFF101A35);
const _royal = Color(0xFF3157C8);
const _green = Color(0xFF07966C);
const _muted = Color(0xFF68758A);
final _money =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class LeadershipHomeShell extends StatefulWidget {
  const LeadershipHomeShell({super.key});

  @override
  State<LeadershipHomeShell> createState() => _LeadershipHomeShellState();
}

class _LeadershipHomeShellState extends State<LeadershipHomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LeadershipBloc, LeadershipState>(
        listenWhen: (previous, current) =>
            current is LeadershipReady && current.message != null,
        listener: (context, state) {
          if (state is LeadershipReady && state.message != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state is LeadershipInitial || state is LeadershipLoading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (state is LeadershipFailure) {
            return Scaffold(
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, size: 46, color: _muted),
                  const SizedBox(height: 12),
                  Text(state.message),
                  TextButton(
                    onPressed: () => context
                        .read<LeadershipBloc>()
                        .add(const LeadershipLoaded('DIR-001')),
                    child: const Text('Try again'),
                  ),
                ]),
              ),
            );
          }
          final ready = state as LeadershipReady;
          final pages = [
            LeadershipDashboardPage(data: ready.data),
            LeadershipInsightsPage(data: ready.data),
            const LeadershipApprovalsPage(embedded: true),
            LeadershipMorePage(data: ready.data),
          ];
          final openAlerts =
              ready.data.alerts.where((item) => !item.resolved).length;
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              title: const Row(children: [
                SchoolLogo(size: 36),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(SchoolBrand.shortName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                  Text('Leadership workspace',
                      style: TextStyle(
                          fontSize: 9.5,
                          color: _muted,
                          fontWeight: FontWeight.w600)),
                ]),
              ]),
              actions: [
                IconButton(
                  tooltip: 'Priority alerts',
                  onPressed: () => _open(
                    context,
                    LeadershipAlertsPage(alerts: ready.data.alerts),
                  ),
                  icon: Badge(
                    label: Text('$openAlerts'),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
                IconButton(
                  tooltip: 'Leadership settings',
                  onPressed: () => _open(
                    context,
                    LeadershipSettingsPage(profile: ready.data.profile),
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
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights_rounded),
                    label: 'Insights'),
                NavigationDestination(
                    icon: Icon(Icons.approval_outlined),
                    selectedIcon: Icon(Icons.approval_rounded),
                    label: 'Approvals'),
                NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'More'),
              ],
            ),
          );
        },
      );
}

class LeadershipDashboardPage extends StatelessWidget {
  const LeadershipDashboardPage({required this.data, super.key});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) {
    final openAlerts = data.alerts.where((item) => !item.resolved).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _LeadershipHero(data: data),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _ExecutiveMetric(
              icon: Icons.how_to_reg_rounded,
              label: 'Students present',
              value: '${data.studentAttendance}%',
              trend: '+1.4% vs avg',
              color: _green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ExecutiveMetric(
              icon: Icons.groups_rounded,
              label: 'Staff present',
              value: '${data.staffAttendance}%',
              trend: '${data.totalStaff} total staff',
              color: _royal,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _ExecutiveMetric(
              icon: Icons.payments_rounded,
              label: 'Collected today',
              value: _compactMoney(data.collectedToday),
              trend: '₹42K above target',
              color: const Color(0xFF8B5DC7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ExecutiveMetric(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Admission conversion',
              value: '${data.admissionConversion}%',
              trend: '+6.2% this month',
              color: const Color(0xFFE47A27),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _DailyPulsePanel(data: data),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'Priority action centre',
          subtitle: '${openAlerts.length} issues need leadership attention',
          action: 'View all',
          onTap: () =>
              _open(context, LeadershipAlertsPage(alerts: data.alerts)),
        ),
        const SizedBox(height: 11),
        ...openAlerts.take(3).map((alert) => _AlertCard(alert: alert)),
        const SizedBox(height: 22),
        _ApprovalPreview(data: data),
        const SizedBox(height: 22),
        _BranchSnapshot(data: data),
        const SizedBox(height: 22),
        const _SectionHeading(
          title: 'Today’s leadership calendar',
          subtitle: 'Meetings, reviews and institutional commitments',
        ),
        const SizedBox(height: 11),
        ...data.events.map((event) => _CalendarCard(event: event)),
        const SizedBox(height: 20),
        _ExecutiveInsight(data: data),
      ],
    );
  }
}

class _DailyPulsePanel extends StatelessWidget {
  const _DailyPulsePanel({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.school_rounded,
        '${data.academicRiskStudents}',
        'At-risk students',
        SchoolBrand.primary
      ),
      (
        Icons.menu_book_rounded,
        '${data.syllabusUnitsBehind}',
        'Units behind',
        const Color(0xFFE89718)
      ),
      (
        Icons.phone_missed_rounded,
        '${data.staleAdmissionLeads}',
        'Stale leads',
        const Color(0xFF7B5BC7)
      ),
      (
        Icons.support_agent_rounded,
        '${data.criticalParentTickets}',
        'SLA escalations',
        const Color(0xFF087E8B)
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F9),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE0E5EE)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.radar_rounded, color: _royal, size: 19),
          SizedBox(width: 8),
          Text('Today at a glance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          Spacer(),
          _Pill(text: 'LIVE', color: _green),
        ]),
        const SizedBox(height: 14),
        Row(
          children: items
              .map((item) => Expanded(
                    child: Column(children: [
                      Icon(item.$1, color: item.$4, size: 21),
                      const SizedBox(height: 5),
                      Text(item.$2,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(item.$3,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 7.5, height: 1.2, color: _muted)),
                    ]),
                  ))
              .toList(),
        ),
      ]),
    );
  }
}

class _BranchSnapshot extends StatelessWidget {
  const _BranchSnapshot({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) {
    final lowest = [...data.branches]
      ..sort((a, b) => a.health.compareTo(b.health));
    return InkWell(
      onTap: () =>
          _open(context, LeadershipBranchesPage(branches: data.branches)),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            CircleAvatar(
              backgroundColor: Color(0xFFEEF3FF),
              child: Icon(Icons.account_tree_rounded, color: _royal),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Branch performance',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900)),
                    Text('Compare health, attendance and collections',
                        style: TextStyle(fontSize: 9.5, color: _muted)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded, color: _muted),
          ]),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(
                child: _MiniValue(
                    label: 'Branches',
                    value: '${data.branches.length}',
                    color: _royal)),
            Expanded(
                child: _MiniValue(
                    label: 'Best health',
                    value:
                        '${data.branches.map((e) => e.health).reduce((a, b) => a > b ? a : b)}',
                    color: _green)),
            Expanded(
                child: _MiniValue(
                    label: 'Needs focus',
                    value: lowest.first.name.replaceAll(' Campus', ''),
                    color: SchoolBrand.primary)),
          ]),
        ]),
      ),
    );
  }
}

class _LeadershipHero extends StatelessWidget {
  const _LeadershipHero({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_midnight, Color(0xFF253C73), Color(0xFF744049)],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: const [
            BoxShadow(
                color: Color(0x35101A35),
                blurRadius: 26,
                offset: Offset(0, 13)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GOOD MORNING',
                      style: TextStyle(
                          color: Color(0xFFBFCBE2),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text(data.profile.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${data.profile.designation} · ${data.profile.campus}',
                      style: const TextStyle(
                          color: Color(0xFFD8E0EF), fontSize: 10.5)),
                ],
              ),
            ),
            SizedBox(
              width: 75,
              height: 75,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: data.schoolHealth / 100,
                  strokeWidth: 7,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFFFFD36B),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${data.schoolHealth}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900)),
                  const Text('HEALTH',
                      style: TextStyle(
                          color: Color(0xFFCCD6E8),
                          fontSize: 7,
                          fontWeight: FontWeight.w800)),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: .12)),
            ),
            child: Row(children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFFFD36B), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${data.totalStudents} students · ${data.totalStaff} staff · ${data.pendingApprovals} approvals waiting',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ]),
          ),
        ]),
      );
}

class _ExecutiveMetric extends StatelessWidget {
  const _ExecutiveMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const Spacer(),
            const Icon(Icons.more_horiz_rounded, color: Color(0xFFBBC2CE)),
          ]),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5, color: _muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(trend,
              style: TextStyle(
                  color: color, fontSize: 8.5, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.action,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 10.5, color: _muted)),
          ]),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ]);
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final LeadershipAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.severity == 'High'
        ? SchoolBrand.primary
        : const Color(0xFFE89718);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13)),
          child: Icon(_domainIcon(alert.domain), color: color, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(alert.title,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w900)),
              ),
              _Pill(text: alert.severity, color: color),
            ]),
            const SizedBox(height: 5),
            Text(alert.detail,
                style: const TextStyle(
                    fontSize: 10.5, height: 1.35, color: _muted)),
            const SizedBox(height: 7),
            Text(alert.actionLabel,
                style: TextStyle(
                    color: color, fontSize: 9.5, fontWeight: FontWeight.w900)),
          ]),
        ),
      ]),
    );
  }
}

class _ApprovalPreview extends StatelessWidget {
  const _ApprovalPreview({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) {
    final pending =
        data.approvals.where((item) => item.status == 'Pending').toList();
    return InkWell(
      onTap: () => _open(context, const LeadershipApprovalsPage()),
      borderRadius: BorderRadius.circular(23),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
            color: _midnight, borderRadius: BorderRadius.circular(23)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white12,
              child: Icon(Icons.approval_rounded,
                  color: Color(0xFFFFD36B), size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Approvals waiting',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  Text('Review requests without leaving the app',
                      style:
                          TextStyle(color: Color(0xFFBFC9DC), fontSize: 9.5)),
                ],
              ),
            ),
            Text('${pending.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 14),
          ...pending.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.circle, color: Color(0xFFFFD36B), size: 7),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text(item.timeLabel,
                      style: const TextStyle(
                          color: Color(0xFFBFC9DC), fontSize: 8.5)),
                ]),
              )),
        ]),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.event});
  final LeadershipCalendarEvent event;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        child: Row(children: [
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(12)),
            child: Text(event.time.replaceAll(' ', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _royal, fontSize: 8.5, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text('${event.location} · ${event.category}',
                  style: const TextStyle(fontSize: 9.5, color: _muted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: _muted),
        ]),
      );
}

class _ExecutiveInsight extends StatelessWidget {
  const _ExecutiveInsight({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFF8E8), Color(0xFFFFF1D1)]),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFF5DBA0)),
        ),
        child:
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFFB17A00)),
          SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Leadership insight',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text(
                'Attendance and admissions are trending upward. Academic intervention in Grade 10-C and fee follow-up should remain this week’s priorities.',
                style: TextStyle(fontSize: 10.5, height: 1.45, color: _muted),
              ),
            ]),
          ),
        ]),
      );
}

class LeadershipInsightsPage extends StatelessWidget {
  const LeadershipInsightsPage({required this.data, super.key});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: [
          _PageHero(
            eyebrow: 'SCHOOL INTELLIGENCE',
            title: 'Leadership insights',
            subtitle:
                'One verified view of academics, finance, admissions, people and operations.',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 18),
          const _SectionHeading(
            title: 'Performance domains',
            subtitle: 'Tap any area for its executive breakdown',
          ),
          const SizedBox(height: 11),
          _InsightDomainCard(
            icon: Icons.school_rounded,
            title: 'Academic health',
            value: '${data.academicRiskStudents} at risk',
            detail:
                '${data.openInterventions} open interventions · ${data.syllabusUnitsBehind} syllabus units behind',
            color: SchoolBrand.primary,
            onTap: () => _open(context, LeadershipAcademicsPage(data: data)),
          ),
          _InsightDomainCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Collection intelligence',
            value: '${data.collectionProgress}% of target',
            detail:
                '${_money.format(data.outstandingFees)} outstanding · ${data.overdueFeeAccounts} overdue accounts',
            color: _green,
            onTap: () => _open(context, LeadershipFinancePage(data: data)),
          ),
          _InsightDomainCard(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Admissions health',
            value: '${data.admissionConversion}% conversion',
            detail:
                '${data.staleAdmissionLeads} leads without follow-up for 48+ hours',
            color: const Color(0xFFE47A27),
            onTap: () => _open(context, LeadershipAdmissionsPage(data: data)),
          ),
          _InsightDomainCard(
            icon: Icons.groups_rounded,
            title: 'People & capacity',
            value: '${data.staffAttendance}% present',
            detail:
                '${data.substitutionGaps} substitution gaps · 4 open positions',
            color: const Color(0xFF7B5BC7),
            onTap: () => _open(context, LeadershipStaffPage(data: data)),
          ),
          _InsightDomainCard(
            icon: Icons.directions_bus_rounded,
            title: 'Transport & safety',
            value: '${data.transportOnTime}% on time',
            detail:
                '${data.delayedRoutes} delayed route · ${data.securityIncidents} safety incidents',
            color: const Color(0xFFE89718),
            onTap: () => _open(context, LeadershipTransportPage(data: data)),
          ),
          _InsightDomainCard(
            icon: Icons.support_agent_rounded,
            title: 'Parent service quality',
            value: '${data.criticalParentTickets} escalations',
            detail: '4.6/5 satisfaction · median response 3h 18m',
            color: const Color(0xFF087E8B),
            onTap: () => _open(
              context,
              const LeadershipGenericPage(
                title: 'Service escalations',
                icon: Icons.support_agent_rounded,
                headline: 'Parent service command',
                detail:
                    'Prioritised complaints, callback requests, ownership, response SLA and closure quality.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _BranchSnapshot(data: data),
        ],
      );
}

class _InsightDomainCard extends StatelessWidget {
  const _InsightDomainCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F0)),
          ),
          child: Row(children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 11,
                            color: _muted,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(detail,
                        style: const TextStyle(
                            fontSize: 9, height: 1.3, color: _muted)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted),
          ]),
        ),
      );
}

class LeadershipAcademicsPage extends StatelessWidget {
  const LeadershipAcademicsPage({required this.data, super.key});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            title: const Text('Academic intelligence',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                  tooltip: 'Academic report',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Academic leadership report prepared'))),
                  icon: const Icon(Icons.ios_share_rounded)),
            ],
          ),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: _AcademicCommandHero(data: data),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _AcademicFilter(
                    label: 'Term 1', icon: Icons.event_note_rounded),
                SizedBox(width: 8),
                _AcademicFilter(
                    label: 'All grades', icon: Icons.school_outlined),
                SizedBox(width: 8),
                _AcademicFilter(
                    label: 'Main campus', icon: Icons.location_on_outlined),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8ECF3),
                    borderRadius: BorderRadius.circular(15)),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 8,
                          offset: Offset(0, 3))
                    ],
                  ),
                  labelColor: _midnight,
                  unselectedLabelColor: _muted,
                  labelStyle: const TextStyle(
                      fontSize: 10.5, fontWeight: FontWeight.w900),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Teachers'),
                    Tab(text: 'Students'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(children: [
                _AcademicOverviewTab(data: data),
                _TeacherPerformanceTab(data: data),
                _StudentPerformanceTab(data: data),
              ]),
            ),
          ]),
        ),
      );
}

class _AcademicCommandHero extends StatelessWidget {
  const _AcademicCommandHero({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111C38), Color(0xFF274B8B)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Color(0x30101A35),
                blurRadius: 22,
                offset: Offset(0, 11)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_graph_rounded,
                  color: Color(0xFFFFD36B), size: 25),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACADEMIC COMMAND CENTRE',
                        style: TextStyle(
                            color: Color(0xFFAEC0E0),
                            fontSize: 8,
                            letterSpacing: .9,
                            fontWeight: FontWeight.w900)),
                    SizedBox(height: 3),
                    Text('Learning performance',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900)),
                  ]),
            ),
            const _Pill(text: 'LIVE', color: Color(0xFF43D6A3)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: _HeroAcademicMetric(
                    value: '82.6%', label: 'School average')),
            Container(width: 1, height: 34, color: Colors.white24),
            Expanded(
                child: _HeroAcademicMetric(
                    value: '${data.academicRiskStudents}',
                    label: 'Need support')),
            Container(width: 1, height: 34, color: Colors.white24),
            Expanded(
                child: _HeroAcademicMetric(
                    value: '${data.openInterventions}',
                    label: 'Interventions')),
          ]),
        ]),
      );
}

class _HeroAcademicMetric extends StatelessWidget {
  const _HeroAcademicMetric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFBFCBE0), fontSize: 8.5)),
      ]);
}

class _AcademicFilter extends StatelessWidget {
  const _AcademicFilter({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE2E6ED))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: _royal),
            const SizedBox(width: 5),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 8.5, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      );
}

class _AcademicOverviewTab extends StatelessWidget {
  const _AcademicOverviewTab({required this.data});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          const _AcademicInsightBanner(),
          const SizedBox(height: 18),
          const _SectionHeading(
              title: 'Grade performance',
              subtitle: 'Results, movement and student support demand'),
          const SizedBox(height: 10),
          ...data.academics.map((item) => _AcademicGradeCard(item: item)),
          const SizedBox(height: 8),
          _InterventionPanel(data: data),
        ],
      );
}

class _AcademicInsightBanner extends StatelessWidget {
  const _AcademicInsightBanner();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFF7E5), Color(0xFFFFFDF7)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0D59A)),
        ),
        child:
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFFB17A00), size: 20),
          SizedBox(width: 9),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Director insight',
                  style:
                      TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
              SizedBox(height: 3),
              Text(
                'Physics and Mathematics improved strongly. Grade 10-C Science and senior Chemistry require a joint teacher-coaching and student-support plan.',
                style: TextStyle(fontSize: 9.5, height: 1.4, color: _muted),
              ),
            ]),
          ),
        ]),
      );
}

class _TeacherPerformanceTab extends StatelessWidget {
  const _TeacherPerformanceTab({required this.data});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) {
    final improving =
        data.teacherPerformance.where((item) => item.resultGrowth > 0).length;
    final coaching =
        data.teacherPerformance.where((item) => item.resultGrowth < 0).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Row(children: [
          Expanded(
              child: _AcademicSummaryCard(
                  label: 'Driving improvement',
                  value: '$improving teachers',
                  icon: Icons.trending_up_rounded,
                  color: _green)),
          const SizedBox(width: 9),
          Expanded(
              child: _AcademicSummaryCard(
                  label: 'Coaching priority',
                  value: '$coaching teachers',
                  icon: Icons.co_present_rounded,
                  color: SchoolBrand.primary)),
        ]),
        const SizedBox(height: 18),
        const _SectionHeading(
          title: 'Teacher impact',
          subtitle:
              'Student outcomes, lesson execution and intervention closure',
        ),
        const SizedBox(height: 10),
        ...data.teacherPerformance
            .map((item) => _TeacherPerformanceCard(item: item)),
      ],
    );
  }
}

class _StudentPerformanceTab extends StatefulWidget {
  const _StudentPerformanceTab({required this.data});
  final LeadershipSnapshot data;

  @override
  State<_StudentPerformanceTab> createState() => _StudentPerformanceTabState();
}

class _StudentPerformanceTabState extends State<_StudentPerformanceTab> {
  String filter = 'Needs attention';

  List<LeadershipStudentPerformance> get filtered {
    return widget.data.studentPerformance.where((item) {
      return _matchesStudentFilter(item, filter);
    }).toList()
      ..sort((a, b) {
        if (filter == 'Needs attention') return a.change.compareTo(b.change);
        if (filter == 'Improved') return b.change.compareTo(a.change);
        return b.average.compareTo(a.average);
      });
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered.take(6).toList();
    final total = switch (filter) {
      'Improved' => widget.data.improvedStudentCount,
      'Needs attention' => widget.data.attentionStudentCount,
      'Top performers' => widget.data.topPerformerCount,
      _ => widget.data.totalStudents,
    };
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
          sliver: SliverToBoxAdapter(child: _StudentDistributionPanel()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(children: [
              Expanded(
                  child: _AcademicSummaryCard(
                      label: 'Improved since last exam',
                      value: '${widget.data.improvedStudentCount}',
                      icon: Icons.trending_up_rounded,
                      color: _green)),
              const SizedBox(width: 9),
              Expanded(
                  child: _AcademicSummaryCard(
                      label: 'Need active attention',
                      value: '${widget.data.attentionStudentCount}',
                      icon: Icons.priority_high_rounded,
                      color: SchoolBrand.primary)),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              children: ['Needs attention', 'Improved', 'Top performers', 'All']
                  .map((label) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: filter == label,
                          onSelected: (_) => setState(() => filter = label),
                          showCheckmark: false,
                          selectedColor: _midnight,
                          labelStyle: TextStyle(
                              color: filter == label ? Colors.white : _muted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          sliver: SliverToBoxAdapter(
            child: _SectionHeading(
              title: filter,
              subtitle: '$total students in this school-wide segment',
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _EmptyPanel(
                  icon: Icons.search_off_rounded,
                  title: 'No matching student',
                  message:
                      'Try another name, class, subject or performance filter.'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _StudentPerformanceCard(item: items[index]),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 30),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: () => _downloadStudentPerformanceReport(
                  context, widget.data, filter, filtered, total),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: _royal),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text('Download $filter PDF report'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AcademicGradeCard extends StatelessWidget {
  const _AcademicGradeCard({required this.item});
  final AcademicClassInsight item;

  @override
  Widget build(BuildContext context) {
    final trendColor = item.trend >= 0 ? _green : SchoolBrand.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Text(item.className,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          _Pill(
              text: '${item.trend >= 0 ? '+' : ''}${item.trend}%',
              color: trendColor),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _MiniValue(
                  label: 'Pass rate',
                  value: '${item.passPercentage}%',
                  color: _green)),
          Expanded(
              child: _MiniValue(
                  label: 'Average', value: '${item.average}%', color: _royal)),
          Expanded(
              child: _MiniValue(
                  label: 'Need support',
                  value: '${item.supportStudents}',
                  color: SchoolBrand.primary)),
        ]),
        const SizedBox(height: 13),
        Row(children: [
          Expanded(
            child: _SubjectSignal(
                icon: Icons.trending_up_rounded,
                label: 'Strongest',
                subject: item.topSubject,
                color: _green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SubjectSignal(
                icon: Icons.support_rounded,
                label: 'Needs focus',
                subject: item.weakSubject,
                color: SchoolBrand.primary),
          ),
        ]),
      ]),
    );
  }
}

class _AcademicSummaryCard extends StatelessWidget {
  const _AcademicSummaryCard({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E6ED)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 8.5, color: _muted)),
        ]),
      );
}

class _TeacherPerformanceCard extends StatelessWidget {
  const _TeacherPerformanceCard({required this.item});
  final LeadershipTeacherPerformance item;

  @override
  Widget build(BuildContext context) {
    final positive = item.resultGrowth >= 0;
    final signalColor = item.signal == 'Needs intervention'
        ? SchoolBrand.primary
        : item.signal == 'Coaching recommended'
            ? const Color(0xFFE89718)
            : _green;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E6ED)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [signalColor.withValues(alpha: .9), signalColor]),
                borderRadius: BorderRadius.circular(14)),
            child: Text(
              item.name
                  .split(' ')
                  .where((part) => part.isNotEmpty && !part.contains('.'))
                  .take(2)
                  .map((part) => part[0])
                  .join(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text('${item.subject} · ${item.classes}',
                  style: const TextStyle(fontSize: 9.5, color: _muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFB018), size: 16),
              const SizedBox(width: 2),
              Text('${item.rating}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 3),
            _Pill(text: item.signal, color: signalColor),
          ]),
        ]),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
              color: const Color(0xFFF6F7FA),
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Expanded(
                child: _MiniValue(
                    label: 'Student avg',
                    value: '${item.studentAverage}%',
                    color: _royal)),
            Expanded(
                child: _MiniValue(
                    label: 'Result growth',
                    value:
                        '${positive ? '+' : ''}${item.resultGrowth.toStringAsFixed(1)}%',
                    color: positive ? _green : SchoolBrand.primary)),
            Expanded(
                child: _MiniValue(
                    label: 'Plans complete',
                    value: '${item.lessonPlanCompletion.toStringAsFixed(0)}%',
                    color: const Color(0xFF7B5BC7))),
          ]),
        ),
        const SizedBox(height: 12),
        _ProgressLine(
            label: 'Support closed',
            value: item.studentSupportClosure,
            color: signalColor),
      ]),
    );
  }
}

class _StudentDistributionPanel extends StatelessWidget {
  const _StudentDistributionPanel();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E6ED)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('School performance distribution',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text('1,284 students · Term 1 latest assessment',
              style: TextStyle(fontSize: 9, color: _muted)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const Row(children: [
              Expanded(
                  flex: 28,
                  child:
                      ColoredBox(color: _green, child: SizedBox(height: 11))),
              Expanded(
                  flex: 49,
                  child:
                      ColoredBox(color: _royal, child: SizedBox(height: 11))),
              Expanded(
                  flex: 17,
                  child: ColoredBox(
                      color: Color(0xFFE89718), child: SizedBox(height: 11))),
              Expanded(
                  flex: 6,
                  child: ColoredBox(
                      color: SchoolBrand.primary, child: SizedBox(height: 11))),
            ]),
          ),
          const SizedBox(height: 13),
          const Row(children: [
            Expanded(
                child: _DistributionKey(
                    label: 'Excellent', value: '28%', color: _green)),
            Expanded(
                child: _DistributionKey(
                    label: 'On track', value: '49%', color: _royal)),
            Expanded(
                child: _DistributionKey(
                    label: 'Support', value: '17%', color: Color(0xFFE89718))),
            Expanded(
                child: _DistributionKey(
                    label: 'Critical',
                    value: '6%',
                    color: SchoolBrand.primary)),
          ]),
        ]),
      );
}

class _DistributionKey extends StatelessWidget {
  const _DistributionKey(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 7.5, color: _muted)),
      ]);
}

class _StudentPerformanceCard extends StatelessWidget {
  const _StudentPerformanceCard({required this.item});
  final LeadershipStudentPerformance item;

  @override
  Widget build(BuildContext context) {
    final positive = item.change >= 0;
    final signalColor = item.signal == 'Immediate support'
        ? SchoolBrand.primary
        : item.signal == 'Monitor closely'
            ? const Color(0xFFE89718)
            : _green;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E6ED)),
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: signalColor.withValues(alpha: .1),
            child: Text(
                item.name.split(' ').map((part) => part[0]).take(2).join(),
                style:
                    TextStyle(color: signalColor, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900)),
              Text(item.className,
                  style: const TextStyle(fontSize: 9, color: _muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${item.average}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text('${positive ? '+' : ''}${item.change.toStringAsFixed(1)}%',
                style: TextStyle(
                    color: positive ? _green : SchoolBrand.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _SubjectSignal(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Strongest',
                  subject: item.strongestSubject,
                  color: _green)),
          const SizedBox(width: 8),
          Expanded(
              child: _SubjectSignal(
                  icon: Icons.support_rounded,
                  label: 'Needs support',
                  subject: item.supportSubject,
                  color: signalColor)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.how_to_reg_rounded, color: signalColor, size: 16),
          const SizedBox(width: 5),
          Text('${item.attendance}% attendance',
              style: const TextStyle(fontSize: 9, color: _muted)),
          const Spacer(),
          _Pill(text: item.signal, color: signalColor),
        ]),
      ]),
    );
  }
}

bool _matchesStudentFilter(LeadershipStudentPerformance item, String filter) =>
    switch (filter) {
      'Improved' => item.change > 0,
      'Needs attention' => item.change < 0 || item.average < 70,
      'Top performers' => item.average >= 85,
      _ => true,
    };

Future<Uint8List> _buildStudentPerformancePdf(
  LeadershipSnapshot data,
  String category,
  List<LeadershipStudentPerformance> students,
  int total,
) async {
  final document = pw.Document(
    title: 'Orison $category student performance report',
    author: data.profile.schoolName,
  );
  final generated = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#101A35'),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Row(children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(data.profile.schoolName.toUpperCase(),
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text('Academic Intelligence - Director Report',
                    style: const pw.TextStyle(
                        color: PdfColors.grey300, fontSize: 9)),
              ],
            ),
          ),
          pw.Text(generated,
              style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8)),
        ]),
      ),
      build: (_) => [
        pw.SizedBox(height: 20),
        pw.Text(category.toUpperCase(),
            style: pw.TextStyle(
                color: PdfColor.fromHex('#3157C8'),
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1)),
        pw.SizedBox(height: 5),
        pw.Text('$total students in this school-wide performance segment',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(
          'Term 1 | All grades | ${data.profile.campus} | ${students.length} detailed priority records included',
          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: .5),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.6),
            1: pw.FlexColumnWidth(.9),
            2: pw.FlexColumnWidth(.7),
            3: pw.FlexColumnWidth(.7),
            4: pw.FlexColumnWidth(1.1),
            5: pw.FlexColumnWidth(1.1),
            6: pw.FlexColumnWidth(.8),
            7: pw.FlexColumnWidth(1.1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#EAF0FC')),
              children: [
                'Student',
                'Class',
                'Average',
                'Change',
                'Strongest',
                'Needs support',
                'Attendance',
                'Signal',
              ].map((value) => _academicPdfCell(value, header: true)).toList(),
            ),
            ...students.map(
              (item) => pw.TableRow(children: [
                _academicPdfCell(item.name),
                _academicPdfCell(item.className),
                _academicPdfCell('${item.average}%'),
                _academicPdfCell(
                    '${item.change >= 0 ? '+' : ''}${item.change.toStringAsFixed(1)}%'),
                _academicPdfCell(item.strongestSubject),
                _academicPdfCell(item.supportSubject),
                _academicPdfCell('${item.attendance}%'),
                _academicPdfCell(item.signal),
              ]),
            ),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(7)),
          child: pw.Text(
            'Confidential leadership report. Use this information for academic intervention, teacher support and authorised school planning only.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 8),
          ),
        ),
      ],
    ),
  );
  return document.save();
}

pw.Widget _academicPdfCell(String value, {bool header = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(value,
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );

Future<void> _downloadStudentPerformanceReport(
  BuildContext context,
  LeadershipSnapshot data,
  String category,
  List<LeadershipStudentPerformance> students,
  int total,
) async {
  try {
    final filename =
        'orison_${category.toLowerCase().replaceAll(' ', '_')}_students.pdf';
    await Printing.sharePdf(
      bytes: await _buildStudentPerformancePdf(data, category, students, total),
      filename: filename,
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unable to prepare the student performance PDF.')));
    }
  }
}

class _MiniValue extends StatelessWidget {
  const _MiniValue(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: _muted)),
      ]);
}

class _SubjectSignal extends StatelessWidget {
  const _SubjectSignal({
    required this.icon,
    required this.label,
    required this.subject,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 8.5, color: _muted)),
              Text(subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
          ),
        ]),
      );
}

class _DivisionAttendanceCard extends StatelessWidget {
  const _DivisionAttendanceCard({required this.item});
  final AttendanceDivision item;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Text(item.label,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w900)),
            ),
            Text('${item.studentsPresent}/${item.totalStudents} students',
                style: const TextStyle(fontSize: 9.5, color: _muted)),
          ]),
          const SizedBox(height: 10),
          _ProgressLine(
              label: 'Students', value: item.studentRate, color: _royal),
          const SizedBox(height: 8),
          _ProgressLine(label: 'Staff', value: item.staffRate, color: _green),
        ]),
      );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine(
      {required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 55,
            child: Text(label,
                style: const TextStyle(fontSize: 9.5, color: _muted))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFE8ECF2),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 40,
          child: Text('${value.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color, fontSize: 9.5, fontWeight: FontWeight.w900)),
        ),
      ]);
}

class _InterventionPanel extends StatelessWidget {
  const _InterventionPanel({required this.data});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFFFD3D3)),
        ),
        child: Row(children: [
          const CircleAvatar(
              backgroundColor: Color(0xFFFFDCDC),
              child: Icon(Icons.support_rounded, color: SchoolBrand.primary)),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${data.academicRiskStudents} intervention cases',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              const Text(
                '7 have no parent meeting scheduled. Assign the academic coordinator today.',
                style: TextStyle(fontSize: 10, height: 1.35, color: _muted),
              ),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: SchoolBrand.primary),
        ]),
      );
}

class LeadershipOperationsPage extends StatelessWidget {
  const LeadershipOperationsPage({required this.data, super.key});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: [
          const _PageHero(
            eyebrow: 'INSTITUTIONAL OPERATIONS',
            title: 'School operations',
            subtitle:
                'Finance, admissions, people, transport and service quality.',
            icon: Icons.domain_rounded,
          ),
          const SizedBox(height: 18),
          _OperationFinance(data: data),
          const SizedBox(height: 14),
          _AdmissionFunnel(data: data),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _OperationStatusCard(
                icon: Icons.directions_bus_rounded,
                title: 'Transport',
                value: '${data.transportOnTime}%',
                subtitle: '11 of 12 routes on time',
                color: const Color(0xFFE89718),
                onTap: () =>
                    _open(context, LeadershipTransportPage(data: data)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OperationStatusCard(
                icon: Icons.badge_rounded,
                title: 'Staff & HR',
                value: '${data.staffAttendance}%',
                subtitle: '5 requests pending',
                color: _royal,
                onTap: () => _open(context, LeadershipStaffPage(data: data)),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _ServiceQualityPanel(data: data),
        ],
      );
}

class _OperationFinance extends StatelessWidget {
  const _OperationFinance({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _open(context, LeadershipFinancePage(data: data)),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF17453A), Color(0xFF08775F)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
              SizedBox(width: 9),
              Text('Finance pulse',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
              Spacer(),
              Icon(Icons.chevron_right_rounded, color: Colors.white),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _DarkMetric(
                    label: 'COLLECTED TODAY',
                    value: _money.format(data.collectedToday)),
              ),
              Container(width: 1, height: 42, color: Colors.white24),
              const SizedBox(width: 15),
              Expanded(
                child: _DarkMetric(
                    label: 'OUTSTANDING',
                    value: _money.format(data.outstandingFees)),
              ),
            ]),
          ]),
        ),
      );
}

class _DarkMetric extends StatelessWidget {
  const _DarkMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFBAD7CF),
                  fontSize: 8,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
        ],
      );
}

class _AdmissionFunnel extends StatelessWidget {
  const _AdmissionFunnel({required this.data});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) {
    final maximum = data.admissionFunnel.values.first.toDouble();
    return InkWell(
      onTap: () => _open(context, LeadershipAdmissionsPage(data: data)),
      borderRadius: BorderRadius.circular(21),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFE5E9F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
              child: Text('Admission funnel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ),
            _Pill(
                text: '${data.admissionConversion}% conversion', color: _royal),
          ]),
          const SizedBox(height: 13),
          ...data.admissionFunnel.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(
                      width: 78,
                      child: Text(entry.key,
                          style:
                              const TextStyle(fontSize: 9.5, color: _muted))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: LinearProgressIndicator(
                        value: entry.value / maximum,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE9EDF4),
                        color: _royal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 32,
                    child: Text('${entry.value}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ]),
              )),
        ]),
      ),
    );
  }
}

class _OperationStatusCard extends StatelessWidget {
  const _OperationStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F0)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 11, color: _muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(value,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: const TextStyle(fontSize: 8.5, color: _muted)),
          ]),
        ),
      );
}

class _ServiceQualityPanel extends StatelessWidget {
  const _ServiceQualityPanel({required this.data});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1FF),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFFDDD3FF)),
        ),
        child: const Row(children: [
          CircleAvatar(
              backgroundColor: Color(0xFFE6DEFF),
              child:
                  Icon(Icons.support_agent_rounded, color: Color(0xFF7353C7))),
          SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Parent service quality · 4.6/5',
                  style:
                      TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
              SizedBox(height: 3),
              Text('8 open requests · 2 escalated · median response 3h 18m',
                  style: TextStyle(fontSize: 9.5, color: _muted)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: Color(0xFF7353C7)),
        ]),
      );
}

class LeadershipMorePage extends StatelessWidget {
  const LeadershipMorePage({required this.data, super.key});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) {
    final services = [
      _LeadershipService(
          Icons.approval_rounded,
          'Approvals',
          '${data.pendingApprovals} decisions',
          const Color(0xFFE89718),
          const LeadershipApprovalsPage()),
      _LeadershipService(
          Icons.account_tree_rounded,
          'Branches',
          'Compare campuses',
          _royal,
          LeadershipBranchesPage(branches: data.branches)),
      _LeadershipService(
          Icons.campaign_rounded,
          'Announcement',
          'Publish securely',
          SchoolBrand.primary,
          const LeadershipAnnouncementPage()),
      _LeadershipService(Icons.account_balance_wallet_rounded, 'Finance',
          'Collections & dues', _green, LeadershipFinancePage(data: data)),
      _LeadershipService(Icons.how_to_reg_rounded, 'Attendance',
          'Students & staff', _royal, LeadershipAttendancePage(data: data)),
      _LeadershipService(
          Icons.person_add_alt_1_rounded,
          'Admissions',
          'Funnel & follow-ups',
          const Color(0xFFE47A27),
          LeadershipAdmissionsPage(data: data)),
      _LeadershipService(Icons.badge_rounded, 'Staff & HR', 'People & leave',
          const Color(0xFF7B5BC7), LeadershipStaffPage(data: data)),
      _LeadershipService(
          Icons.directions_bus_rounded,
          'Transport',
          'Routes & safety',
          const Color(0xFFDB8B18),
          LeadershipTransportPage(data: data)),
      _LeadershipService(
          Icons.calendar_month_rounded,
          'Calendar',
          'Meetings & events',
          const Color(0xFFDA4B82),
          LeadershipCalendarPage(events: data.events)),
      _LeadershipService(
          Icons.analytics_rounded,
          'Executive reports',
          'Board-ready reports',
          const Color(0xFF087E8B),
          LeadershipReportsPage(data: data)),
      const _LeadershipService(
          Icons.payments_rounded,
          'Payroll oversight',
          'Variance & exceptions',
          Color(0xFF7B5BC7),
          LeadershipGenericPage(
              title: 'Payroll oversight',
              icon: Icons.payments_rounded,
              headline: 'Payroll controls',
              detail:
                  'Review payroll totals, unusual variances, off-cycle payments and exceptions requiring leadership authority.')),
      const _LeadershipService(
          Icons.inventory_2_rounded,
          'Stock & purchase',
          'Risk and exceptions',
          Color(0xFFE47A27),
          LeadershipGenericPage(
              title: 'Stock & purchase',
              icon: Icons.inventory_2_rounded,
              headline: 'Procurement intelligence',
              detail:
                  'Monitor low stock, stock variance, high-value purchase requests and department budget impact.')),
      const _LeadershipService(
          Icons.security_rounded,
          'Safety & visitors',
          'Campus incidents',
          Color(0xFF087E8B),
          LeadershipGenericPage(
              title: 'Safety & visitors',
              icon: Icons.security_rounded,
              headline: 'No critical incidents',
              detail:
                  'Monitor visitor exceptions, emergency incidents, access irregularities and required closures.')),
      _LeadershipService(
          Icons.support_agent_rounded,
          'Escalations',
          'Parent service issues',
          const Color(0xFF526177),
          const LeadershipGenericPage(
              title: 'Service escalations',
              icon: Icons.support_agent_rounded,
              headline: '2 escalations need review',
              detail:
                  'Track parent complaints, ownership, response SLA and final resolution.')),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        const _PageHero(
          eyebrow: 'LEADERSHIP SERVICES',
          title: 'Control centre',
          subtitle: 'Decision tools, reports and institutional communication.',
          icon: Icons.grid_view_rounded,
        ),
        const SizedBox(height: 18),
        GridView.builder(
          itemCount: services.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.05,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
          ),
          itemBuilder: (context, index) =>
              _LeadershipServiceTile(item: services[index]),
        ),
        const SizedBox(height: 16),
        ListTile(
          tileColor: _midnight,
          textColor: Colors.white,
          iconColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: const Icon(Icons.settings_rounded),
          title: const Text('Leadership settings',
              style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text(
              'Profile, security, delegation and notifications',
              style: TextStyle(color: Color(0xFFBCC8DE), fontSize: 10.5)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              _open(context, LeadershipSettingsPage(profile: data.profile)),
        ),
      ],
    );
  }
}

class _LeadershipService {
  const _LeadershipService(
      this.icon, this.title, this.subtitle, this.color, this.page);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget page;
}

class _LeadershipServiceTile extends StatelessWidget {
  const _LeadershipServiceTile({required this.item});
  final _LeadershipService item;

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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            const Spacer(),
            Text(item.title,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(item.subtitle,
                style: const TextStyle(fontSize: 9.5, color: _muted)),
          ]),
        ),
      );
}

class LeadershipApprovalsPage extends StatelessWidget {
  const LeadershipApprovalsPage({this.embedded = false, super.key});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<LeadershipBloc, LeadershipState>(
      builder: (context, state) {
        if (state is! LeadershipReady) {
          return const Center(child: CircularProgressIndicator());
        }
        final approvals = state.data.approvals;
        final pending =
            approvals.where((item) => item.status == 'Pending').toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _PageHero(
              eyebrow: 'DECISION QUEUE',
              title: '${pending.length} requests waiting',
              subtitle:
                  'Only policy, financial and structural decisions requiring your authority.',
              icon: Icons.approval_rounded,
            ),
            const SizedBox(height: 12),
            const _ApprovalGovernanceNotice(),
            const SizedBox(height: 18),
            if (pending.isEmpty)
              const _EmptyPanel(
                icon: Icons.task_alt_rounded,
                title: 'All caught up',
                message: 'There are no pending leadership approvals.',
              )
            else
              ...pending.map((item) => _ApprovalCard(item: item)),
            if (approvals.any((item) => item.status != 'Pending')) ...[
              const SizedBox(height: 18),
              const _SectionHeading(
                  title: 'Recently decided',
                  subtitle: 'Recorded in the leadership audit trail'),
              const SizedBox(height: 10),
              ...approvals
                  .where((item) => item.status != 'Pending')
                  .map((item) => _ApprovalCard(item: item)),
            ],
          ],
        );
      },
    );
    if (embedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: content,
    );
  }
}

class _ApprovalGovernanceNotice extends StatelessWidget {
  const _ApprovalGovernanceNotice();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E8),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFF1D99C)),
        ),
        child: const Row(children: [
          Icon(Icons.verified_user_rounded, color: Color(0xFFB17A00), size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Routine attendance, marks, payment proofs and normal leave stay with their responsible teams.',
              style: TextStyle(fontSize: 9.5, height: 1.35, color: _muted),
            ),
          ),
        ]),
      );
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.item});
  final LeadershipApproval item;

  @override
  Widget build(BuildContext context) {
    final pending = item.status == 'Pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Pill(text: item.type, color: _royal),
          const SizedBox(width: 6),
          _Pill(
              text: '${item.risk} risk',
              color: item.risk == 'Critical' || item.risk == 'High'
                  ? SchoolBrand.primary
                  : const Color(0xFFE89718)),
          const Spacer(),
          Text(item.timeLabel,
              style: const TextStyle(fontSize: 9, color: _muted)),
        ]),
        const SizedBox(height: 11),
        Text(item.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(item.subtitle,
            style: const TextStyle(fontSize: 10.5, color: _muted)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.person_outline_rounded, size: 16, color: _muted),
          const SizedBox(width: 5),
          Expanded(
            child: Text(item.submittedBy,
                style: const TextStyle(fontSize: 9.5, color: _muted)),
          ),
          if (item.amount != null)
            Text(_money.format(item.amount),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 9),
        InkWell(
          onTap: () => _showApprovalDetails(context, item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.fact_check_outlined, size: 17, color: _royal),
              const SizedBox(width: 7),
              const Expanded(
                child: Text('Review context, impact and evidence',
                    style:
                        TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18, color: _muted),
            ]),
          ),
        ),
        if (pending) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () =>
                  _confirmApprovalDecision(context, item, 'Needs changes'),
              icon: const Icon(Icons.rate_review_outlined, size: 17),
              label: const Text('Request clarification or changes'),
            ),
          ),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _confirmApprovalDecision(context, item, 'Rejected'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: SchoolBrand.primary),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: FilledButton.icon(
                onPressed: () =>
                    _confirmApprovalDecision(context, item, 'Approved'),
                style: FilledButton.styleFrom(backgroundColor: _green),
                icon: const Icon(Icons.done_rounded, size: 18),
                label: const Text('Approve'),
              ),
            ),
          ]),
        ] else ...[
          const SizedBox(height: 12),
          _Pill(
              text: item.status,
              color: item.status == 'Approved' ? _green : SchoolBrand.primary),
        ],
      ]),
    );
  }
}

void _showApprovalDetails(BuildContext context, LeadershipApproval item) {
  final rootContext = context;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: .84,
      minChildSize: .6,
      maxChildSize: .94,
      expand: false,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DCE4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            _Pill(text: item.type, color: _royal),
            const SizedBox(width: 7),
            _Pill(text: '${item.risk} risk', color: SchoolBrand.primary),
          ]),
          const SizedBox(height: 12),
          Text(item.title,
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(item.subtitle,
              style: const TextStyle(fontSize: 11, color: _muted)),
          const SizedBox(height: 18),
          if (item.currentValue != null || item.proposedValue != null)
            Row(children: [
              Expanded(
                child: _DecisionValue(
                  label: 'CURRENT',
                  value: item.currentValue ?? 'Not set',
                  color: _muted,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Icon(Icons.arrow_forward_rounded, color: _royal),
              ),
              Expanded(
                child: _DecisionValue(
                  label: 'PROPOSED',
                  value: item.proposedValue ?? 'Requested',
                  color: _green,
                ),
              ),
            ]),
          const SizedBox(height: 17),
          _ApprovalDetailRow(
              icon: Icons.notes_rounded, label: 'Reason', value: item.reason),
          _ApprovalDetailRow(
              icon: Icons.hub_rounded,
              label: 'Institutional impact',
              value: item.impact),
          _ApprovalDetailRow(
              icon: Icons.gavel_rounded,
              label: 'Why your approval is required',
              value: item.policyTrigger),
          _ApprovalDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Requested by',
              value: '${item.submittedBy} · ${item.timeLabel}'),
          _ApprovalDetailRow(
              icon: Icons.attach_file_rounded,
              label: 'Evidence',
              value:
                  '${item.attachmentCount} supporting attachment${item.attachmentCount == 1 ? '' : 's'}'),
          _ApprovalDetailRow(
              icon: Icons.schedule_rounded,
              label: 'Decision timeline',
              value: item.dueLabel),
          if (item.status == 'Pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _confirmApprovalDecision(rootContext, item, 'Approved');
                },
                style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    minimumSize: const Size.fromHeight(52)),
                icon: const Icon(Icons.verified_rounded),
                label: const Text('Continue to secure decision'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Future<void> _confirmApprovalDecision(
    BuildContext context, LeadershipApproval item, String decision) async {
  final note = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('$decision request?'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          decision == 'Approved'
              ? 'This decision will be recorded against your leadership identity.'
              : 'Add a clear reason so the requesting team knows the next action.',
          style: const TextStyle(fontSize: 11, color: _muted),
        ),
        const SizedBox(height: 13),
        TextField(
          controller: note,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: decision == 'Approved'
                ? 'Decision note (optional)'
                : 'Reason / required changes',
            prefixIcon: const Icon(Icons.edit_note_rounded),
          ),
        ),
        if (item.requiresReauthentication) ...[
          const SizedBox(height: 12),
          const Row(children: [
            Icon(Icons.face_rounded, color: _green, size: 19),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                  'Face ID or device PIN confirmation will protect this decision.',
                  style: TextStyle(fontSize: 9.5, color: _muted)),
            ),
          ]),
        ],
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (decision != 'Approved' && note.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Add a reason for this decision.')));
              return;
            }
            Navigator.pop(dialogContext, true);
          },
          style: FilledButton.styleFrom(
              backgroundColor:
                  decision == 'Approved' ? _green : SchoolBrand.primary),
          child: Text(decision),
        ),
      ],
    ),
  );
  note.dispose();
  if (confirmed == true && context.mounted) {
    context
        .read<LeadershipBloc>()
        .add(LeadershipApprovalDecided(item.id, decision));
  }
}

class _DecisionValue extends StatelessWidget {
  const _DecisionValue(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 7.5, color: color, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _ApprovalDetailRow extends StatelessWidget {
  const _ApprovalDetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEEF3FF),
              child: Icon(icon, color: _royal, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: _muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                      fontSize: 11, height: 1.35, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      );
}

class LeadershipAlertsPage extends StatelessWidget {
  const LeadershipAlertsPage({required this.alerts, super.key});
  final List<LeadershipAlert> alerts;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Priority alerts')),
        body: BlocBuilder<LeadershipBloc, LeadershipState>(
          builder: (context, state) {
            final data = state is LeadershipReady ? state.data.alerts : alerts;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _PageHero(
                  eyebrow: 'ACTION CENTRE',
                  title: 'Risks and exceptions',
                  subtitle:
                      'Only items requiring leadership attention appear here.',
                  icon: Icons.notification_important_rounded,
                ),
                const SizedBox(height: 18),
                ...data.map((alert) => Column(children: [
                      Opacity(
                          opacity: alert.resolved ? .55 : 1,
                          child: _AlertCard(alert: alert)),
                      if (!alert.resolved)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => context
                                .read<LeadershipBloc>()
                                .add(LeadershipAlertResolved(alert.id)),
                            icon: const Icon(Icons.task_alt_rounded, size: 17),
                            label: const Text('Mark resolved'),
                          ),
                        ),
                    ])),
              ],
            );
          },
        ),
      );
}

class LeadershipAnnouncementPage extends StatefulWidget {
  const LeadershipAnnouncementPage({super.key});
  @override
  State<LeadershipAnnouncementPage> createState() =>
      _LeadershipAnnouncementPageState();
}

class _LeadershipAnnouncementPageState
    extends State<LeadershipAnnouncementPage> {
  final title = TextEditingController();
  final message = TextEditingController();
  String audience = 'All parents and staff';

  @override
  void dispose() {
    title.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Publish announcement')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageHero(
              eyebrow: 'OFFICIAL COMMUNICATION',
              title: 'Leadership announcement',
              subtitle:
                  'Publish an authorised update with audience and audit trail.',
              icon: Icons.campaign_rounded,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: audience,
              decoration: const InputDecoration(
                  labelText: 'Audience',
                  prefixIcon: Icon(Icons.groups_rounded)),
              items: const [
                'All parents and staff',
                'All parents',
                'All staff',
                'Senior School',
                'Transport users'
              ]
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => audience = value ?? audience),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: title,
              decoration: const InputDecoration(
                  labelText: 'Announcement title',
                  prefixIcon: Icon(Icons.title_rounded)),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: message,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Official message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                if (title.text.trim().isEmpty || message.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Enter the announcement and message.')));
                  return;
                }
                context.read<LeadershipBloc>().add(
                    LeadershipAnnouncementPublished(
                        title.text.trim(), audience));
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Review and publish'),
            ),
          ],
        ),
      );
}

class LeadershipFinancePage extends StatelessWidget {
  const LeadershipFinancePage({required this.data, super.key});
  final LeadershipSnapshot data;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Finance overview')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHero(
              eyebrow: 'FINANCIAL GOVERNANCE',
              title: _money.format(data.collectedToday),
              subtitle:
                  'Collected today · ${_money.format(data.outstandingFees)} outstanding',
              icon: Icons.account_balance_wallet_rounded,
            ),
            const SizedBox(height: 16),
            const _FinanceBreakdown(
                title: 'Tuition fee',
                collected: 4260000,
                target: 4820000,
                color: _green),
            const _FinanceBreakdown(
                title: 'Transport fee',
                collected: 682000,
                target: 745000,
                color: _royal),
            const _FinanceBreakdown(
                title: 'Activities & annual fee',
                collected: 515000,
                target: 635000,
                color: Color(0xFFE89718)),
            const SizedBox(height: 13),
            const _EmptyPanel(
              icon: Icons.warning_amber_rounded,
              title: '86 overdue accounts',
              message:
                  '₹2.18L is more than 30 days overdue. Collection ownership is assigned to the Accounts Office.',
            ),
          ],
        ),
      );
}

class _FinanceBreakdown extends StatelessWidget {
  const _FinanceBreakdown({
    required this.title,
    required this.collected,
    required this.target,
    required this.color,
  });
  final String title;
  final double collected;
  final double target;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final progress = collected / target;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E9F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w900))),
          Text('${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: color,
            backgroundColor: const Color(0xFFE8ECF2),
          ),
        ),
        const SizedBox(height: 7),
        Text('${_money.format(collected)} of ${_money.format(target)}',
            style: const TextStyle(fontSize: 9.5, color: _muted)),
      ]),
    );
  }
}

class LeadershipAttendancePage extends StatelessWidget {
  const LeadershipAttendancePage({required this.data, super.key});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Attendance overview')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHero(
              eyebrow: 'DAILY PRESENCE',
              title: '${data.studentAttendance}% student attendance',
              subtitle:
                  '${data.staffAttendance}% staff attendance · Updated 09:32 AM',
              icon: Icons.how_to_reg_rounded,
            ),
            const SizedBox(height: 17),
            ...data.attendanceDivisions
                .map((item) => _DivisionAttendanceCard(item: item)),
            const SizedBox(height: 10),
            const _EmptyPanel(
                icon: Icons.access_time_rounded,
                title: '37 late arrivals today',
                message:
                    'Senior School accounts for 19. The discipline team is following up with repeat cases.'),
          ],
        ),
      );
}

class LeadershipAdmissionsPage extends StatelessWidget {
  const LeadershipAdmissionsPage({required this.data, super.key});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Admissions')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHero(
              eyebrow: 'ADMISSION PERFORMANCE',
              title: '${data.admissionConversion}% conversion',
              subtitle:
                  '153 confirmed admissions · 31 offers awaiting response',
              icon: Icons.person_add_alt_1_rounded,
            ),
            const SizedBox(height: 16),
            _AdmissionFunnel(data: data),
            const SizedBox(height: 13),
            const _EmptyPanel(
              icon: Icons.phone_callback_rounded,
              title: '18 inquiries need follow-up',
              message:
                  'Six have had no contact for more than 48 hours. Admission counsellor ownership is visible in the web portal.',
            ),
          ],
        ),
      );
}

class LeadershipStaffPage extends StatelessWidget {
  const LeadershipStaffPage({required this.data, super.key});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Staff & HR')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHero(
              eyebrow: 'PEOPLE OVERVIEW',
              title: '${data.totalStaff} school employees',
              subtitle:
                  '${data.staffAttendance}% present · 4 open positions · 5 requests',
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 16),
            const _StaffRow(
                department: 'Academic staff',
                present: '68/72 present',
                vacancy: '2 vacancies',
                color: _royal),
            const _StaffRow(
                department: 'Administration',
                present: '12/13 present',
                vacancy: '1 vacancy',
                color: _green),
            const _StaffRow(
                department: 'Operations & support',
                present: '10/11 present',
                vacancy: '1 vacancy',
                color: Color(0xFFE89718)),
            const SizedBox(height: 12),
            const _EmptyPanel(
              icon: Icons.event_busy_rounded,
              title: 'Tomorrow’s substitution risk',
              message:
                  'Two faculty leave requests overlap during the first three periods. Timetable adjustment is pending.',
            ),
          ],
        ),
      );
}

class _StaffRow extends StatelessWidget {
  const _StaffRow({
    required this.department,
    required this.present,
    required this.vacancy,
    required this.color,
  });
  final String department;
  final String present;
  final String vacancy;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E9F0))),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: color.withValues(alpha: .1),
              child: Icon(Icons.groups_rounded, color: color)),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(department,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w900)),
              Text(present,
                  style: const TextStyle(fontSize: 9.5, color: _muted)),
            ]),
          ),
          _Pill(text: vacancy, color: color),
        ]),
      );
}

class LeadershipTransportPage extends StatelessWidget {
  const LeadershipTransportPage({required this.data, super.key});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Transport command')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHero(
              eyebrow: 'LIVE TRANSPORT',
              title: '${data.transportOnTime}% routes on time',
              subtitle: '12 active buses · 634 students · 1 delayed route',
              icon: Icons.directions_bus_rounded,
            ),
            const SizedBox(height: 16),
            const _RouteRow(
                route: 'Route 02 · North Zone',
                eta: 'Completed',
                students: '58 students',
                delayed: false),
            const _RouteRow(
                route: 'Route 07 · Lake View',
                eta: '18 min late',
                students: '46 students',
                delayed: true),
            const _RouteRow(
                route: 'Route 11 · Central',
                eta: 'On time',
                students: '61 students',
                delayed: false),
            const SizedBox(height: 12),
            const _EmptyPanel(
              icon: Icons.health_and_safety_rounded,
              title: 'All vehicles safety-cleared',
              message:
                  'GPS, driver documents, insurance and maintenance checks are current. Route 7 delay is being monitored.',
            ),
          ],
        ),
      );
}

class _RouteRow extends StatelessWidget {
  const _RouteRow(
      {required this.route,
      required this.eta,
      required this.students,
      required this.delayed});
  final String route;
  final String eta;
  final String students;
  final bool delayed;
  @override
  Widget build(BuildContext context) {
    final color = delayed ? SchoolBrand.primary : _green;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E9F0))),
      child: Row(children: [
        CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(Icons.directions_bus_filled_rounded, color: color)),
        const SizedBox(width: 11),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(route,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
          Text(students, style: const TextStyle(fontSize: 9.5, color: _muted)),
        ])),
        _Pill(text: eta, color: color),
      ]),
    );
  }
}

class LeadershipBranchesPage extends StatelessWidget {
  const LeadershipBranchesPage({required this.branches, super.key});
  final List<LeadershipBranchInsight> branches;

  @override
  Widget build(BuildContext context) {
    final ordered = [...branches]..sort((a, b) => b.health.compareTo(a.health));
    return Scaffold(
      appBar: AppBar(title: const Text('Branch performance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PageHero(
            eyebrow: 'MULTI-BRANCH GOVERNANCE',
            title: 'Campus comparison',
            subtitle:
                'Ranked view of school health, attendance, collections and academic risk.',
            icon: Icons.account_tree_rounded,
          ),
          const SizedBox(height: 18),
          ...ordered.asMap().entries.map((entry) {
            final item = entry.value;
            final color = item.health >= 88
                ? _green
                : item.health >= 84
                    ? const Color(0xFFE89718)
                    : SchoolBrand.primary;
            return Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E9F0)),
              ),
              child: Column(children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: .1),
                    child: Text('${entry.key + 1}',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900)),
                  ),
                  _Pill(text: 'Health ${item.health}', color: color),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: _MiniValue(
                          label: 'Attendance',
                          value: '${item.attendance}%',
                          color: _royal)),
                  Expanded(
                      child: _MiniValue(
                          label: 'Collection',
                          value: '${item.collectionProgress}%',
                          color: _green)),
                  Expanded(
                      child: _MiniValue(
                          label: 'Academic risk',
                          value: '${item.academicRisk}',
                          color: SchoolBrand.primary)),
                  Expanded(
                      child: _MiniValue(
                          label: 'Open alerts',
                          value: '${item.openAlerts}',
                          color: const Color(0xFFE89718))),
                ]),
              ]),
            );
          }),
          const _EmptyPanel(
            icon: Icons.auto_awesome_rounded,
            title: 'Leadership recommendation',
            message:
                'North Campus needs a collection and academic intervention review this week. Main Campus can share its follow-up playbook.',
          ),
        ],
      ),
    );
  }
}

class LeadershipCalendarPage extends StatelessWidget {
  const LeadershipCalendarPage({required this.events, super.key});
  final List<LeadershipCalendarEvent> events;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Leadership calendar')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageHero(
                eyebrow: 'TODAY’S AGENDA',
                title: '3 leadership commitments',
                subtitle: 'Tuesday · 18 August · Main Campus',
                icon: Icons.calendar_month_rounded),
            const SizedBox(height: 16),
            ...events.map((event) => _CalendarCard(event: event)),
          ],
        ),
      );
}

class LeadershipReportsPage extends StatelessWidget {
  const LeadershipReportsPage({required this.data, super.key});
  final LeadershipSnapshot data;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Executive reports')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _PageHero(
                eyebrow: 'BOARD-READY INFORMATION',
                title: 'Reports & exports',
                subtitle: 'Verified summaries generated from the school ERP.',
                icon: Icons.analytics_rounded),
            const SizedBox(height: 16),
            const _ReportRow(
                icon: Icons.health_and_safety_rounded,
                title: 'Daily school health brief',
                subtitle: 'Attendance, risks, finance and operations'),
            const _ReportRow(
                icon: Icons.school_rounded,
                title: 'Academic performance report',
                subtitle: 'Grades, subjects, trends and interventions'),
            const _ReportRow(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Fee collection report',
                subtitle: 'Collection, aging and outstanding accounts'),
            const _ReportRow(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Admission conversion report',
                subtitle: 'Funnel, counsellors and pending follow-ups'),
            const _ReportRow(
                icon: Icons.badge_rounded,
                title: 'Staff attendance & leave',
                subtitle: 'Presence, substitutions and department load'),
            const _ReportRow(
                icon: Icons.account_tree_rounded,
                title: 'Branch performance pack',
                subtitle: 'Health, attendance, finance and risk comparison'),
            const _ReportRow(
                icon: Icons.directions_bus_rounded,
                title: 'Transport safety report',
                subtitle: 'Route punctuality, incidents and compliance'),
            const _ReportRow(
                icon: Icons.support_agent_rounded,
                title: 'Parent service & SLA report',
                subtitle: 'Concerns, ownership, response and resolution'),
            const _ReportRow(
                icon: Icons.history_rounded,
                title: 'Leadership decision audit',
                subtitle: 'Approvals, rejections, notes and delegated actions'),
          ],
        ),
      );
}

class _ReportRow extends StatelessWidget {
  const _ReportRow(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: const Color(0xFFEEF3FF),
              child: Icon(icon, color: _royal)),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 9.5, color: _muted)),
          trailing: IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title prepared for download'))),
              icon: const Icon(Icons.download_rounded)),
        ),
      );
}

class LeadershipSettingsPage extends StatelessWidget {
  const LeadershipSettingsPage({required this.profile, super.key});
  final LeadershipProfile profile;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Leadership settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_midnight, Color(0xFF6A3B45)]),
                  borderRadius: BorderRadius.circular(23)),
              child: Row(children: [
                const CircleAvatar(
                    radius: 29,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFFFFD36B), size: 29)),
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
                      Text('${profile.designation} · ${profile.campus}',
                          style: const TextStyle(
                              color: Color(0xFFCDD6E7), fontSize: 10)),
                    ])),
              ]),
            ),
            const SizedBox(height: 16),
            const _SettingsRow(
                icon: Icons.person_outline_rounded,
                title: 'Leadership profile',
                subtitle: 'Identity and authorised campus access'),
            const _SettingsRow(
                icon: Icons.notifications_outlined,
                title: 'Executive alerts',
                subtitle: 'Risk, approvals and daily brief'),
            const _SettingsRow(
                icon: Icons.supervisor_account_outlined,
                title: 'Delegation',
                subtitle: 'Temporary approval delegation'),
            const _SettingsRow(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & security',
                subtitle: 'Device, biometrics and session controls'),
            const _SettingsRow(
                icon: Icons.history_rounded,
                title: 'Leadership audit log',
                subtitle: 'Approvals and decisions'),
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          leading: Icon(icon, color: _royal),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 9.5, color: _muted)),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}

class LeadershipGenericPage extends StatelessWidget {
  const LeadershipGenericPage(
      {required this.title,
      required this.icon,
      required this.headline,
      required this.detail,
      super.key});
  final String title;
  final IconData icon;
  final String headline;
  final String detail;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _PageHero(
              eyebrow: 'LEADERSHIP WORKSPACE',
              title: headline,
              subtitle: detail,
              icon: icon),
        ),
      );
}

class _PageHero extends StatelessWidget {
  const _PageHero(
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
              colors: [_midnight, Color(0xFF344C82)]),
          borderRadius: BorderRadius.circular(23),
          boxShadow: const [
            BoxShadow(
                color: Color(0x28101A35), blurRadius: 20, offset: Offset(0, 9))
          ],
        ),
        child: Row(children: [
          Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: const Color(0xFFFFD36B), size: 27)),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(eyebrow,
                    style: const TextStyle(
                        color: Color(0xFFBFCBE2),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8)),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFFD4DCEC),
                        fontSize: 10.5,
                        height: 1.35)),
              ])),
        ]),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
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

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel(
      {required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F0))),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: const Color(0xFFEEF3FF),
              child: Icon(icon, color: _royal)),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(message,
                    style: const TextStyle(
                        fontSize: 9.5, height: 1.4, color: _muted)),
              ])),
        ]),
      );
}

IconData _domainIcon(String domain) => switch (domain) {
      'Academics' => Icons.school_rounded,
      'Finance' => Icons.account_balance_wallet_rounded,
      'Transport' => Icons.directions_bus_rounded,
      'Staff' => Icons.badge_rounded,
      'Admissions' => Icons.person_add_alt_1_rounded,
      'Service' => Icons.support_agent_rounded,
      'Security' => Icons.security_rounded,
      _ => Icons.warning_amber_rounded,
    };

String _compactMoney(double amount) {
  if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)}L';
  if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(0)}K';
  return _money.format(amount);
}

void _open(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}
