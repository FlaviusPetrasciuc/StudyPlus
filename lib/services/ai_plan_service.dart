import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generated_task.dart';

class AiPlanService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<GeneratedTask>> generatePlan({
    required String title,
    required String details,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-plan'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'details': details,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate plan');
    }

    final data = jsonDecode(response.body);
    final List tasksJson = data['tasks'];

    return tasksJson.map((task) {
      return GeneratedTask.fromJson(task);
    }).toList();
  }
}