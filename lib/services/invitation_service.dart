import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_plan.dart';

class InvitationService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<String> generateInviteCode(String projectId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/invite-code'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['inviteCode'];
  }

  static Future<ProjectPlan> joinTeamByCode(String joinCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams/join-by-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'joinCode': joinCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid invite code: ${response.body}');
    }

    return ProjectPlan.fromJson(jsonDecode(response.body));
  }
}