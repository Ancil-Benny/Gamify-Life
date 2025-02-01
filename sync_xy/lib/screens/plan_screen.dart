import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/providers/app_state_provider.dart';
import 'package:sync_xy/models/note.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _showNoteDialog(BuildContext context, {Note? note, int? index}) {
    final TextEditingController titleController = TextEditingController(text: note?.title ?? '');
    final TextEditingController contentController = TextEditingController(text: note?.content ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Note', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Content',
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (note != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color.fromARGB(255, 112, 73, 180)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showDeleteConfirmationDialog(context, index!);
                        },
                      ),
                    ElevatedButton(
                      onPressed: () {
                        final newNote = Note(
                          title: titleController.text,
                          content: contentController.text,
                        );
                        if (note == null) {
                          Provider.of<AppStateProvider>(context, listen: false).addNote(newNote);
                        } else {
                          Provider.of<AppStateProvider>(context, listen: false).updateNote(index!, newNote);
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<AppStateProvider>(context, listen: false).deleteNote(index);
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
    final notes = Provider.of<AppStateProvider>(context).notes;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: notes.isEmpty
            ? const Center(child: Text('No notes yet.'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return GestureDetector(
                    onTap: () => _showNoteDialog(context, note: note, index: index),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: Text(
                                note.content,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}