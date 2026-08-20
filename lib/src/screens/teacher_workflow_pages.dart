import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../models/teacher_models.dart';
import '../school_brand.dart';
import '../state/teacher_bloc.dart';

const _navy = Color(0xFF10203F);
const _blue = SchoolBrand.teacherAccent;
const _muted = Color(0xFF68758A);
const _green = Color(0xFF00A878);
final _dateFormat = DateFormat('dd MMM yyyy');

class TeacherHomeworkWorkspacePage extends StatefulWidget {
  const TeacherHomeworkWorkspacePage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  State<TeacherHomeworkWorkspacePage> createState() =>
      _TeacherHomeworkWorkspacePageState();
}

class _TeacherHomeworkWorkspacePageState
    extends State<TeacherHomeworkWorkspacePage> {
  late String classId = widget.data.classes.first.id;
  late String subject = widget.data.classes.first.subjects.first;
  final title = TextEditingController();
  final instructions = TextEditingController();
  DateTime dueDate = DateTime.now().add(const Duration(days: 2));
  List<String> attachments = [];

  TeacherClass get selectedClass =>
      widget.data.classes.firstWhere((item) => item.id == classId);

  @override
  void dispose() {
    title.dispose();
    instructions.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result == null) return;
    setState(() {
      attachments = {
        ...attachments,
        ...result.files.map((file) => file.name),
      }.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assign homework')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _WorkflowHero(
              eyebrow: 'MULTI-SUBJECT WORKSPACE',
              title: 'Create class homework',
              subtitle:
                  'Choose the class first, then publish under the correct assigned subject.',
              icon: Icons.assignment_add,
            ),
            const SizedBox(height: 18),
            const _FormLabel('Class'),
            const SizedBox(height: 7),
            DropdownButtonFormField<String>(
              initialValue: classId,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.groups_rounded),
              ),
              items: widget.data.classes
                  .map((item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  classId = value;
                  subject = selectedClass.subjects.first;
                });
              },
            ),
            const SizedBox(height: 14),
            const _FormLabel('Subject taught by you in this class'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedClass.subjects
                  .map((item) => ChoiceChip(
                        label: Text(item),
                        selected: subject == item,
                        avatar: Icon(
                          item == 'Mathematics'
                              ? Icons.calculate_rounded
                              : Icons.science_rounded,
                          size: 17,
                          color: subject == item ? Colors.white : _blue,
                        ),
                        onSelected: (_) => setState(() => subject = item),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: title,
              decoration: const InputDecoration(
                labelText: 'Homework title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 13),
            TextField(
              controller: instructions,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Instructions and expected outcome',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 13),
            _DateSelector(
              label: 'Submission due date',
              date: dueDate,
              onTap: () async {
                final value = await showDatePicker(
                  context: context,
                  initialDate: dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 120)),
                );
                if (value != null) setState(() => dueDate = value);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1E5EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Learning attachments',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900)),
                          SizedBox(height: 2),
                          Text('PDF, image or document · up to 5 files',
                              style: TextStyle(fontSize: 10, color: _muted)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickAttachments,
                      icon: const Icon(Icons.attach_file_rounded, size: 18),
                      label: const Text('Add files'),
                    ),
                  ]),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...attachments.map((name) => Container(
                          margin: const EdgeInsets.only(top: 7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5FC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            const Icon(Icons.description_outlined,
                                color: _blue, size: 19),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () =>
                                  setState(() => attachments.remove(name)),
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                          ]),
                        )),
                  ],
                ],
              ),
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
                      subject: subject,
                      title: title.text.trim(),
                      instructions: instructions.text.trim(),
                      dueDate: dueDate,
                      attachmentNames: attachments,
                    ));
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
              icon: const Icon(Icons.send_rounded),
              label: Text('Publish $subject homework'),
            ),
          ],
        ),
      );
}

class DynamicTeacherTimetablePage extends StatefulWidget {
  const DynamicTeacherTimetablePage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  State<DynamicTeacherTimetablePage> createState() =>
      _DynamicTeacherTimetablePageState();
}

class _DynamicTeacherTimetablePageState
    extends State<DynamicTeacherTimetablePage> {
  late DateTime selectedDate = DateUtils.dateOnly(DateTime.now());

  List<DateTime> get week {
    final monday =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final periods = widget.data.periods
        .where((item) => item.weekday == selectedDate.weekday)
        .toList()
      ..sort((a, b) => a.period.compareTo(b.period));
    final classCount = periods.map((item) => item.classId).toSet().length;
    final subjectCount = periods.map((item) => item.subject).toSet().length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My timetable'),
        actions: [
          IconButton(
            onPressed: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 180)),
                lastDate: DateTime.now().add(const Duration(days: 180)),
              );
              if (value != null) setState(() => selectedDate = value);
            },
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _WorkflowHero(
            eyebrow: 'DYNAMIC TEACHING SCHEDULE',
            title: DateFormat('EEEE, dd MMMM').format(selectedDate),
            subtitle:
                '${periods.length} periods · $classCount classes · $subjectCount subjects',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: week.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = week[index];
                final selected = DateUtils.isSameDay(date, selectedDate);
                return InkWell(
                  onTap: () => setState(() => selectedDate = date),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 54,
                    decoration: BoxDecoration(
                      color: selected ? _blue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected ? _blue : const Color(0xFFE1E5EC)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('EEE').format(date).toUpperCase(),
                            style: TextStyle(
                                color: selected ? Colors.white70 : _muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 5),
                        Text('${date.day}',
                            style: TextStyle(
                                color: selected ? Colors.white : _navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (periods.isEmpty)
            const _EmptyState(
              icon: Icons.free_breakfast_rounded,
              title: 'No teaching periods',
              message: 'There are no assigned classes for this day.',
            )
          else
            ...periods.map((period) => _DynamicPeriodCard(period: period)),
        ],
      ),
    );
  }
}

class _DynamicPeriodCard extends StatelessWidget {
  const _DynamicPeriodCard({required this.period});
  final TeacherPeriod period;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E5EC)),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 62,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('PERIOD',
                  style: TextStyle(
                      color: _muted,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800)),
              Text('${period.period}',
                  style: const TextStyle(
                      color: _blue, fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(period.subject,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(period.classLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _blue,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(
                  '${period.startTime} – ${period.endTime}  ·  ${period.room}',
                  style: const TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _muted),
        ]),
      );
}

class AdvancedStudentInsightsPage extends StatefulWidget {
  const AdvancedStudentInsightsPage({required this.data, super.key});
  final TeacherSnapshot data;

  @override
  State<AdvancedStudentInsightsPage> createState() =>
      _AdvancedStudentInsightsPageState();
}

class _AdvancedStudentInsightsPageState
    extends State<AdvancedStudentInsightsPage> {
  late String classId;

  @override
  void initState() {
    super.initState();
    final ranked = [...widget.data.classes]
      ..sort((a, b) => _supportCount(b.id).compareTo(_supportCount(a.id)));
    classId = ranked.first.id;
  }

  int _supportCount(String targetClassId) => widget.data.students
      .where((student) =>
          student.classId == targetClassId &&
          (student.status == 'Needs support' ||
              student.performance < 65 ||
              student.attendance < 75))
      .length;

  @override
  Widget build(BuildContext context) {
    final ranked = [...widget.data.classes]
      ..sort((a, b) => _supportCount(b.id).compareTo(_supportCount(a.id)));
    final priorityClass = ranked.first;
    final selectedClass =
        widget.data.classes.firstWhere((item) => item.id == classId);
    final students = widget.data.students
        .where((student) => student.classId == classId)
        .toList()
      ..sort((a, b) => a.performance.compareTo(b.performance));
    final average = students.isEmpty
        ? 0.0
        : students.map((item) => item.performance).reduce((a, b) => a + b) /
            students.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Student insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_navy, Color(0xFF71333D)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD66B), size: 19),
                  SizedBox(width: 7),
                  Text('CLASS NEEDING MOST SUPPORT',
                      style: TextStyle(
                          color: Color(0xFFD8DFEC),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8)),
                ]),
                const SizedBox(height: 13),
                Text(priorityClass.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  '${_supportCount(priorityClass.id)} students need your attention across ${priorityClass.subjects.join(' and ')}.',
                  style: const TextStyle(
                      color: Color(0xFFD8DFEC), fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FormLabel('Select assigned class'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: classId,
            decoration:
                const InputDecoration(prefixIcon: Icon(Icons.groups_rounded)),
            items: widget.data.classes
                .map((item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                          '${item.label} · ${_supportCount(item.id)} need support'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => classId = value ?? classId),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _InsightMetric(
                label: 'Class average',
                value: '${average.toStringAsFixed(1)}%',
                color: _blue,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _InsightMetric(
                label: 'Need support',
                value: '${_supportCount(classId)}',
                color: SchoolBrand.primary,
              ),
            ),
          ]),
          const SizedBox(height: 18),
          Text('${selectedClass.label} performance',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('Subjects: ${selectedClass.subjects.join(' · ')}',
              style: const TextStyle(fontSize: 10.5, color: _muted)),
          const SizedBox(height: 11),
          ...students.map((student) => _PerformanceStudentCard(
                student: student,
                subjects: selectedClass.subjects,
              )),
        ],
      ),
    );
  }
}

class _PerformanceStudentCard extends StatelessWidget {
  const _PerformanceStudentCard(
      {required this.student, required this.subjects});
  final TeacherStudent student;
  final List<String> subjects;

  @override
  Widget build(BuildContext context) {
    final needsSupport = student.status == 'Needs support' ||
        student.performance < 65 ||
        student.attendance < 75;
    final color = needsSupport ? SchoolBrand.primary : _green;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE1E5EC)),
      ),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .1),
            child: Text(student.name.substring(0, 1),
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900)),
                Text('Roll ${student.roll} · Attendance ${student.attendance}%',
                    style: const TextStyle(fontSize: 9.5, color: _muted)),
              ],
            ),
          ),
          _StatusTag(
              text: needsSupport ? 'Needs help' : student.status, color: color),
        ]),
        const SizedBox(height: 12),
        ...subjects.map((subject) {
          final score = student.subjectScores[subject] ?? student.performance;
          final scoreColor = score < 65 ? SchoolBrand.primary : _blue;
          return Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Row(children: [
              SizedBox(
                width: 118,
                child: Text(subject,
                    style: const TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8ECF2),
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 35,
                child: Text('${score.round()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 10.5,
                        color: scoreColor,
                        fontWeight: FontWeight.w900)),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

class TeacherLessonPlansPage extends StatelessWidget {
  const TeacherLessonPlansPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lesson plans')),
        body: BlocBuilder<TeacherBloc, TeacherState>(
          builder: (context, state) {
            if (state is! TeacherReady) {
              return const Center(child: CircularProgressIndicator());
            }
            final plans = state.data.lessonPlans;
            final active = plans
                .where((plan) =>
                    plan.status == 'Today' || plan.status == 'In progress')
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _WorkflowHero(
                  eyebrow: 'ADMIN-ASSIGNED CURRICULUM',
                  title: 'Today’s teaching plan',
                  subtitle:
                      '${active.length} active plans · ${plans.where((plan) => plan.status == 'Completed').length} completed',
                  icon: Icons.menu_book_rounded,
                ),
                const SizedBox(height: 18),
                if (active.isEmpty)
                  const _EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'Today’s plans are complete',
                    message: 'Upcoming plans remain visible below.',
                  )
                else ...[
                  const _FormLabel('Assigned for today'),
                  const SizedBox(height: 9),
                  ...active.map((plan) => _LessonPlanCard(plan: plan)),
                ],
                const SizedBox(height: 14),
                const _FormLabel('Timeline and upcoming plans'),
                const SizedBox(height: 9),
                ...plans
                    .where((plan) => !active.contains(plan))
                    .map((plan) => _LessonPlanCard(plan: plan)),
              ],
            );
          },
        ),
      );
}

class _LessonPlanCard extends StatelessWidget {
  const _LessonPlanCard({required this.plan});
  final TeacherLessonPlan plan;

  @override
  Widget build(BuildContext context) {
    final complete = plan.status == 'Completed';
    final color = complete
        ? _green
        : plan.status == 'Upcoming'
            ? _blue
            : const Color(0xFFE89718);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E5EC)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _StatusTag(text: plan.status, color: color),
          const Spacer(),
          Text(plan.periodLabel,
              style: const TextStyle(fontSize: 9.5, color: _muted)),
        ]),
        const SizedBox(height: 11),
        Text(plan.lesson,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('${plan.classLabel} · ${plan.subject}',
            style: const TextStyle(
                fontSize: 10.5, color: _blue, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        Text(plan.objective,
            style: const TextStyle(fontSize: 10.5, color: _muted, height: 1.4)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.timeline_rounded, size: 17, color: _muted),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${_dateFormat.format(plan.startDate)} – ${_dateFormat.format(plan.endDate)}',
              style: const TextStyle(fontSize: 10, color: _muted),
            ),
          ),
          if (!complete && plan.status != 'Upcoming')
            FilledButton.icon(
              onPressed: () => context
                  .read<TeacherBloc>()
                  .add(TeacherLessonPlanCompleted(plan.id)),
              icon: const Icon(Icons.done_rounded, size: 17),
              label: const Text('Mark complete'),
            ),
        ]),
      ]),
    );
  }
}

class TeacherLeavePage extends StatefulWidget {
  const TeacherLeavePage({super.key});

  @override
  State<TeacherLeavePage> createState() => _TeacherLeavePageState();
}

class _TeacherLeavePageState extends State<TeacherLeavePage> {
  String type = 'Casual leave';
  DateTime from =
      DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  DateTime to = DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  final reason = TextEditingController();
  String? attachment;

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> _selectRange() async {
    final value = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: from, end: to),
    );
    if (value != null) {
      setState(() {
        from = value.start;
        to = value.end;
      });
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => attachment = result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Staff leave')),
        body: BlocBuilder<TeacherBloc, TeacherState>(
          builder: (context, state) {
            if (state is! TeacherReady) {
              return const Center(child: CircularProgressIndicator());
            }
            final requests = state.data.leaveRequests;
            final pending =
                requests.where((item) => item.status == 'Pending').length;
            final approved =
                requests.where((item) => item.status == 'Approved').length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                const _WorkflowHero(
                  eyebrow: 'STAFF SELF-SERVICE',
                  title: '8 leave days available',
                  subtitle:
                      'Apply with dates, reason and supporting documents. Administration will review it.',
                  icon: Icons.beach_access_rounded,
                ),
                const SizedBox(height: 14),
                Row(children: [
                  const Expanded(
                      child: _InsightMetric(
                          label: 'Available', value: '8 days', color: _green)),
                  const SizedBox(width: 9),
                  Expanded(
                      child: _InsightMetric(
                          label: 'Pending',
                          value: '$pending',
                          color: const Color(0xFFE89718))),
                  const SizedBox(width: 9),
                  Expanded(
                      child: _InsightMetric(
                          label: 'Approved', value: '$approved', color: _blue)),
                ]),
                const SizedBox(height: 20),
                const _FormLabel('New leave request'),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(
                      labelText: 'Leave type',
                      prefixIcon: Icon(Icons.category_outlined)),
                  items: const [
                    'Casual leave',
                    'Medical leave',
                    'Earned leave',
                    'Emergency leave'
                  ]
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => type = value ?? type),
                ),
                const SizedBox(height: 12),
                _DateSelector(
                  label: '${to.difference(from).inDays + 1} leave day(s)',
                  date: from,
                  endDate: to,
                  onTap: _selectRange,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reason,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Reason for leave',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickAttachment,
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  icon: const Icon(Icons.attach_file_rounded),
                  label: Text(attachment ?? 'Attach supporting document'),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    if (reason.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please enter a reason for leave.')));
                      return;
                    }
                    final request = TeacherLeaveRequest(
                      id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
                      type: type,
                      from: from,
                      to: to,
                      reason: reason.text.trim(),
                      status: 'Pending',
                      attachmentName: attachment,
                    );
                    context
                        .read<TeacherBloc>()
                        .add(TeacherLeaveSubmitted(request));
                    reason.clear();
                    setState(() => attachment = null);
                  },
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit leave request'),
                ),
                const SizedBox(height: 24),
                const _FormLabel('Request history'),
                const SizedBox(height: 9),
                ...requests
                    .map((request) => _LeaveHistoryCard(request: request)),
              ],
            );
          },
        ),
      );
}

class _LeaveHistoryCard extends StatelessWidget {
  const _LeaveHistoryCard({required this.request});
  final TeacherLeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final color = request.status == 'Approved'
        ? _green
        : request.status == 'Rejected'
            ? SchoolBrand.primary
            : const Color(0xFFE89718);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E5EC)),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13)),
          child: Icon(Icons.event_available_rounded, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.type,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(
                '${_dateFormat.format(request.from)} – ${_dateFormat.format(request.to)} · ${request.days} day(s)',
                style: const TextStyle(fontSize: 9.5, color: _muted),
              ),
              if (request.attachmentName != null)
                Text('Attachment: ${request.attachmentName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: _blue)),
            ],
          ),
        ),
        _StatusTag(text: request.status, color: color),
      ]),
    );
  }
}

class _WorkflowHero extends StatelessWidget {
  const _WorkflowHero({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
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
          borderRadius: BorderRadius.circular(23),
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow,
                    style: const TextStyle(
                        color: Color(0xFFB8C9E6),
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
                        color: Color(0xFFD1DBEC),
                        fontSize: 10.5,
                        height: 1.35)),
              ],
            ),
          ),
        ]),
      );
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
    this.endDate,
  });
  final String label;
  final DateTime date;
  final DateTime? endDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFFE1E5EC))),
        leading: const Icon(Icons.event_rounded, color: _blue),
        title: Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
        subtitle: Text(
          endDate == null
              ? _dateFormat.format(date)
              : '${_dateFormat.format(date)} – ${_dateFormat.format(endDate!)}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        trailing: const Icon(Icons.edit_calendar_rounded),
        onTap: onTap,
      );
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: .14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9.5, color: _muted)),
          ],
        ),
      );
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.text, required this.color});
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

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE1E5EC))),
        child: Column(children: [
          Icon(icon, color: _blue, size: 38),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: _muted)),
        ]),
      );
}
