import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstapp/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textController = TextEditingController();

  final DatabaseReference _taskRef =
      FirebaseDatabase.instance.ref().child('tasks');

  Future<void> addItem(String text) async {
    if (text == "") return;
    await _taskRef.push().set({
      'task': text,
      'completed': false,
    });

    _textController.clear();
  }

  Future<void> updateItem(String key, bool? checked) async {
    await _taskRef.child(key).update({'completed': checked});
  }

  Future<void> deleteItem(String key) async {
    await _taskRef.child(key).remove();
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove('user');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _textController,
                  )),
                  ElevatedButton(
                      onPressed: () => addItem(_textController.text),
                      child: const Text("Add"))
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Text("Tasks"),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _taskRef.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.snapshot.value != null) {
                      Map<dynamic, dynamic> tasks = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;

                      List<Map<dynamic, dynamic>> taskList =
                          tasks.entries.map((entry) {
                        return {'key': entry.key, ...entry.value};
                      }).toList();

                      return ListView.builder(
                          itemCount: taskList.length,
                          itemBuilder: (context, index) {
                            dynamic task = taskList[index];
                            return ListTile(
                              leading: Checkbox(
                                onChanged: (bool? checked) async {
                                  await updateItem(task['key'], checked);
                                },
                                value: task['completed'],
                              ),
                              title: Text(task['task']),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await deleteItem(task['key']);
                                },
                              ),
                            );
                          });
                    } else {
                      return const Text("No List Item");
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}
