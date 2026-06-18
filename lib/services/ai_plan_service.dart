import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_plan.dart';

class AiPlanService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProjectPlan> generatePlan({
    required String title,
    required String details,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/generate-plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'details': details,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate plan: ${response.body}');
    }

    final generatedPlan = ProjectPlan.fromJson(jsonDecode(response.body));

    final joinCode = generatedPlan.inviteCode.isNotEmpty
        ? generatedPlan.inviteCode
        : _generateJoinCode();

    final teamResponse = await _supabase
        .from('teams')
        .insert({
      'name': title,
      'join_code': joinCode,
      'created_by': user.id,
    })
        .select()
        .single();

    final teamId = teamResponse['id'];

    await _supabase.from('team_members').insert({
      'team_id': teamId,
      'user_id': user.id,
      'role': 'owner',
    });

    final projectResponse = await _supabase
        .from('projects')
        .insert({
      'team_id': teamId,
      'created_by': user.id,
      'title': title,
      'details': details,
    })
        .select()
        .single();

    final projectId = projectResponse['id'];

    final taskRows = generatedPlan.tasks.map((task) {
      return {
        'project_id': projectId,
        'week': task.week,
        'day': task.day,
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'estimated_hours': task.estimatedHours,
        'is_completed': false,
        'assigned_to': null,
      };
    }).toList();

    if (taskRows.isNotEmpty) {
      await _supabase.from('tasks').insert(taskRows);
    }

    return ProjectPlan(
      id: projectId.toString(),
      title: title,
      details: details,
      inviteCode: joinCode,
      tasks: generatedPlan.tasks,
    );
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(
      6,
          (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}