import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/invitation_service.dart';
import '../widgets/menu_button.dart';

class InviteTeamMembersScreen extends StatefulWidget {
  const InviteTeamMembersScreen({super.key});

  @override
  State<InviteTeamMembersScreen> createState() =>
      _InviteTeamMembersScreenState();
}

class _InviteTeamMembersScreenState extends State<InviteTeamMembersScreen> {
  String inviteCode = '';
  String errorMessage = '';
  bool isLoading = true;

  final String teamId = 'c805eb9f-2d5b-4e62-8137-29075f9c7f52';
  final String projectName = 'Product Launch Q2 2026';

  @override
  void initState() {
    super.initState();
    loadInviteCode();
  }

  Future<void> loadInviteCode() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final code = await InvitationService.generateInviteCode(teamId);

      setState(() {
        inviteCode = code;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: MenuButton(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            projectCard(),
            const SizedBox(height: 24),

            if (errorMessage.isNotEmpty)
              errorCard()
            else
              inviteCodeCard(),
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
            'Share this invite code with your teammates so they can join this project.',
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
                    inviteCode.isEmpty ? 'No code generated' : inviteCode,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loadInviteCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D83FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate New Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget errorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Could not generate invite code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: loadInviteCode,
            child: const Text('Try Again'),
          ),
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