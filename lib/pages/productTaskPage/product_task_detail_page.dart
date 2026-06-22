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
  late String     _draftStatus;
  late String     _draftPriority;
  late TaskGroup? _draftGroup;
  late DateTime   _draftDueDateTime;
  late String     _draftEstimatedTime; // now editable via draft pattern

  static const List<String> _statusOptions   = ['Pending', 'In Progress', 'Done'];
  static const List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  static const List<Color> _colorOptions = [
    Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFFF59E0B), Color(0xFF10B981),
    Color(0xFFEC4899), Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    // Seed drafts from the real task when the page first opens
    _draftStatus        = widget.task.status;
    _draftPriority      = widget.task.priority ?? 'Medium';
    _draftGroup         = widget.task.group;
    // Parse existing dueDate string into a DateTime, or fall back to now
    _draftDueDateTime   = _parseDueDate(widget.task.dueDate);
    _draftEstimatedTime = widget.task.estimatedTime;
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

  // Formats just the time portion — "2:30 PM" style
  String _formatTime(DateTime dt) {
    final hour   = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h      = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:$minute $period';
  }

  // Formats a log entry date as "Jun 18, 2026"
  String _formatLogDate(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[dt.month]} ${dt.day}, ${dt.year}';
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB))),
        child: child!,
      ),
    );
    if (pickedDate == null) return; // user cancelled

    // Step 2: pick time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draftDueDateTime),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB))),
        child: child!,
      ),
    );
    if (pickedTime == null) return; // user cancelled time step

    // Combine date + time into a single DateTime and update the draft
    setState(() {
      _draftDueDateTime = DateTime(
        pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute,
      );
    });
  }

  // ── Log Hours bottom sheet ────────────────────────────────────
  // Opens when user taps "Log Hours". Hours, notes and date are
  // collected here, then saved directly to widget.task via logTime().
  // Time logs are NOT drafts — they save immediately.
  void _openLogHoursSheet() {
    final hoursController = TextEditingController();
    final notesController = TextEditingController();
    DateTime logDate      = DateTime.now();
    String? hoursError;

    // True if input matches a valid time format with h/m/s, spaces allowed
    bool isValidLogTime(String input) {
      final t = input.trim();
      if (t.isEmpty) return false; // must log something
      return RegExp(r'^(\d+(\.\d+)?\s?h)?\s*(\d+\s?m)?\s*(\d+\s?s)?$').hasMatch(t.toLowerCase())
          && RegExp(r'\d').hasMatch(t); // must contain at least one digit
    }

    // Parses friendly input like "2h", "30m", "15s", "1h 30m", "2 h" into hours
    double parseFriendlyTime(String input) {
      final t = input.trim().toLowerCase();
      if (t.isEmpty) return 0;
      double total = 0;
      final h = RegExp(r'(\d+(\.\d+)?)\s?h').firstMatch(t);
      if (h != null) total += double.parse(h.group(1)!);
      final m = RegExp(r'(\d+)\s?m').firstMatch(t);
      if (m != null) total += int.parse(m.group(1)!) / 60;
      final s = RegExp(r'(\d+)\s?s').firstMatch(t);
      if (s != null) total += int.parse(s.group(1)!) / 3600;
      return total;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        // StatefulBuilder gives the sheet its own setState for the date picker
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Sheet handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Log Hours',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 20),

                // ── Hours field ──
                const Text('Time Spent',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 4),
                Text('e.g. 2h, 30m, 15s, 1h 30m',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                const SizedBox(height: 8),
                TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.text,
                  decoration: _inputDecor('e.g. 1h 30m'),
                  onChanged: (_) {
                    if (hoursError != null) setSheet(() => hoursError = null);
                  },
                ),
                if (hoursError != null) ...[
                  const SizedBox(height: 6),
                  Text(hoursError!, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                ],
                const SizedBox(height: 16),

                // ── Date picker row ──
                const Text('Date',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: logDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: Color(0xFF2563EB))),
                        child: child!,
                      ),
                    );
                    if (picked != null) setSheet(() => logDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
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
                          _formatLogDate(logDate),
                          style: const TextStyle(fontSize: 14,
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

                // ── Notes field ──
                const Text('Notes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _inputDecor('What did you work on?'),
                ),
                const SizedBox(height: 24),

                // ── Save log button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = hoursController.text;
                      if (!isValidLogTime(text)) {
                        setSheet(() => hoursError = 'Use format like 2h, 30m, or 1h 30m');
                        return;
                      }
                      final hours = parseFriendlyTime(text); // e.g. "1h 30m" → 1.5

                      final log = TimeLog(
                        hours: hours,
                        notes: notesController.text.trim(),
                        date:  logDate,
                      );

                      setState(() => widget.task.logTime(log)); // saves immediately, not a draft
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Save Log',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Group editor bottom sheet ─────────────────────────────────
  // Edits _draftGroup, not widget.task.group directly
  void _openGroupEditor() {
    String groupName     = _draftGroup?.name ?? '';
    Color selectedColor  = _draftGroup?.color ?? _colorOptions[0];
    final nameController = TextEditingController(text: groupName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                onChanged: (v) => groupName = v,
                decoration: _inputDecor('e.g. Design, Engineering…'),
              ),
              const SizedBox(height: 20),

              const Text('Colour tag',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
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
                            ? [BoxShadow(color: color.withOpacity(0.5),
                            blurRadius: 6, spreadRadius: 1)]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
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
                    final newGroup = TaskGroup(
                        name: groupName.trim(), color: selectedColor);
                    // Save into draft only — not yet into widget.task
                    setState(() => _draftGroup = newGroup);
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
                        style: TextStyle(fontSize: 14,
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

  // ── Edit Estimated Time sheet ─────────────────────────────────
  // Opens when user taps the Est. chip. Updates _draftEstimatedTime only —
  // written to widget.task when Save Changes is tapped.
  // True if input is empty (allowed) or matches a valid time format
  bool _isValidEstimatedTime(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return true; // empty is allowed
    return RegExp(r'^(\d+(\.\d+)?\s?h)?\s*(\d+\s?m)?$').hasMatch(trimmed.toLowerCase())
        && trimmed.toLowerCase() != 'h' && trimmed.toLowerCase() != 'm';
  }

  // Strips spaces between number and unit, e.g. "28 h" -> "28h"
  String _normalizeTimeFormat(String input) {
    return input.trim().toLowerCase().replaceAllMapped(
        RegExp(r'(\d)\s+([hms])'), (m) => '${m[1]}${m[2]}');
  }

  void _openEditEstimatedSheet() {
    final controller = TextEditingController(text: _draftEstimatedTime);
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Edit Estimated Time',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 20),
              const Text('Estimated Time',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
              const SizedBox(height: 4),
              Text('e.g. 2h, 30m, 1h 30m',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: _inputDecor('e.g. 2h'),
                onChanged: (_) {
                  if (errorText != null) setSheet(() => errorText = null);
                },
              ),
              if (errorText != null) ...[
                const SizedBox(height: 6),
                Text(errorText!, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (!_isValidEstimatedTime(text)) {
                      setSheet(() => errorText = 'Use format like 2h, 30m, or 1h 30m');
                      return;
                    }
                    setState(() => _draftEstimatedTime = _normalizeTimeFormat(text));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Update',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Edit Log Entry sheet, edits hours/notes/date for an existing log
  void _openEditLogSheet(TimeLog log) {
    final hoursController = TextEditingController(text: _formatHours(log.hours));
    final notesController = TextEditingController(text: log.notes);
    DateTime logDate      = log.date;
    String? hoursError;

    bool isValidLogTime(String input) {
      final t = input.trim();
      if (t.isEmpty) return false;
      return RegExp(r'^(\d+(\.\d+)?\s?h)?\s*(\d+\s?m)?\s*(\d+\s?s)?$').hasMatch(t.toLowerCase())
          && RegExp(r'\d').hasMatch(t);
    }

    double parseFriendlyTime(String input) {
      final t = input.trim().toLowerCase();
      if (t.isEmpty) return 0;
      double total = 0;
      final h = RegExp(r'(\d+(\.\d+)?)\s?h').firstMatch(t);
      if (h != null) total += double.parse(h.group(1)!);
      final m = RegExp(r'(\d+)\s?m').firstMatch(t);
      if (m != null) total += int.parse(m.group(1)!) / 60;
      final s = RegExp(r'(\d+)\s?s').firstMatch(t);
      if (s != null) total += int.parse(s.group(1)!) / 3600;
      return total;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Edit Log Entry',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 20),

                // ── Hours field ──
                const Text('Time Spent',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 4),
                Text('e.g. 2h, 30m, 15s, 1h 30m',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                const SizedBox(height: 8),
                TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.text,
                  decoration: _inputDecor('e.g. 1h 30m'),
                  onChanged: (_) {
                    if (hoursError != null) setSheet(() => hoursError = null);
                  },
                ),
                if (hoursError != null) ...[
                  const SizedBox(height: 6),
                  Text(hoursError!, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                ],
                const SizedBox(height: 16),

                // ── Date picker ──
                const Text('Date',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: logDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: Color(0xFF2563EB))),
                        child: child!,
                      ),
                    );
                    if (picked != null) setSheet(() => logDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
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
                        Text(_formatLogDate(logDate),
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2563EB))),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Notes field ──
                const Text('Notes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _inputDecor('What did you work on?'),
                ),
                const SizedBox(height: 24),

                // ── Save edited log ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = hoursController.text;
                      if (!isValidLogTime(text)) {
                        setSheet(() => hoursError = 'Use format like 2h, 30m, or 1h 30m');
                        return;
                      }
                      final newHours = parseFriendlyTime(text);

                      setState(() {
                        widget.task.spentHours -= log.hours; // remove old, add new
                        log.hours  = newHours;
                        log.notes  = notesController.text.trim();
                        log.date   = logDate;
                        widget.task.spentHours += newHours;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Commit all drafts → real task, then go back ───────────────
  void _saveChanges() {
    widget.task.status        = _draftStatus;
    widget.task.priority      = _draftPriority;
    widget.task.group         = _draftGroup;
    widget.task.dueDate       = _formatDate(_draftDueDateTime);
    widget.task.dueTime       = _formatTime(_draftDueDateTime);
    // Save updated estimated time and recalculate the numeric hours
    widget.task.estimatedTime  = _draftEstimatedTime;
    widget.task.estimatedHours = _parseEstimatedHours(_draftEstimatedTime);
    Navigator.pop(context); // return to main page
  }

  // Parses "2h", "30m", "1h 30m" into a numeric hour value
  double _parseEstimatedHours(String input) {
    final t = input.trim().toLowerCase();
    if (t.isEmpty) return 0;
    double total = 0;
    final h = RegExp(r'(\d+(\.\d+)?)h').firstMatch(t);
    if (h != null) total += double.parse(h.group(1)!);
    final m = RegExp(r'(\d+)m').firstMatch(t);
    if (m != null) total += int.parse(m.group(1)!) / 60;
    return total;
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

  // Shared input decoration used across both bottom sheets
  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB))),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back arrow + title + menu icon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    // Back arrow — discards drafts by simply popping without saving
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.black87, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Task Assignment',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700, color: Colors.black87)),
                  )
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
                  const SizedBox(height: 16),
                  // Time tracking only shown if estimated hours were set at creation
                  if (widget.task.estimatedHours > 0) ...[
                    _buildTimeTrackingCard(),
                    const SizedBox(height: 16),
                  ],
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

  // ── Task info card: title, description, due date/time, estimated time ──
  Widget _buildTaskInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.task.title,
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(widget.task.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 12),

          // Tapping this row opens the date+time picker
          GestureDetector(
            onTap: _pickDueDateTime,
            child: Row(
              children: [
                _infoChip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due ${_formatDate(_draftDueDateTime)}',
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 8),
                _infoChip(
                  icon: Icons.access_time_rounded,
                  label: _formatTime(_draftDueDateTime),
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 6),
                // Small pencil hints the date/time row is editable
                Icon(Icons.edit_outlined, size: 13, color: Colors.grey.shade400),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Priority flag chip — reflects the current draft priority
          _infoChip(
            icon: Icons.flag_outlined,
            label: _draftPriority,
            color: _priorityColor(_draftPriority),
            bg: _priorityColor(_draftPriority).withOpacity(0.1),
          ),

          // Estimated time chip — tappable to edit, uses draft value
          if (_draftEstimatedTime.isNotEmpty || widget.task.estimatedTime.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _openEditEstimatedSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _infoChip(
                    icon: Icons.hourglass_top_rounded,
                    label: 'Est. ${_draftEstimatedTime.isNotEmpty ? _draftEstimatedTime : widget.task.estimatedTime}',
                    color: Colors.grey.shade600,
                    bg: Colors.grey.shade100,
                  ),
                  const SizedBox(width: 4),
                  // Pencil signals it's editable
                  Icon(Icons.edit_outlined, size: 13, color: Colors.grey.shade400),
                ],
              ),
            ),
          ],
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
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w500, color: color)),
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
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: _statusOptions.map((s) {
              final isSelected = _draftStatus == s ||
                  (s == 'Pending' && _draftStatus == 'To Do');
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _draftStatus = s), // updates draft only
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
                    child: Text(s,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
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

  // ── Priority card ─────────────────────────────────────────────
  Widget _buildPriorityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Priority',
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: _priorityOptions.map((p) {
              final isSelected = _draftPriority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _draftPriority = p), // updates draft only
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
                            fontSize: 13, fontWeight: FontWeight.w600,
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
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),

          if (_draftGroup != null) ...[
            // Tapping the group row re-opens the editor to change it
            GestureDetector(
              onTap: _openGroupEditor,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _draftGroup!.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _draftGroup!.color.withOpacity(0.25)),
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
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _draftGroup!.color)),
                    ),
                    Icon(Icons.edit_outlined,
                        size: 16, color: _draftGroup!.color),
                  ],
                ),
              ),
            ),
          ] else ...[
            // No group yet — prompt the user to add one
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
                    Icon(Icons.add_circle_outline,
                        size: 18, color: Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Text('Assign to a group',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Time tracking card ────────────────────────────────────────
  // Only shown when estimatedHours > 0.
  // Shows progress bar, spent/remaining stats, Log Hours button, and log history.
  Widget _buildTimeTrackingCard() {
    final task      = widget.task;
    final spent     = task.spentHours;
    final estimated = task.estimatedHours;
    final remaining = task.remainingHours;
    final ratio     = task.timeProgress;
    final isOver    = spent > estimated; // flag when user goes over estimate

    // Bar turns red when over budget, blue otherwise
    final barColor = isOver
        ? const Color(0xFFEF4444)
        : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header row + Log Hours button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Time Tracking',
                  style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700, color: Colors.black87)),
              GestureDetector(
                onTap: _openLogHoursSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text('Log Hours',
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Spent / Estimated / Remaining stats
          Row(
            children: [
              _timeStat('Spent',     _formatHours(spent)),
              const SizedBox(width: 24),
              _timeStat('Estimated', _formatHours(estimated)),
              const SizedBox(width: 24),
              _timeStat('Remaining', _formatHours(remaining),
                  color: isOver
                      ? const Color(0xFFEF4444)
                      : Colors.black87),
            ],
          ),
          const SizedBox(height: 16),

          // Progress label + percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              Text(
                isOver
                    ? '${((spent / estimated) * 100).toInt()}% (over)'
                    : '${(ratio * 100).toInt()}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isOver
                        ? const Color(0xFFEF4444)
                        : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),

          // ── Log history — only shown once at least one entry exists ──
          if (task.timeLogs.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text('Log History',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: Color(0xFF374151))),
            const SizedBox(height: 10),
            // Most recent log shown first
            ...task.timeLogs.reversed.map((log) => _buildLogEntry(log)),
          ],
        ],
      ),
    );
  }

  // Small stat column: label on top, bold value below
  Widget _timeStat(String label, String value,
      {Color color = Colors.black87}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  // Formats a numeric hour value into a friendly string for display
  // e.g. 2.0 → "2h", 0.5 → "30m", 1.5 → "1h 30m", 0.004 → "15s"
  String _formatHours(double hours) {
    if (hours <= 0) return '0m';
    final totalSeconds = (hours * 3600).round();
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    // Only show seconds if there are no hours or minutes
    if (s > 0 && h == 0 && m == 0) parts.add('${s}s');
    return parts.join(' ');
  }

  // A single row in the log history list — tappable to edit
  Widget _buildLogEntry(TimeLog log) {
    return GestureDetector(
      onTap: () => _openEditLogSheet(log), // opens the edit sheet for this entry
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue dot acts as a timeline marker
            Container(
              margin: const EdgeInsets.only(top: 5, right: 10),
              width: 8, height: 8,
              decoration: const BoxDecoration(
                  color: Color(0xFF2563EB), shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_formatHours(log.hours)} logged',
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600, color: Colors.black87)),
                      Row(
                        children: [
                          Text(_formatLogDate(log.date),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500)),
                          const SizedBox(width: 6),
                          // Pencil icon signals the entry is editable
                          Icon(Icons.edit_outlined,
                              size: 12, color: Colors.grey.shade400),
                        ],
                      ),
                    ],
                  ),
                  if (log.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(log.notes,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save Changes button — the ONLY place that writes drafts to widget.task ──
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text('Save Changes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}