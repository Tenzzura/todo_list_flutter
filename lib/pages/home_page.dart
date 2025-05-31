import 'dart:async';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/todo.dart';
import 'package:to_do_list/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> todos = [];

  StreamSubscription? todoStream;

  @override
  void initState() {
    super.initState();
    todoStream = DatabaseService.db.todos
        .buildQuery<Todo>()
        .watch(fireImmediately: true)
        .listen((data) {
          // ketika ada perubahan pada data, maka akan mengupdate
          setState(() {
            todos = data;
          });
        });
  }

  @override
  void dispose() {
    // menutup semua proses yang berjalan dan mencegah memory leak
    todoStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        title: Center(child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(children: [
            
             Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w300)),
             const Text('To-Do List', style: TextStyle(fontSize: 24, fontFamily: "Poppins", fontWeight: FontWeight.bold))
          ],),
        )),
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 30),
        child: _buildApp(),
      ),

      // tombol tambah
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditToDo();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildApp() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Card(
            color: todo.isCompleted ? Colors.grey[400] : Colors.grey[100],
            child: ListTile(
              // ketika di tap, akan menampilkan konfirmasi untuk menghapus
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text(
                      'Apakah Anda yakin ingin menghapus to-do ini?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await DatabaseService.db.writeTxn(() async {
                            await DatabaseService.db.todos.delete(todo.id);
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, true);
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await DatabaseService.db.writeTxn(() async {
                    await DatabaseService.db.todos.delete(todo.id);
                  });
                }
              },
              title: Text(
                todo.title ?? "",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: todo.isCompleted ? Colors.black54 : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.description ?? "",
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.isCompleted ? Colors.black54 : Colors.black,
                    ),
                  ),
                  if (todo.createdAt != null)
                    Text(
                      'Dibuat: ${todo.createdAt?.day}/${todo.createdAt?.month}/${todo.createdAt?.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // icon untuk mengedit to-do
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _addOrEditToDo(todo: todo);
                    },
                  ),
                  Checkbox(
                    value: todo.isCompleted ,
                    onChanged: (value) async {
                      await DatabaseService.db.writeTxn(() async {
                        await DatabaseService.db.todos.put(
                          todo.copyWith(isCompleted: value),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // fungsi untuk menambahkan atau mengedit to-do
  void _addOrEditToDo({Todo? todo}) {
    //controller untuk mengelola input teks judl dan deskripsi
    TextEditingController titleController = TextEditingController(
      text: todo?.title ?? "",
    );
    TextEditingController descriptionController = TextEditingController(
      text: todo?.description ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(todo != null ? 'Edit To-Do' : 'Tambah To-Do'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  late Todo newTodo;
                  if (todo != null) {
                    // jika todo tidak null, maka akan mengedit todo yang sudah ada
                    newTodo = todo.copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                    );
                  } else {
                    // jika todo null, maka akan menambahkan todo baru
                    newTodo = Todo().copyWith(
                      title: titleController.text,
                      description: descriptionController.text,
                      createdAt: DateTime.now(),
                    );
                  }
                  await DatabaseService.db.writeTxn(() async {
                    await DatabaseService.db.todos.put(newTodo);
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan Deskripsi tidak boleh kosong'),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
