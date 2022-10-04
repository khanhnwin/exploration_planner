import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(ProviderScope(child: MyApp()));

final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(tasks: [
    Task(id: 1, label: 'Load rocket with supplies'),
    Task(id: 2, label: 'Launch rocket'),
    Task(id: 3, label: 'Circle the home planet'),
    Task(id: 4, label: 'Head out to the first moon'),
    Task(id: 5, label: 'Launch moon lander #1')
  ]);
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exploration!',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Space Exploration Planner!'),
      ),
      body: Column(
        children: [
          Progress(),
          TaskList(),
        ],
      ),
    );
  }
}

class Progress extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(tasksProvider);

    var numCompletedTasks = tasks.where((task) {
      return task.completed == true;
    }).length;

    return Column(
      children: [
        Text('You are this far away from exploring the whole universe:'),
        LinearProgressIndicator(value: numCompletedTasks / tasks.length),
      ],
    );
  }
}

class TaskList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(tasksProvider);

    return Column(
      children: tasks
          .map(
            (task) => TaskItem(task: task),
          )
          .toList(),
    );
  }
}

class TaskItem extends ConsumerWidget {
  final Task task;

  TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Checkbox(
          onChanged: (newValue) =>
              ref.read(tasksProvider.notifier).toggle(task.id),
          value: task.completed,
        ),
        Text(task.label),
      ],
    );
  }
}

@immutable
class Task {
  final int id;
  final String label;
  final bool completed;

  Task({required this.id, required this.label, this.completed = false});

  Task copyWith({int? id, String? label, bool? completed}) {
    return Task(
        id: id ?? this.id,
        label: label ?? this.label,
        completed: completed ?? this.completed);
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier({tasks}) : super(tasks);

  void add(Task task) {
    state = [...state, task];
  }

  void toggle(int taskId) {
    state = [
      for (final item in state)
        if (taskId == item.id)
          item.copyWith(completed: !item.completed)
        else
          item
    ];
  }
}
