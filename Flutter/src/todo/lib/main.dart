import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Firestore Sample',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _descController = TextEditingController();
  DateTime? _selectedLimit;

  void _showDatePicker(
    BuildContext context,
    void Function(DateTime) onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  void _addTodo() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) return;
    await FirebaseFirestore.instance.collection('TodoData').add({
      'description': desc,
      'limit': _selectedLimit != null
          ? Timestamp.fromDate(_selectedLimit!)
          : null,
      'status': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _descController.clear();
    setState(() => _selectedLimit = null);
  }

  void _editTodo(String docId, String currentDesc, DateTime? currentLimit) {
    final editDescController = TextEditingController(text: currentDesc);
    DateTime? editLimit = currentLimit;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editDescController,
                decoration: const InputDecoration(labelText: '内容'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    editLimit == null
                        ? '期限: 未設定'
                        : '期限: ${editLimit?.year}/${editLimit?.month}/${editLimit?.day}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _showDatePicker(context, (picked) {
                        editLimit = picked;
                        setState(() {});
                        Navigator.of(context).pop();
                        _editTodo(docId, editDescController.text, editLimit);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('TodoData')
                    .doc(docId)
                    .update({
                      'description': editDescController.text.trim(),
                      'limit': editLimit != null
                          ? Timestamp.fromDate(editLimit!)
                          : null,
                    });
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(String docId) async {
    await FirebaseFirestore.instance.collection('TodoData').doc(docId).delete();
  }

  void _updateStatus(String docId, bool? value) async {
    await FirebaseFirestore.instance.collection('TodoData').doc(docId).update({
      'status': value ?? false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Firestore Sample')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Todo内容'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _selectedLimit != null
                      ? '期限: ${_selectedLimit!.year}/${_selectedLimit!.month}/${_selectedLimit!.day}'
                      : '期限: 未設定',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _showDatePicker(context, (picked) {
                      setState(() => _selectedLimit = picked);
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton(onPressed: _addTodo, child: const Text('登録')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('TodoData')
                    .where('status', isEqualTo: false)
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('エラーが発生しました'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('Todoがありません'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, idx) {
                      final doc = docs[idx];
                      final data = doc.data() as Map<String, dynamic>;
                      final desc = data['description'] ?? '';
                      final status = data['status'] ?? false;
                      final limit = data['limit'] != null
                          ? (data['limit'] as Timestamp).toDate()
                          : null;
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: status,
                            onChanged: (v) => _updateStatus(doc.id, v),
                          ),
                          title: Text(desc),
                          subtitle: Text(() {
                            if (limit != null && limit is DateTime) {
                              final dt = limit as DateTime;
                              return '期限: ${(dt.year)}/${(dt.month)}/${(dt.day)}';
                            } else {
                              return '期限: 未設定';
                            }
                          }()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editTodo(doc.id, desc, limit),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTodo(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
