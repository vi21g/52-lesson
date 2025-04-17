import 'package:flutter/material.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Менеджер задач',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskManagerHomePage(),
    );
  }
}

class TaskManagerHomePage extends StatefulWidget {
  @override
  _TaskManagerHomePageState createState() => _TaskManagerHomePageState();
}

class _TaskManagerHomePageState extends State<TaskManagerHomePage> {
  final TextEditingController _taskController = TextEditingController();
  final List<String> _tasks = [];
  int? _selectedIndex;

  void _addTask() {
    final task = _taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add(task);
        _taskController.clear();
        _selectedIndex = null;
      });
    } else {
      _showWarningDialog('Введите задачу!');
    }
  }

  void _deleteTask() {
    if (_selectedIndex != null &&
        _selectedIndex! >= 0 &&
        _selectedIndex! < _tasks.length) {
      setState(() {
        _tasks.removeAt(_selectedIndex!);
        _selectedIndex = null;
      });
    } else {
      _showWarningDialog('Выберите задачу для удаления!');
    }
  }

  void _editTask() async {
    if (_selectedIndex != null &&
        _selectedIndex! >= 0 &&
        _selectedIndex! < _tasks.length) {
      final oldTask = _tasks[_selectedIndex!];
      final newTask = await _showEditDialog(oldTask);
      if (newTask != null && newTask.trim().isNotEmpty && newTask != oldTask) {
        setState(() {
          _tasks[_selectedIndex!] = newTask.trim();
        });
      }
    } else {
      _showWarningDialog('Выберите задачу для редактирования!');
    }
  }

  void _clearTasks() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Подтверждение'),
            content: Text('Удалить все задачи?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Удалить'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      setState(() {
        _tasks.clear();
        _selectedIndex = null;
      });
    }
  }

  Future<void> _showWarningDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Предупреждение'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ОК'),
              ),
            ],
          ),
    );
  }

  Future<String?> _showEditDialog(String oldTask) async {
    final TextEditingController editController = TextEditingController(
      text: oldTask,
    );
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Редактирование'),
            content: TextField(
              controller: editController,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Измените задачу'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(editController.text),
                child: Text('Сохранить'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Менеджер задач')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Введите новую задачу',
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: Text('Добавить')),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  return ListTile(
                    title: Text(_tasks[index]),
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedIndex = isSelected ? null : index;
                      });
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _deleteTask, child: Text('Удалить')),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _editTask,
                  child: Text('Редактировать'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearTasks,
                  child: Text('Очистить все'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
