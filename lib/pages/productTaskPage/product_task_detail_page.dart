import 'package:flutter/material.dart';
import 'models/product_task_module.dart';

class ProductTaskDetailPage extends StatefulWidget {
  final ProductTask task;
  const ProductTaskDetailPage({super.key, required this.task});

  @override
  State<ProductTaskDetailPage> createState() => _ProductTaskDetailPageState();
}

class _ProductTaskDetailPageState extends State<ProductTaskDetailPage> {

  // ── Draft fields ─────────────────────────────────────────────
  // These hold the in-progress edits. Nothing is written back to
  // widget.task until the user taps "Save Changes".
  late String _draftStatus;
  late String _draftPriority;
  late TaskGroup? _draftGroup;
  late DateTime _draftDueDateTime; // replaces the plain string due date

  static const List<String> _statusOptions   = ['Pending', 'In Progress', 'Done'];
  static const List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  static const List<Color> _colorOptions = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    // Seed drafts from the real task when the page first opens
    _draftStatus   = widget.task.status;
    _draftPriority = widget.task.priority ?? 'Medium';
    _draftGroup    = widget.task.group;
    // Parse existing dueDate string into a DateTime, or fall back to now
    _draftDueDateTime = _parseDueDate(widget.task.dueDate);
  }

  // Tries to parse the stored "Apr 5" style string back to a DateTime.
  // Falls back to today if parsing fails.
  DateTime _parseDueDate(String raw) {
    try {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = raw.split(' ');
      final month = months[parts[0]] ?? DateTime.now().month;
      final day   = int.parse(parts[1]);
      return DateTime(DateTime.now().year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  // Formats a DateTime back to "Apr 5" for display and storage
  String _formatDate(DateTime dt) {
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[dt.month]} ${dt.day}';
  }

  // Formats just the time portion — "14:30" or "2:30 PM" style
  String _formatTime(DateTime dt) {
    final hour   = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h      = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:$minute $period';
  }

  // ── Date & time picker ────────────────────────────────────────
  // Shows Flutter's built-in date picker then immediately the time picker.
  // Updates the draft — does NOT touch widget.task.
  Future<void> _pickDueDateTime() async {
    // Step 1: pick date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _draftDueDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Tint the date picker to match the app's blue
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return; // user cancelled

    // Step 2: pick time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draftDueDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return; // user cancelled time step

    // Combine date + time into a single DateTime and update the draft
    setState(() {
      _draftDueDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ── Group editor bottom sheet ─────────────────────────────────
  // Edits _draftGroup, not widget.task.group directly
  void _openGroupEditor() {
    String groupName      = _draftGroup?.name ?? '';
    Color selectedColor   = _draftGroup?.color ?? _colorOptions[0];
    final nameController  = TextEditingController(text: groupName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _draftGroup == null ? 'Create Group' : 'Edit Group',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              const Text('Group name',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                onChanged: (v) => groupName = v,
                decoration: InputDecoration(
                  hintText: 'e.g. Design, Engineering…',
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
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Colour tag',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _colorOptions.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (groupName.trim().isEmpty) return;
                    // Save into draft only — not yet into widget.task
                    setState(() {
                      _draftGroup = TaskGroup(
                          name: groupName.trim(), color: selectedColor);
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save Group',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              if (_draftGroup != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _draftGroup = null);
                      Navigator.pop(context);
                    },
                    child: Text('Remove group',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Commit all drafts → real task, then go back ───────────────
  void _saveChanges() {
    widget.task.status   = _draftStatus;
    widget.task.priority = _draftPriority;
    widget.task.group    = _draftGroup;
    widget.task.dueDate  = _formatDate(_draftDueDateTime);
    widget.task.dueTime  = _formatTime(_draftDueDateTime);
    Navigator.pop(context); // return to main page
  }

  // ── Helpers ───────────────────────────────────────────────────
  Color _priorityColor(String p) {
    switch (p) {
      case 'High':   return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF59E0B);
      default:       return const Color(0xFF6B7280);
    }
  }

  Color _statusSelectedBg(String s) {
    switch (s) {
      case 'Done':        return const Color(0xFF22C55E);
      case 'In Progress': return const Color(0xFF6366F1);
      default:            return const Color(0xFF2563EB);
    }
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    // Back arrow — discards drafts by simply popping without saving
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Task Assignment',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTaskInfoCard(),
                  const SizedBox(height: 16),
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildPriorityCard(),
                  const SizedBox(height: 16),
                  _buildGroupCard(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Task info card: title, description, due date/time picker ──
  Widget _buildTaskInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.task.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(widget.task.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 12),

          // Tapping this row opens the date+time picker
          GestureDetector(
            onTap: _pickDueDateTime,
            child: Row(
              children: [
                // Date chip
                _infoChip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due ${_formatDate(_draftDueDateTime)}',
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 8),
                // Time chip
                _infoChip(
                  icon: Icons.access_time_rounded,
                  label: _formatTime(_draftDueDateTime),
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 6),
                // Small pencil hints it's editable
                Icon(Icons.edit_outlined, size: 13, color: Colors.grey.shade400),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Priority flag chip — reflects draft priority
          _infoChip(
            icon: Icons.flag_outlined,
            label: _draftPriority,
            color: _priorityColor(_draftPriority),
            bg: _priorityColor(_draftPriority).withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  // ── Status card ───────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: _statusOptions.map((s) {
              final isSelected = _draftStatus == s ||
                  (s == 'Pending' && _draftStatus == 'To Do');
              return Expanded(
                child: GestureDetector(
                  // Updates draft only
                  onTap: () => setState(() => _draftStatus = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _statusSelectedBg(s)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      s,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Priority card ─────────────────────────────────────────────
  Widget _buildPriorityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Priority',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: _priorityOptions.map((p) {
              final isSelected = _draftPriority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  // Updates draft only
                  onTap: () => setState(() => _draftPriority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _priorityColor(p) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(p,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black54)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Group card ────────────────────────────────────────────────
  Widget _buildGroupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Group',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),

          if (_draftGroup != null) ...[
            GestureDetector(
              onTap: _openGroupEditor,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _draftGroup!.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _draftGroup!.color.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: _draftGroup!.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_draftGroup!.name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _draftGroup!.color)),
                    ),
                    Icon(Icons.edit_outlined, size: 16, color: _draftGroup!.color),
                  ],
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _openGroupEditor,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 18, color: Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Text('Assign to a group',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Save Changes button — the ONLY place that writes to widget.task ──
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text('Save Changes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}