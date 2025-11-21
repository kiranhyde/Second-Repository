import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/task.dart';

/// Repository that proxies the backend API.
class TaskRepository {
  TaskRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  final _uuid = const Uuid();

  Future<List<Task>> fetchTasks() async {
    final uri = Uri.parse('$baseUrl/tasks');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load tasks');
    }
    final List<dynamic> payload = jsonDecode(response.body) as List<dynamic>;
    return payload
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Task> createTask(Task task) async {
    final uri = Uri.parse('$baseUrl/tasks');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
    return Task.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Task scaffoldTask({
    required String title,
    required TaskPriority priority,
    List<TaskStep>? steps,
    int? estimatedMinutes,
  }) {
    final safeSteps = steps ?? [];
    final estimate = estimatedMinutes ??
        safeSteps.fold<int>(0, (sum, step) => sum + step.estimatedMinutes);
    return Task(
      id: _uuid.v4(),
      title: title,
      priority: priority,
      steps: safeSteps,
      estimatedMinutes: estimate,
    );
  }
}
