import 'package:flutter/material.dart';
import 'models/product_task_module.dart';
import 'widgets/product_task_card.dart';
import '../createProjectPage/models/project.dart';
import '../../widgets/analytics_dashboard.dart';
import '../../widgets/menu_button.dart';
import '../../widgets/navigation_drawer.dart';

class ProductTaskPage extends StatefulWidget {
  final Project project;

  final int initialTab;

  const ProductTaskPage({
    super.key,
    required this.project,
    this.initialTab = 1,
  });

  @override
  State<ProductTaskPage> createState() => _ProductTaskPageState();
}

class _ProductTaskPageState extends State<ProductTaskPage> {
  late int _selectedTab; // seeded from widget.initialTab in initState

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab; // tab content swaps inline, no navigation needed
  }

  void _refresh() => setState(() {});

  // ── Opens the "Create New Task" bottom sheet ──────────────────
  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets sheet resize when keyboard opens
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreateTaskSheet(
        groups: widget.project.groups, // pass project groups into the sheet
        onCreated: (newTask) {
          // Add the new task to THIS project's task list and rebuild
          setState(() => widget.project.tasks.add(newTask));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      // Shared app-wide drawer — MenuButton opens this by default
      endDrawer: CustomNavigationDrawer(activePage: widget.project.title),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White background covers the header + tab bar section
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  _buildTabBar(),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                ],
              ),
            ),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project title comes from widget.project, not hard-coded
                Text(
                  widget.project.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text('${widget.project.memberCount} members',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          // Builder gives MenuButton context
          Builder(
            builder: (context) => MenuButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(height: 8), // bottom breathing room before divider
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Overview', 'Tasks', 'Analytics'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index    = entry.key;
          final label    = entry.value;
          final selected = _selectedTab == index;
          return GestureDetector(
            onTap: () => _handleTabTap(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? Colors.black87 : Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: selected ? label.length * 7.0 : 0,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Switch between tabs
  void _handleTabTap(int index) {
    setState(() => _selectedTab = index);
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:  return _buildOverviewTab();
      case 1:  return _buildTasksTab();
      case 2:  return _buildAnalyticsTab();
      default: return _buildTasksTab();
    }
  }

  Widget _buildTasksTab() {
    final tasks = widget.project.tasks; // this project's tasks only
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: tasks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildCreateButton();
        return ProductTaskCard(
            task: tasks[index - 1], onUpdate: _refresh);
      },
    );
  }

  // ── Overview tab content — same cards as ProjectOverviewScreen's
  Widget _buildOverviewTab() {
    final project      = widget.project;
    final totalHours   = project.tasks.fold<double>(0, (sum, t) => sum + t.spentHours);
    final inProgress   = project.tasks.where((t) => t.status == 'In Progress').length;
    final progressPct  = (project.progress * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2x2 stat grid: Progress, Completed, Time Spent, In Progress
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _overviewStatCard(
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFF2979FF),
                iconBg: const Color(0xFFE3EDFF),
                label: 'Progress',
                value: '$progressPct%',
              ),
              _overviewStatCard(
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF00C48C),
                iconBg: const Color(0xFFE0F7F1),
                label: 'Completed',
                value: '${project.tasksDone}/${project.totalTasks}',
              ),
              _overviewStatCard(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFFF9F43),
                iconBg: const Color(0xFFFFF3E0),
                label: 'Time Spent',
                value: '${totalHours.round()}h',
              ),
              _overviewStatCard(
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF9B59B6),
                iconBg: const Color(0xFFF3E5F5),
                label: 'In Progress',
                value: '$inProgress',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Timeline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Start',
                        style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                    Text(
                      project.deadline != null
                          ? '${project.deadline!.day}/${project.deadline!.month}'
                          : 'No deadline',
                      style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: const Color(0xFFEEEFF4),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2979FF)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('$progressPct% complete',
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _overviewStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Analytics tab content —
  Widget _buildAnalyticsTab() {
    final project     = widget.project;
    final total       = project.totalTasks;
    final completed   = project.tasksDone;
    final inProgress  = project.tasks.where((t) => t.status == 'In Progress').length;
    final pending     = total - completed - inProgress;
    final totalHours  = project.tasks.fold<double>(0, (sum, t) => sum + t.spentHours);

    return AnalyticsDashboard(
      totalTasks: total,
      completedTasks: completed,
      inProgressTasks: inProgress,
      pendingTasks: pending < 0 ? 0 : pending,
      completionRate: total == 0 ? 0 : (completed / total) * 100,
      totalHours: totalHours.round(),
    );
  }

  // Tapping this now calls _openCreateSheet
  Widget _buildCreateButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openCreateSheet, // ← wired up here
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add,
                      color: Color(0xFF6366F1), size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Create New Task',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Create Task Bottom Sheet ──────────────────────────────────────
class _CreateTaskSheet extends StatefulWidget {
  final ValueChanged<ProductTask> onCreated;
  final List<TaskGroup> groups;

  const _CreateTaskSheet({required this.onCreated, required this.groups});

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {

  // Form fields
  final _titleController         = TextEditingController();
  final _descriptionController   = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  String   _selectedPriority     = 'Medium';
  DateTime _dueDateTime          = DateTime.now().add(const Duration(days: 7));
  TaskGroup? _selectedGroup;     // optional group picked from the project's groups

  static const List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':   return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF59E0B);
      default:       return const Color(0xFF6B7280);
    }
  }

  // Formats DateTime → "Apr 5"
  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}';
  }

  // Formats DateTime → "2:30 PM"
  String _formatTime(DateTime dt) {
    final h      = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min    = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$min $period';
  }

  // Opens date picker then time picker back-to-back
  Future<void> _pickDueDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDateTime),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _dueDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // Parses "2h", "30m", "1h 30m" into a numeric hour value for the progress bar
  double _parseEstimatedHours(String input) {
    final trimmed = input.trim().toLowerCase();
    if (trimmed.isEmpty) return 0;
    double total = 0;
    // Match hours — e.g. "2h" or "1h"
    final hoursMatch = RegExp(r'(\d+(\.\d+)?)h').firstMatch(trimmed);
    if (hoursMatch != null) total += double.parse(hoursMatch.group(1)!);
    // Match minutes — e.g. "30m"
    final minsMatch = RegExp(r'(\d+)m').firstMatch(trimmed);
    if (minsMatch != null) total += int.parse(minsMatch.group(1)!) / 60;
    return total;
  }

  // Validates and creates the task
  void _submit() {
    if (_titleController.text.trim().isEmpty) return; // title is required

    final estText  = _estimatedTimeController.text.trim();
    final estHours = _parseEstimatedHours(estText);

    final newTask = ProductTask(
      title:          _titleController.text.trim(),
      description:    _descriptionController.text.trim(),
      dueDate:        _formatDate(_dueDateTime),
      dueTime:        _formatTime(_dueDateTime),
      status:         'To Do',
      priority:       _selectedPriority,
      progress:       0.0,
      estimatedTime:  estText,    // human-readable string shown as chip
      estimatedHours: estHours,   // numeric value used for the progress bar
      group:          _selectedGroup, // attach the picked group, if any
      checklist:      [],
    );

    widget.onCreated(newTask); // pass back to the page
    Navigator.pop(context);   // close the sheet
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sheet rises above the keyboard automatically
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Sheet handle + title ──
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Create New Task',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            const SizedBox(height: 24),

            // ── Task name ──
            _fieldLabel('Task Name *'),
            const SizedBox(height: 8),
            _textField(
              controller: _titleController,
              hint: 'e.g. Design onboarding flow',
            ),
            const SizedBox(height: 16),

            // ── Description ──
            _fieldLabel('Description'),
            const SizedBox(height: 8),
            _textField(
              controller: _descriptionController,
              hint: 'What needs to be done?',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ── Due date & time ──
            _fieldLabel('Due Date & Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDueDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Text(
                      '${_formatDate(_dueDateTime)}  ·  ${_formatTime(_dueDateTime)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2563EB)),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Priority ──
            _fieldLabel('Priority'),
            const SizedBox(height: 8),
            Row(
              children: _priorityOptions.map((p) {
                final isSelected = _selectedPriority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _priorityColor(p)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(p,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black54)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Group picker — only shown if the project has groups ──
            if (widget.groups.isNotEmpty) ...[
              _fieldLabel('Group'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.groups.map((g) {
                  final isSelected = _selectedGroup?.name == g.name;
                  return GestureDetector(
                    onTap: () => setState(() =>
                    _selectedGroup = isSelected ? null : g), // tap again to deselect
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? g.color.withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? g.color : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: g.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(g.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? g.color : Colors.black54)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ── Estimated time ──
            _fieldLabel('Estimated Time'),
            const SizedBox(height: 4),
            Text('e.g. 30m, 2h, 1h 30m',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            const SizedBox(height: 8),
            _textField(
              controller: _estimatedTimeController,
              hint: 'e.g. 2h',
            ),
            const SizedBox(height: 28),

            // ── Create button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Create',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shared label style above each field
  Widget _fieldLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151)));
  }

  // Shared text field style
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}