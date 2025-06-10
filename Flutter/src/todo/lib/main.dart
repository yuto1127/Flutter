import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // const を追加
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // const と super.key を追加

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // new キーワードはDart 2.0以降不要になったため削除
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
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

  @override
  void dispose() {
    _controller.dispose(); // TextEditingControllerは必ずdisposeする
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'), // const を追加
      ),
      body: Column( // Center を削除し、Column を直接使う
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0), // const を追加
            child: TextField(
              controller: _controller,
              style: const TextStyle( // const を追加
                fontSize: 28.0,
                color: Color(0xff000000),
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto",
              ),
              decoration: const InputDecoration( // ヒントテキストを追加
                hintText: '新しいTodoを入力',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // 横方向のパディング
            child: ElevatedButton(
              onPressed: _addTodo, // メソッド名を変更
              child: const Text( // const を追加
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
          Expanded( // ListViewが使用可能なスペースを全て使うようにする
            child: _todoList.isEmpty
                ? const Center( // Todoリストが空の場合のメッセージ
                    child: Text(
                      'Todoがありません',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      // MapのキーをIDとして取得
                      final int todoId = _todoList.keys.elementAt(index);
                      // IDに対応するTodoの内容を取得
                      final String todoText = _todoList[todoId]!; // ! でnullでないことを保証

                      return Card( // 見た目を良くするためにCardで囲む
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        child: CheckboxListTile(
                          title: Text(
                            todoText,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                          value: false, // 初期値はfalse（チェックなし）
                          onChanged: (bool? newValue) {
                            // newValueがtrue（チェックされた）の場合に削除
                            if (newValue == true) {
                              _removeTodo(todoId);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Todoを追加するメソッド
  void _addTodo() {
    setState(() {
      final String text = _controller.text.trim(); // 空白をトリム
      if (text.isNotEmpty) { // 空文字列でない場合のみ追加
        _idCounter++;
        _todoList[_idCounter] = text;
        _controller.clear(); // テキストフィールドをクリア
      }
    });
  }

  // Todoを削除するメソッド
  // Todoを削除するメソッド
  void _removeTodo(int id) {
    setState(() {
      // ★★★ 削除する前にTodoの内容を取得する ★★★
      final String? removedTodoText = _todoList[id];

      _todoList.remove(id); // 指定されたIDのTodoをMapから削除
      // SnackBarの表示
      if (removedTodoText != null) { // 取得したテキストがnullでなければ表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todoを削除しました: "$removedTodoText"'), // ここで取得したテキストを使用
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }
}