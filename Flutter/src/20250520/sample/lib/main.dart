import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final title = 'Flutterサンプル';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// データ用クラス
class Data {
  final int _price;
  final String _name;
  Data(this._name, this._price) : super();

  @override
  String toString() {
    return '$_name:$_price円';
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // サンプルデータ
  static final _data = [
    Data('Apple', 200),
    Data('Orange', 150),
    Data('Peach', 300)
  ];
  Data _item = _data[0];

  void _setData() {
    setState(() {
      _item = (_data..shuffle()).first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set data'),
      ),
      body: Text(
        _item.toString(),
        style: const TextStyle(fontSize: 32.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setData,
        tooltip: 'set message.',
        child: const Icon(Icons.star),
      ),
    );
  }
}
