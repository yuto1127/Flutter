# Flutter & Dart ウィジェット完全ガイド

## 目次
1. [基本ウィジェット](#基本ウィジェット)
2. [レイアウトウィジェット](#レイアウトウィジェット)
3. [入力ウィジェット](#入力ウィジェット)
4. [ナビゲーションウィジェット](#ナビゲーションウィジェット)
5. [マテリアルデザインウィジェット](#マテリアルデザインウィジェット)
6. [カスタムウィジェット](#カスタムウィジェット)
7. [状態管理](#状態管理)

---

## 基本ウィジェット

### 1. Text
テキストを表示するための基本的なウィジェット

```dart
Text(
  'Hello, Flutter!',
  style: TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

**主なプロパティ:**
- `data`: 表示するテキスト
- `style`: テキストのスタイル
- `textAlign`: テキストの配置
- `maxLines`: 最大行数
- `overflow`: オーバーフロー時の処理

### 2. Container
他のウィジェットを包む汎用的なウィジェット

```dart
Container(
  width: 200.0,
  height: 100.0,
  margin: EdgeInsets.all(16.0),
  padding: EdgeInsets.all(8.0),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        blurRadius: 4.0,
      ),
    ],
  ),
  child: Text('Container Example'),
)
```

**主なプロパティ:**
- `width/height`: サイズ
- `margin/padding`: 余白
- `decoration`: 装飾
- `child`: 子ウィジェット

### 3. Image
画像を表示するウィジェット

```dart
// ネットワーク画像
Image.network(
  'https://example.com/image.jpg',
  width: 200.0,
  height: 200.0,
  fit: BoxFit.cover,
)

// ローカル画像
Image.asset(
  'assets/images/logo.png',
  width: 100.0,
  height: 100.0,
)
```

**主なプロパティ:**
- `width/height`: サイズ
- `fit`: フィット方法
- `alignment`: 配置
- `repeat`: 繰り返し

---

## レイアウトウィジェット

### 1. Row
子ウィジェットを水平に配置

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Icon(Icons.star),
    Text('Rating: 4.5'),
    ElevatedButton(
      onPressed: () {},
      child: Text('Rate'),
    ),
  ],
)
```

**主なプロパティ:**
- `mainAxisAlignment`: 主軸の配置
- `crossAxisAlignment`: 交差軸の配置
- `mainAxisSize`: 主軸のサイズ
- `children`: 子ウィジェットのリスト

### 2. Column
子ウィジェットを垂直に配置

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text('Title', style: TextStyle(fontSize: 24)),
    SizedBox(height: 16),
    Text('Subtitle'),
    SizedBox(height: 32),
    ElevatedButton(
      onPressed: () {},
      child: Text('Action'),
    ),
  ],
)
```

### 3. Stack
子ウィジェットを重ねて配置

```dart
Stack(
  alignment: Alignment.center,
  children: [
    Container(
      width: 200.0,
      height: 200.0,
      color: Colors.blue,
    ),
    Positioned(
      top: 20.0,
      left: 20.0,
      child: Text('Overlay Text'),
    ),
    Positioned(
      bottom: 20.0,
      right: 20.0,
      child: Icon(Icons.favorite, color: Colors.red),
    ),
  ],
)
```

### 4. Expanded
利用可能な空間を埋めるウィジェット

```dart
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(
        color: Colors.red,
        height: 100.0,
      ),
    ),
    Expanded(
      flex: 1,
      child: Container(
        color: Colors.blue,
        height: 100.0,
      ),
    ),
  ],
)
```

### 5. Flexible
子ウィジェットのサイズを柔軟に調整

```dart
Row(
  children: [
    Flexible(
      flex: 1,
      child: Text('Short text'),
    ),
    Flexible(
      flex: 2,
      child: Text('This is a longer text that will wrap if needed'),
    ),
  ],
)
```

### 6. Wrap
子ウィジェットを自動的に折り返し

```dart
Wrap(
  spacing: 8.0,
  runSpacing: 4.0,
  children: [
    Chip(label: Text('Flutter')),
    Chip(label: Text('Dart')),
    Chip(label: Text('Mobile')),
    Chip(label: Text('Development')),
    Chip(label: Text('Cross-platform')),
  ],
)
```

---

## 入力ウィジェット

### 1. TextField
テキスト入力フィールド

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Enter your name',
    hintText: 'John Doe',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.person),
  ),
  onChanged: (value) {
    print('Text changed: $value');
  },
  onSubmitted: (value) {
    print('Submitted: $value');
  },
)
```

**主なプロパティ:**
- `decoration`: 装飾
- `controller`: テキストコントローラー
- `onChanged`: テキスト変更時のコールバック
- `onSubmitted`: 送信時のコールバック
- `keyboardType`: キーボードタイプ

### 2. ElevatedButton
マテリアルデザインのボタン

```dart
ElevatedButton(
  onPressed: () {
    print('Button pressed!');
  },
  style: ElevatedButton.styleFrom(
    primary: Colors.blue,
    onPrimary: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  child: Text('Click Me'),
)
```

### 3. IconButton
アイコンボタン

```dart
IconButton(
  icon: Icon(Icons.favorite),
  onPressed: () {
    print('Icon button pressed!');
  },
  tooltip: 'Add to favorites',
)
```

### 4. Checkbox
チェックボックス

```dart
bool isChecked = false;

Checkbox(
  value: isChecked,
  onChanged: (bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  },
)
```

### 5. Switch
スイッチ

```dart
bool isSwitched = false;

Switch(
  value: isSwitched,
  onChanged: (bool value) {
    setState(() {
      isSwitched = value;
    });
  },
  activeColor: Colors.green,
)
```

### 6. Slider
スライダー

```dart
double sliderValue = 0.5;

Slider(
  value: sliderValue,
  min: 0.0,
  max: 1.0,
  divisions: 10,
  label: '${(sliderValue * 100).round()}%',
  onChanged: (double value) {
    setState(() {
      sliderValue = value;
    });
  },
)
```

---

## ナビゲーションウィジェット

### 1. AppBar
アプリバー

```dart
AppBar(
  title: Text('My App'),
  backgroundColor: Colors.blue,
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {},
  ),
)
```

### 2. BottomNavigationBar
下部ナビゲーションバー

```dart
int _selectedIndex = 0;

BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (int index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.business),
      label: 'Business',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school),
      label: 'School',
    ),
  ],
)
```

### 3. TabBar
タブバー

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.directions_car)),
          Tab(icon: Icon(Icons.directions_transit)),
          Tab(icon: Icon(Icons.directions_bike)),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Icon(Icons.directions_car),
        Icon(Icons.directions_transit),
        Icon(Icons.directions_bike),
      ],
    ),
  ),
)
```

---

## マテリアルデザインウィジェット

### 1. Card
カードウィジェット

```dart
Card(
  elevation: 4.0,
  margin: EdgeInsets.all(8.0),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: Icon(Icons.album),
        title: Text('The Enchanted Nightingale'),
        subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
      ),
      ButtonBar(
        children: [
          TextButton(
            child: const Text('BUY TICKETS'),
            onPressed: () {},
          ),
          TextButton(
            child: const Text('LISTEN'),
            onPressed: () {},
          ),
        ],
      ),
    ],
  ),
)
```

### 2. ListTile
リストアイテム

```dart
ListTile(
  leading: CircleAvatar(
    backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
  ),
  title: Text('John Doe'),
  subtitle: Text('Software Developer'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {
    print('ListTile tapped');
  },
)
```

### 3. FloatingActionButton
フローティングアクションボタン

```dart
FloatingActionButton(
  onPressed: () {
    print('FAB pressed!');
  },
  child: Icon(Icons.add),
  backgroundColor: Colors.blue,
  tooltip: 'Add item',
)
```

### 4. SnackBar
スナックバー

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('This is a SnackBar'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        print('Undo pressed');
      },
    ),
    duration: Duration(seconds: 3),
  ),
)
```

### 5. Dialog
ダイアログ

```dart
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Confirm'),
      content: Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Delete'),
          onPressed: () {
            Navigator.of(context).pop();
            // 削除処理
          },
        ),
      ],
    );
  },
)
```

---

## カスタムウィジェット

### 1. StatelessWidget
状態を持たないウィジェット

```dart
class CustomWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomWidget({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}
```

### 2. StatefulWidget
状態を持つウィジェット

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 3. InheritedWidget
データを子ウィジェットに提供

```dart
class ThemeData extends InheritedWidget {
  final Color primaryColor;
  final Color accentColor;

  const ThemeData({
    Key? key,
    required this.primaryColor,
    required this.accentColor,
    required Widget child,
  }) : super(key: key, child: child);

  static ThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeData>()!;
  }

  @override
  bool updateShouldNotify(ThemeData oldWidget) {
    return primaryColor != oldWidget.primaryColor ||
           accentColor != oldWidget.accentColor;
  }
}
```

---

## 状態管理

### 1. setState
最もシンプルな状態管理

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_counter'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 2. Provider
推奨される状態管理パターン

```dart
// プロバイダーの定義
class CounterProvider extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

// 使用例
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<CounterProvider>(
              builder: (context, counter, child) {
                return Text('Count: ${counter.counter}');
              },
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CounterProvider>().increment();
              },
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Bloc
複雑な状態管理

```dart
// イベント
abstract class CounterEvent {}

class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}

// 状態
abstract class CounterState {
  final int count;
  CounterState(this.count);
}

class CounterInitial extends CounterState {
  CounterInitial() : super(0);
}

class CounterUpdated extends CounterState {
  CounterUpdated(int count) : super(count);
}

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<IncrementEvent>((event, emit) {
      emit(CounterUpdated(state.count + 1));
    });
    
    on<DecrementEvent>((event, emit) {
      emit(CounterUpdated(state.count - 1));
    });
  }
}

// 使用例
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text('Bloc Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<CounterBloc, CounterState>(
                builder: (context, state) {
                  return Text('Count: ${state.count}');
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<CounterBloc>().add(IncrementEvent());
                    },
                    child: Text('+'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CounterBloc>().add(DecrementEvent());
                    },
                    child: Text('-'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## よく使われるレイアウトパターン

### 1. レスポンシブレイアウト

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return Row(
        children: [
          Expanded(child: LeftPanel()),
          Expanded(child: RightPanel()),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: TopPanel()),
          Expanded(child: BottomPanel()),
        ],
      );
    }
  },
)
```

### 2. スクロール可能なレイアウト

```dart
SingleChildScrollView(
  child: Column(
    children: [
      Header(),
      Content(),
      Footer(),
    ],
  ),
)
```

### 3. グリッドレイアウト

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      child: ListTile(
        title: Text(items[index].title),
        subtitle: Text(items[index].subtitle),
      ),
    );
  },
)
```

---

## パフォーマンス最適化

### 1. const コンストラクタの使用

```dart
// 良い例
const Text('Hello')

// 悪い例
Text('Hello')
```

### 2. ListView.builder の使用

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
)
```

### 3. メモ化

```dart
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 重い処理
    );
  }
}

// 使用時
const ExpensiveWidget()
```

---

## まとめ

FlutterとDartでは、豊富なウィジェットライブラリが提供されており、これらを組み合わせることで美しく機能的なアプリケーションを作成できます。適切なウィジェットを選択し、効率的なレイアウトを設計することで、ユーザーエクスペリエンスを向上させることができます。

また、状態管理の選択も重要で、アプリケーションの複雑さに応じて適切なパターンを選択することが推奨されます。
