import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'models/task.dart';
import 'services/gmail_service.dart';
import 'services/message_ingestion_service.dart';
import 'services/sms_service.dart';
import 'services/task_repository.dart';
import 'services/whatsapp_service.dart';
import 'widgets/task_card.dart';

void main() {
  const apiBaseUrl = 'http://localhost:8080';
  final taskRepository = TaskRepository(baseUrl: apiBaseUrl);
  final messageIngestion = MessageIngestionService(
    gmailService: GmailService(baseUrl: apiBaseUrl),
    whatsAppService: WhatsAppService(baseUrl: apiBaseUrl),
    smsService: SmsService(baseUrl: apiBaseUrl),
  );

  runApp(
    TaskFlowApp(
      repository: taskRepository,
      ingestionService: messageIngestion,
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({
    super.key,
    required this.repository,
    required this.ingestionService,
  });

  final TaskRepository repository;
  final MessageIngestionService ingestionService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Priority To-Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: TaskBoardPage(
        repository: repository,
        ingestionService: ingestionService,
      ),
    );
  }
}

class TaskBoardPage extends HookWidget {
  const TaskBoardPage({
    super.key,
    required this.repository,
    required this.ingestionService,
  });

  final TaskRepository repository;
  final MessageIngestionService ingestionService;

  @override
  Widget build(BuildContext context) {
    final tasks = useState<List<Task>>([]);
    final isLoading = useState(true);
    final selectedPriority = useState(TaskPriority.urgentImportant);

    useEffect(() {
      Future<void>(() async {
        tasks.value = await repository.fetchTasks();
        isLoading.value = false;
      });
      return null;
    }, const []);

    Future<void> handleAddTask() async {
      final result = await showDialog<Task>(
        context: context,
        builder: (_) => TaskDialog(
          priority: selectedPriority.value,
          repository: repository,
        ),
      );
      if (result != null) {
        tasks.value = [...tasks.value, result];
      }
    }

    final filteredTasks = tasks.value
        .where((task) => task.priority == selectedPriority.value)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Priority To-Do'),
        actions: [
          IconButton(
            tooltip: 'Ingest Gmail',
            icon: const Icon(Icons.email),
            onPressed: () async {
              await ingestionService.ingestGmail('oauth-token');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gmail ingestion triggered'),
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Ingest WhatsApp',
            icon: const Icon(Icons.chat),
            onPressed: () async {
              await ingestionService.ingestWhatsApp(
                businessAccountId: 'acct-id',
                accessToken: 'access-token',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('WhatsApp ingestion triggered'),
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Ingest SMS',
            icon: const Icon(Icons.sms),
            onPressed: () async {
              await ingestionService.ingestSms();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SMS ingestion triggered'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          PrioritySelector(
            value: selectedPriority.value,
            onChanged: (priority) => selectedPriority.value = priority,
          ),
          Expanded(
            child: isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (_, index) {
                      final task = filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onToggleStep: (stepIndex) {
                          final updatedSteps = [...task.steps];
                          final current = updatedSteps[stepIndex];
                          updatedSteps[stepIndex] = current.copyWith(
                            isCompleted: !current.isCompleted,
                          );
                          tasks.value = tasks.value.map((entry) {
                            if (entry.id == task.id) {
                              return entry.copyWith(steps: updatedSteps);
                            }
                            return entry;
                          }).toList();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
          children: TaskPriority.values.map((priority) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(_labelFor(priority)),
                selected: value == priority,
                onSelected: (_) => onChanged(priority),
              ),
            );
          }).toList(),
      ),
    );
  }

  String _labelFor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgentImportant:
        return 'Do Now';
      case TaskPriority.urgentNotImportant:
        return 'Delegate';
      case TaskPriority.notUrgentImportant:
        return 'Schedule';
      case TaskPriority.notUrgentNotImportant:
        return 'Archive';
    }
  }
}

class TaskDialog extends StatefulWidget {
  const TaskDialog({
    super.key,
    required this.priority,
    required this.repository,
  });

  final TaskPriority priority;
  final TaskRepository repository;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _stepControllers = <TextEditingController>[];
  final _stepMinutes = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _addStepRow();
  }

  void _addStepRow() {
    _stepControllers.add(TextEditingController());
    _stepMinutes.add(TextEditingController(text: '5'));
  }

  @override
  void dispose() {
    for (final controller in [
      ..._stepControllers,
      ..._stepMinutes,
      _titleCtrl,
      _notesCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ..._buildStepFields(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(_addStepRow),
                  child: const Text('Add Step'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final steps = <TaskStep>[];
              for (var i = 0; i < _stepControllers.length; i += 1) {
                final name = _stepControllers[i].text;
                final minutes = int.tryParse(_stepMinutes[i].text) ?? 5;
                if (name.isNotEmpty) {
                  steps.add(
                    TaskStep(title: name, estimatedMinutes: minutes),
                  );
                }
              }
              final task = widget.repository.scaffoldTask(
                title: _titleCtrl.text,
                priority: widget.priority,
                steps: steps,
              );
              final saved = await widget.repository.createTask(task);
              if (context.mounted) {
                Navigator.of(context).pop(saved);
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  List<Widget> _buildStepFields() {
    return List.generate(_stepControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _stepControllers[index],
                decoration: InputDecoration(
                  labelText: 'Step ${index + 1}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _stepMinutes[index],
                decoration: const InputDecoration(labelText: 'Min'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      );
    });
  }
}
