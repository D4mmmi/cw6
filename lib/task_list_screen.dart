import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_model.dart';
import 'auth.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _taskController = TextEditingController();

  Future<void> _addTask(String name) async {
    await _firestore.collection('tasks').add({
      'name': name,
      'isCompleted': false,
      'priority': 'Low',
      'userId': _auth.currentUser?.uid,
    });
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> _deleteTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: signOut)],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _taskController, decoration: InputDecoration(labelText: 'New Task')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      _addTask(_taskController.text.trim());
                      _taskController.clear();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('tasks').where('userId', isEqualTo: _auth.currentUser?.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final tasks = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Task.fromMap(data, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.name, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(task),
                      ),
                      trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteTask(task)),
                    );
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
