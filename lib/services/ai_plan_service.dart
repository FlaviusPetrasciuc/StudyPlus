import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_plan.dart';

class AiPlanService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<ProjectPlan> generatePlan({
    required String title,
    required String details,
  }) async {
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

    return ProjectPlan.fromJson(jsonDecode(response.body));
  }
}