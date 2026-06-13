import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project_plan.dart';
import '../services/invitation_service.dart';
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';
import 'project_calendar_screen.dart';

class InviteTeamMembersScreen extends StatefulWidget {
  final ProjectPlan? projectPlan;

  const InviteTeamMembersScreen({
    super.key,
    this.projectPlan,
  });

  @override
  State<InviteTeamMembersScreen> createState() =>
      _InviteTeamMembersScreenState();
}

class _InviteTeamMembersScreenState extends State<InviteTeamMembersScreen> {
  final TextEditingController joinCodeController = TextEditingController();

  String joinMessage = '';
  bool isJoining = false;

  String get inviteCode => widget.projectPlan?.inviteCode ?? '';
  String get projectName => widget.projectPlan?.title ?? 'Join a Project';

  @override
  void dispose() {
    joinCodeController.dispose();
    super.dispose();
  }

  Future<void> joinByCode() async {
    final code = joinCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        joinMessage = 'Please enter an invite code';
      });
      return;
    }

    setState(() {
      isJoining = true;
      joinMessage = '';
    });

    try {
      final projectPlan = await InvitationService.joinTeamByCode(code);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectCalendarScreen(projectPlan: projectPlan),
        ),
      );
    } catch (error) {
      setState(() {
        joinMessage = 'Invalid invite code';
        isJoining = false;
      });
    }
  }

  void copyInviteCode() {
    if (inviteCode.isEmpty) return;

    Clipboard.setData(ClipboardData(text: inviteCode));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      endDrawer: CustomNavigationDrawer(activePage: 'Team Invite'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Invite Team Members',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Builder(
              builder: (context) {
                return MenuButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            projectCard(),
            const SizedBox(height: 24),
            if (widget.projectPlan != null) inviteCodeCard(),
            if (widget.projectPlan != null) const SizedBox(height: 24),
            joinCodeCard(),
          ],
        ),
      ),
    );
  }

  Widget projectCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.groups_outlined,
            color: Color(0xFF0D83FF),
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            projectName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Share your code with teammates or enter a code to join a project.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget inviteCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Invite Code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    inviteCode,
                    style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: copyInviteCode,
                  icon: const Icon(Icons.copy),
                  color: const Color(0xFF0D83FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget joinCodeCard() {
    final bool isSuccess = joinMessage.contains('Successfully');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Do you have an invite code?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter it here to join a team and see the same AI project tasks.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: joinCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter invite code',
              filled: true,
              fillColor: const Color(0xFFFAFAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF0D83FF),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isJoining ? null : joinByCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D83FF),
                foregroundColor: Colors.white,
              ),
              child: Text(isJoining ? 'Joining...' : 'Join Team'),
            ),
          ),
          if (joinMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              joinMessage,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}