import 'package:flutter/material.dart';
import 'package:study_plus/pages/createProjectPage/create_project_page.dart';
import 'package:study_plus/auth/auth_service.dart';
import 'package:study_plus/screens/login_screen.dart';
import 'package:study_plus/screens/invite_team_members_screen.dart';
import 'package:study_plus/screens/create_project_screen.dart';
import 'package:study_plus/screens/project_calendar_screen.dart';
import 'package:study_plus/pages/productTaskPage/product_task_page.dart';
import 'package:study_plus/pages/createProjectPage/models/project_store.dart';
import 'package:study_plus/screens/my_account_screen.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final String? activePage;
  final AuthService _authService = AuthService();

  CustomNavigationDrawer({super.key, this.activePage});

  void _navigateTo(BuildContext context, String pageName, Widget screen) {
    Navigator.pop(context);

    if (activePage != pageName) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  Widget _latestProjectPage({
    required int tab,
    required Widget fallback,
  }) {
    final projects = ProjectStore.instance.projects;

    if (projects.isEmpty) {
      return fallback;
    }

    return ProductTaskPage(
      project: projects.last,
      initialTab: tab,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      Text(
                        'Jump to any screen',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C7278),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _buildSectionTitle('MAIN'),

            _buildMenuItem(
              context,
              'Dashboard',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateProjectPage(),
                    settings: const RouteSettings(name: 'CreateProjectPage'),
                  ),
                      (route) => false,
                );
              },
            ),

            _buildMenuItem(context, 'My Account'),

            _buildMenuItem(
              context,
              'New Project',
              onTap: () {
                _navigateTo(
                  context,
                  'New Project',
                  const CreateProjectScreen(),
                );
              },
            ),

            _buildMenuItem(
              context,
              'Calendar',
              onTap: () {
                _navigateTo(
                  context,
                  'Calendar',
                  const ProjectCalendarScreen(),
                );
              },
            ),

            const SizedBox(height: 30),

            _buildSectionTitle('TEAM'),

            _buildMenuItem(
              context,
              'Team Dashboard',
              onTap: () {
                _navigateTo(
                  context,
                  'Team Dashboard',
                  _latestProjectPage(
                    tab: 0,
                    fallback: const CreateProjectScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context,
              'Activity Feed',
              onTap: () {
                _navigateTo(
                  context,
                  'Activity Feed',
                  _latestProjectPage(
                    tab: 1,
                    fallback: const CreateProjectScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context,
              'Team Analytics',
              onTap: () {
                _navigateTo(
                  context,
                  'Team Analytics',
                  _latestProjectPage(
                    tab: 2,
                    fallback: const CreateProjectScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              context,
              'Team Invite',
              onTap: () {
                _navigateTo(
                  context,
                  'Team Invite',
                  const InviteTeamMembersScreen(),
                );
              },
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await _authService.signOut();

                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C7278),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title, {
        VoidCallback? onTap,
      }) {
    final bool isActive = activePage == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF007AFF) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isActive) {
              Navigator.pop(context);
              return;
            }

            if (onTap != null) {
              onTap();
              return;
            }

            Widget? nextPage;

            if (title == 'My Account') {
              nextPage = const MyAccountScreen();
            } else if (title == 'New Project') {
              nextPage = const CreateProjectScreen();
            } else if (title == 'Calendar') {
              nextPage = const ProjectCalendarScreen();
            } else if (title == 'Team Invite') {
              nextPage = const InviteTeamMembersScreen();
            }

            if (nextPage == null) {
              Navigator.pop(context);
              return;
            }

            Navigator.pop(context);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nextPage!),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF1A1C1E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}