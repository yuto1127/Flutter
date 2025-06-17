import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async';

void main() {
  runApp(const MyApp()); // const を追加
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // const と super.key を追加

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // new キーワードはDart 2.0以降不要になったため削除
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFffffff),
      ),
      home: MyHomePage(), // const は付けない
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key); // Key? key と super(key: key) を使用

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static int _idCounter = 0; // _id ではなく _idCounter にリネームしてカウンターであることを明確に
  static Map<int, Map<String, dynamic>> _todoList = {}; // TodoのIDと内容、期限を保存
  static final _controller = TextEditingController();
  static Map<int, bool> _todoChecked = {}; // チェック状態を保存するMapを追加
  DateTime _selectedDateTime = DateTime.now().copyWith(
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _controller.dispose(); // TextEditingControllerは必ずdisposeする
    super.dispose();
  }

  Future<void> _selectDateTime(int todoId) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // 選択したTodoに期限を設定
          if (_todoList[todoId] != null) {
            _todoList[todoId]!['deadline'] = _selectedDateTime
                .toIso8601String();
            _saveTodos();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontSize: 28.0,
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                    ),
                    decoration: const InputDecoration(hintText: '新しいTodoを入力'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text(
                    "登録",
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _todoList.isEmpty
                ? const Center(
                    child: Text(
                      'Todoがありません',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final int todoId = _todoList.keys.elementAt(index);
                      final todoData = _todoList[todoId]!;
                      final String todoText = todoData['text'] as String;
                      final bool hasDeadline = todoData.containsKey('deadline');
                      final DateTime? deadline = hasDeadline
                          ? DateTime.parse(todoData['deadline'] as String)
                          : null;
                      final bool isChecked = _todoChecked[todoId] ?? false;
                      final bool isOverdue =
                          hasDeadline &&
                          deadline != null &&
                          DateTime.now().isAfter(deadline) &&
                          !isChecked;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
                        color: isOverdue ? Colors.red[50] : null,
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todoText,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: isChecked
                                          ? Colors.grey
                                          : Colors.black,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (hasDeadline && deadline != null)
                                    Text(
                                      '期限: ${deadline.year}/${deadline.month.toString().padLeft(2, '0')}/${deadline.day.toString().padLeft(2, '0')} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: isOverdue
                                            ? Colors.red
                                            : Colors.grey[600],
                                        fontWeight: isOverdue
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    )
                                  else
                                    const Text(
                                      '期限: 未設定',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _todoChecked[todoId] = newValue ?? false;
                                  _saveTodos();
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _selectDateTime(todoId),
                                    icon: const Icon(Icons.schedule, size: 16),
                                    label: Text(hasDeadline ? '期限変更' : '期限設定'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasDeadline
                                          ? Colors.orange
                                          : Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _todoChecked.containsValue(true)
          ? FloatingActionButton(
              onPressed: _confirmDelete,
              child: const Icon(Icons.delete),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  void _loadTodos() async {
    // すべてのプラットフォームでSharedPreferencesを使用
    final prefs = await SharedPreferences.getInstance();
    final todoListString = prefs.getString('todoList') ?? '{}';
    final todoCheckedString = prefs.getString('todoChecked') ?? '{}';
    final idCounterString = prefs.getString('idCounter') ?? '0';

    setState(() {
      _todoList = Map<int, Map<String, dynamic>>.from(
        json.decode(todoListString),
      );
      _todoChecked = Map<int, bool>.from(json.decode(todoCheckedString));
      _idCounter = int.parse(idCounterString);
    });
  }

  void _saveTodos() async {
    // すべてのプラットフォームでSharedPreferencesを使用
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('todoList', json.encode(_todoList));
    prefs.setString('todoChecked', json.encode(_todoChecked));
    prefs.setString('idCounter', _idCounter.toString());
  }

  void _addTodo() {
    setState(() {
      final String text = _controller.text.trim();
      if (text.isNotEmpty) {
        _idCounter++;
        _todoList[_idCounter] = {
          'text': text,
          // 期限は設定しない
        };
        _controller.clear();
        _saveTodos();
      }
    });
  }

  void _deleteCheckedTodos() {
    setState(() {
      _todoList.removeWhere((key, value) => _todoChecked[key] == true);
      _todoChecked.removeWhere((key, value) => value == true);
      _saveTodos();
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('選択したTodoを削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('はい'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCheckedTodos();
              },
            ),
          ],
        );
      },
    );
  }
}
