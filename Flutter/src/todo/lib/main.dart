import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'package:flutter/foundation.dart';

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
  static Map<int, String> _todoList = {}; // TodoのIDと内容を保存
  static final _controller = TextEditingController();
  static Map<int, bool> _todoChecked = {}; // チェック状態を保存するMapを追加

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadTodos();
    } else {
      _loadFromFile();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // TextEditingControllerは必ずdisposeする
    super.dispose();
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
            padding: const EdgeInsets.all(10.0), // const を追加
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                // const を追加
                fontSize: 28.0,
                color: Color(0xff000000),
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto",
              ),
              decoration: const InputDecoration(
                // ヒントテキストを追加
                hintText: '新しいTodoを入力',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // 横方向のパディング
            child: ElevatedButton(
              onPressed: _addTodo, // メソッド名を変更
              child: const Text(
                // const を追加
                "追加",
                style: TextStyle(
                  fontSize: 32.0,
                  color: Color(0xff000000),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Roboto",
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // スペーサー
          Expanded(
            // ListViewが使用可能なスペースを全て使うようにする
            child: _todoList.isEmpty
                ? const Center(
                    // Todoリストが空の場合のメッセージ
                    child: Text(
                      'Todoがありません',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final int todoId = _todoList.keys.elementAt(index);
                      final String todoText = _todoList[todoId]!;
                      final bool isChecked = _todoChecked[todoId] ?? false;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            todoText,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: isChecked ? Colors.grey : Colors.black,
                            ),
                          ),
                          value: isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _todoChecked[todoId] = newValue ?? false;
                            });
                          },
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
    final prefs = await SharedPreferences.getInstance();
    final todoListString = prefs.getString('todoList') ?? '{}';
    final todoCheckedString = prefs.getString('todoChecked') ?? '{}';

    setState(() {
      _todoList = Map<int, String>.from(json.decode(todoListString));
      _todoChecked = Map<int, bool>.from(json.decode(todoCheckedString));
    });
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('todoList', json.encode(_todoList));
    prefs.setString('todoChecked', json.encode(_todoChecked));
  }

  void _loadFromFile() async {
    // This method is now empty as per the instructions
  }

  void _addTodo() {
    setState(() {
      final String text = _controller.text.trim();
      if (text.isNotEmpty) {
        _idCounter++;
        _todoList[_idCounter] = text;
        _controller.clear();
        _saveTodos();
        if (!kIsWeb) {
          // _saveToFile();
        }
      }
    });
  }

  void _deleteCheckedTodos() {
    setState(() {
      _todoList.removeWhere((key, value) => _todoChecked[key] == true);
      _todoChecked.removeWhere((key, value) => value == true);
      _saveTodos();
      if (!kIsWeb) {
        // _saveToFile();
      }
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
