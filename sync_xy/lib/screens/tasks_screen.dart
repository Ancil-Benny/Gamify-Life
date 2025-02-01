import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/providers/app_state_provider.dart';
import 'package:sync_xy/models/task.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showDialog(BuildContext context, {Task? task, int? index}) {
    final TextEditingController taskNameController = TextEditingController(text: task?.name ?? '');
    final TextEditingController coinsController = TextEditingController(text: task?.coins.toString() ?? '');
    final TextEditingController xpController = TextEditingController(text: task?.xp.toString() ?? '');
    String taskType = task?.type ?? 'daily';
    String penalty = task?.penalty ?? '0%';
    DateTime? endDate = task?.endDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Task',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            if (task != null)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color.fromARGB(255, 112, 73, 180)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showDeleteConfirmationDialog(context, index!);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: taskNameController,
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), // user-entered text is black
                          decoration: InputDecoration(
                            labelText: 'Task Name',
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // label uses theme color
                            prefixIcon: const Icon(Icons.task),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text('Type:'),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'daily',
                                    groupValue: taskType,
                                    onChanged: (value) {
                                      setState(() {
                                        taskType = value!;
                                      });
                                    },
                                  ),
                                  const Text('Daily'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'once',
                                    groupValue: taskType,
                                    onChanged: (value) {
                                      setState(() {
                                        taskType = value!;
                                      });
                                    },
                                  ),
                                  const Text('Once'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: coinsController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Coins',
                                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  prefixIcon: const Icon(Icons.monetization_on),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: xpController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'XP',
                                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  prefixIcon: const Icon(Icons.star),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: TextEditingController(
                            text: endDate != null
                                ? "${endDate?.toLocal()}".split(' ')[0]
                                : '',
                          ),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                endDate = pickedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text('Penalty:'),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: '0%',
                                        groupValue: penalty,
                                        onChanged: (value) {
                                          setState(() {
                                            penalty = value!;
                                          });
                                        },
                                      ),
                                      const Text('0%'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: '100%',
                                        groupValue: penalty,
                                        onChanged: (value) {
                                          setState(() {
                                            penalty = value!;
                                          });
                                        },
                                      ),
                                      const Text('100%'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: '200%',
                                        groupValue: penalty,
                                        onChanged: (value) {
                                          setState(() {
                                            penalty = value!;
                                          });
                                        },
                                      ),
                                      const Text('200%'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (taskNameController.text.isNotEmpty &&
                                    coinsController.text.isNotEmpty &&
                                    xpController.text.isNotEmpty &&
                                    endDate != null) {
                                  final newTask = Task(
                                    name: taskNameController.text,
                                    type: taskType,
                                    coins: int.parse(coinsController.text),
                                    xp: int.parse(xpController.text),
                                    endDate: endDate!,
                                    penalty: penalty,
                                  );
                                  if (task == null) {
                                    Provider.of<AppStateProvider>(context, listen: false).addTask(newTask);
                                  } else {
                                    Provider.of<AppStateProvider>(context, listen: false).updateTask(index!, newTask);
                                  }
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<AppStateProvider>(context, listen: false).deleteTask(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return ListView.builder(
            itemCount: appState.tasks.length,
            itemBuilder: (context, index) {
              final task = appState.tasks[index];
              return Card(
                elevation: 2, // Reduced shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.task),
                  title: Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      color: task.isCompleted
                          ? Colors.grey
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: task.isCompleted
                            ? null
                            : () {
                                _showDialog(context, task: task, index: index);
                              },
                      ),
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: task.isCompleted
                            ? null
                            : (bool? value) {
                                appState.toggleTaskCompletion(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Task completed'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        appState.toggleTaskCompletion(index);
                                      },
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}