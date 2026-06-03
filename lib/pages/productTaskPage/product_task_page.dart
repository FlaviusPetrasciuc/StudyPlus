import 'package:flutter/material.dart';
import 'models/product_task_module.dart';
import 'widgets/product_task_card.dart';

class ProductTaskPage extends StatefulWidget {
  const ProductTaskPage({super.key});

  @override
  State<ProductTaskPage> createState() => _ProductTaskPageState();
}

class _ProductTaskPageState extends State<ProductTaskPage> {
  int _selectedTab = 1; // 0=Overview, 1=Tasks, 2=Analytics

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
        onCreated: (newTask) {
          // Add the new task to the list and rebuild the page
          setState(() => fakeProductTasks.add(newTask));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Launch Q2 2026',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text('6 team members',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFF2563EB), shape: BoxShape.circle),
            child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
          ),
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
            onTap: () => setState(() => _selectedTab = index),
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

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:  return _buildPlaceholder(Icons.bar_chart_rounded, 'Overview coming soon');
      case 1:  return _buildTasksTab();
      case 2:  return _buildPlaceholder(Icons.pie_chart_outline_rounded, 'Analytics coming soon');
      default: return _buildTasksTab();
    }
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: fakeProductTasks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildCreateButton();
        return ProductTaskCard(
            task: fakeProductTasks[index - 1], onUpdate: _refresh);
      },
    );
  }

  Widget _buildPlaceholder(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
        ],
      ),
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
// A self-contained widget so its own setState doesn't rebuild the whole page
class _CreateTaskSheet extends StatefulWidget {
  final ValueChanged<ProductTask> onCreated;
  const _CreateTaskSheet({required this.onCreated});

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {

  // Form fields
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  String  _selectedPriority    = 'Medium';
  DateTime _dueDateTime        = DateTime.now().add(const Duration(days: 7));

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

  // Validates and creates the task
  void _submit() {
    if (_titleController.text.trim().isEmpty) return; // title is required

    final newTask = ProductTask(
      title:       _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate:     _formatDate(_dueDateTime),
      dueTime:     _formatTime(_dueDateTime),
      status:      'To Do',
      priority:    _selectedPriority,
      progress:    0.0,
      checklist:   [], // empty checklist on creation
    );

    widget.onCreated(newTask); // pass back to the page
    Navigator.pop(context);   // close the sheet
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _titleController.dispose();
    _descriptionController.dispose();
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

            // ── Estimated time

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