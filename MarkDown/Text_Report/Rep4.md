>このままコピーだと動かないので注意
>>main関数など必要なものが抜けているため

```dart
class _MyHomePageState extends State<MyHomePage> {
  static var _message = 'ok.'; // 初期メッセージ
  static var _janken = <String>['グー', 'チョキ', 'パー']; // じゃんけんの選択肢

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Name'), // アプリのタイトル
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 縦方向の配置
          mainAxisSize: MainAxisSize.max, // 最大サイズ
          crossAxisAlignment: CrossAxisAlignment.stretch, // 横方向の配置
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0), // パディング設定
              child: Text(
                _message, // 表示するメッセージ
                style: TextStyle(
                  fontSize: 32.0, // フォントサイズ
                  fontWeight: FontWeight.w400, // フォントの太さ
                  fontFamily: "Roboto"), // フォントファミリー
              ),
            ),
            TextButton(
              onPressed: buttonPressed, // ボタンが押されたときの処理
              child: Padding(
                padding: EdgeInsets.all(10.0), // ボタン内のパディング
                child: Text(
                  "Push me!", // ボタンのテキスト
                  style: TextStyle(
                    fontSize: 32.0, // フォントサイズ
                    color: const Color(0xff000000), // テキストの色
                    fontWeight: FontWeight.w400, // フォントの太さ
                    fontFamily: "Roboto"), // フォントファミリー
                )
              )
            )
          ]
        ),
      ),
    );
  }

  void buttonPressed() {
    setState(() {
      _message = (_janken..shuffle()).first; // じゃんけんの結果をランダムに選択
    });
  }
}
```


- **クラス定義**: `_MyHomePageState`は`State<MyHomePage>`を継承し、アプリの状態を管理。
- **_message**: 初期メッセージとして'OK.'を設定。これは画面に表示されるメッセージ。
- **_janken**: じゃんけんの選択肢をリストとして定義。
- **buildメソッド**: UIを構築するメソッドで、`Scaffold`ウィジェットを返す。
  - **AppBar**: アプリのタイトルを表示。
  - **Column**: 子ウィジェットを縦に並べるために使用。
  - **Padding**: ウィジェットの周囲に余白を追加。
  - **Text**: メッセージを表示するウィジェット。
  - **TextButton**: 押すと`buttonPressed`メソッドが呼ばれるボタン。
- **buttonPressedメソッド**: ボタンが押されたときに呼び出され、じゃんけんの結果をランダムに選択してメッセージを更新。

## 入力用UI

### TextField

`TextField`は、ユーザーからのテキスト入力を受け取るための基本的なウィジェット。フォームや検索バーなど、さまざまな場面で使用される。

#### 特徴

- **シンプルなテキスト入力**: ユーザーがテキストを入力できるシンプルなフィールドを提供。
- **カスタマイズ可能**: プレースホルダー、スタイル、入力制限など、さまざまなプロパティを設定してカスタマイズ可能。
- **リアルタイムの入力検知**: 入力内容の変更をリアルタイムで検知し、処理を行うことができる。

#### 使用例

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Enter your name',
    border: OutlineInputBorder(),
  ),
  onChanged: (text) {
    print('Text changed: $text');
  },
)
```

### 他の入力用UI

#### Checkbox

`Checkbox`は、ユーザーが選択肢をオンまたはオフにするためのウィジェット。

- **特徴**: 複数の選択肢から選ぶ際に使用される。
- **使用例**:

  ```dart
  Checkbox(
    value: isChecked,
    onChanged: (bool? value) {
      setState(() {
        isChecked = value!;
      });
    },
  )
  ```

#### Radio

`Radio`は、ユーザーが一つの選択肢を選ぶためのウィジェット。

- **特徴**: 複数の選択肢から一つだけ選ぶ際に使用される。
- **使用例**:

  ```dart
  Radio<int>(
    value: 1,
    groupValue: selectedValue,
    onChanged: (int? value) {
      setState(() {
        selectedValue = value!;
      });
    },
  )
  ```

#### Slider

`Slider`は、ユーザーが範囲内の値を選択するためのウィジェット。

- **特徴**: 音量や明るさの調整などに使用される。
- **使用例**:

  ```dart
  Slider(
    value: sliderValue,
    min: 0,
    max: 100,
    onChanged: (double value) {
      setState(() {
        sliderValue = value;
      });
    },
  )
  ```

### まとめ

- `TextField`は、テキスト入力を受け取るための基本的なウィジェット。
- `Checkbox`、`Radio`、`Slider`など、他にもさまざまな入力用UIがあり、それぞれ異なる用途に適している。

## イベントハンドリング

Flutterでは、ユーザーの操作に応じてアクションを実行するためにイベントハンドリングを使用。`onPressed`をはじめ、さまざまなイベントプロパティを使用して、ウィジェットに対するユーザーの操作を処理。

### 書き方

イベントハンドリングは、ウィジェットのプロパティとして関数を渡すことで実装。以下に代表的なイベントプロパティを示す。

#### 使用例

```dart
TextButton(
  onPressed: () {
    print('Button pressed!');
  },
  child: Text('Press me'),
)

TextField(
  onChanged: (text) {
    print('Text changed: $text');
  },
)

GestureDetector(
  onTap: () {
    print('Container tapped!');
  },
  child: Container(
    color: Colors.blue,
    width: 100,
    height: 100,
  ),
)
```

### 主なイベントプロパティ

- **onPressed**: ボタンが押されたときに実行される関数を指定。
- **onChanged**: テキストフィールドの内容が変更されたときに実行される関数を指定。
- **onTap**: タップされたときに実行される関数を指定。
- **onLongPress**: 長押しされたときに実行される関数を指定。
- **onHover**: マウスがウィジェット上にあるときに実行される関数を指定。

### 用途

- **ユーザーインタラクションの処理**: ボタンが押されたときやスライダーが動かされたときなど、ユーザーの操作に応じてアクションを実行。
- **状態の更新**: ユーザーの操作に基づいてアプリケーションの状態を更新し、UIを再描画。
- **ナビゲーション**: ボタンを押すことで、別の画面に遷移するなどのナビゲーションを実行。

### まとめ

- イベントハンドリングは、ユーザーの操作に応じてアクションを実行するために使用される。
- 各ウィジェットのイベントプロパティに関数を渡すことで、イベントを処理。
- ユーザーインタラクションの処理、状態の更新、ナビゲーションなど、さまざまな用途に使用される。

## DropDownButton

`DropDownButton`は、ユーザーが複数の選択肢から一つを選ぶことができるウィジェット。フォームや設定画面などでよく使用される。

### 特徴

- **選択肢の表示**: ドロップダウンメニューを表示し、ユーザーが選択肢を選ぶことが可能。
- **カスタマイズ可能**: アイテムのスタイルや選択時の動作をカスタマイズで可能。
- **簡単な実装**: 簡単に実装でき、選択肢をリストで指定するだけで使用可能。

### 使用例

```dart
DropdownButton<String>(
  value: selectedValue,
  onChanged: (String? newValue) {
    setState(() {
      selectedValue = newValue!;
    });
  },
  items: <String>['One', 'Two', 'Three', 'Four']
      .map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
)
```

### 用途

- **フォーム入力**: ユーザーに選択肢を提供し、フォームの入力を簡素化。
- **設定変更**: 設定画面でのオプション選択に使用される。
- **フィルタリング**: データのフィルタリング条件を選択する際に使用される。

### まとめ

- `DropDownButton`は、複数の選択肢から一つを選ぶためのウィジェット。
- 簡単に実装でき、選択肢をリストで指定するだけで使用可能。
- フォーム入力や設定変更、フィルタリングなど、さまざまな用途に適している。

## PopupMenuButton

`PopupMenuButton`は、ユーザーが複数の選択肢から一つを選ぶことができるポップアップメニューを表示するウィジェット。アプリケーションのアクションメニューやオプションメニューとしてよく使用される。

### 特徴

- **ポップアップメニューの表示**: ボタンを押すと、選択肢がポップアップメニューとして表示。
- **カスタマイズ可能**: メニューのスタイルや選択時の動作をカスタマイズ可能。
- **簡単な実装**: 簡単に実装でき、選択肢をリストで指定するだけで使用可能。

### 使用例

```dart
PopupMenuButton<String>(
  onSelected: (String result) {
    print('Selected: $result');
  },
  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
    const PopupMenuItem<String>(
      value: 'Option 1',
      child: Text('Option 1'),
    ),
    const PopupMenuItem<String>(
      value: 'Option 2',
      child: Text('Option 2'),
    ),
  ],
)
```

### 用途

- **アクションメニュー**: アプリケーションのアクションメニューとして使用され、ユーザーに追加のオプションを提供。
- **オプションメニュー**: 設定やその他のオプションを提供するメニューとして使用。
- **コンテキストメニュー**: 特定のコンテキストに応じたオプションを提供するために使用。

### まとめ

- `PopupMenuButton`は、ポップアップメニューを表示し、ユーザーが選択肢を選ぶためのウィジェット。
- 簡単に実装でき、選択肢をリストで指定するだけで使用可能。
- アクションメニューやオプションメニュー、コンテキストメニューなど、さまざまな用途に適している。

## アラートとダイアログ

Flutterでは、ユーザーに情報を伝えたり、選択を促すためにダイアログを使用。`showDialog`関数を使用して、`AlertDialog`や`SimpleDialog`を表示可能。

### showDialog関数

`showDialog`は、ダイアログを表示するための関数。非同期に動作し、ユーザーの応答を待つ。

#### 使用例

```dart
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Alert'),
      content: Text('This is an alert dialog.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  },
);
```

### AlertDialog関数

`AlertDialog`は、ユーザーに重要な情報を伝えるためのダイアログ。タイトル、コンテンツ、アクションボタンを持つことができる。

#### 使用例

上記の`showDialog`の例を参照。

### SimpleDialog関数

`SimpleDialog`は、ユーザーに選択肢を提示するためのダイアログ。`SimpleDialogOption`を使用して選択肢を追加。

#### 使用例

```dart
showDialog(
  context: context,
  builder: (BuildContext context) {
    return SimpleDialog(
      title: Text('Select an option'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, 'Option 1');
          },
          child: Text('Option 1'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, 'Option 2');
          },
          child: Text('Option 2'),
        ),
      ],
    );
  },
);
```

### アラートにボタンを追加する方法

ダイアログにボタンを追加するには、`actions`プロパティを使用。`TextButton`や`ElevatedButton`を追加して、ユーザーの応答を処理。

### actionsのボタンについて

`actions`プロパティは、ダイアログの下部に表示されるボタンを指定。ユーザーの選択に応じて、ダイアログを閉じたり、他のアクションを実行。

### thenによるアラート後の処理

`showDialog`は非同期関数であり、`then`を使用してダイアログが閉じられた後の処理を行うことが可能。

#### 使用例

```dart
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Alert'),
      content: Text('This is an alert dialog.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop('OK');
          },
          child: Text('OK'),
        ),
      ],
    );
  },
).then((result) {
  print('Dialog closed with result: $result');
});
```

### まとめ

- `showDialog`を使用して、`AlertDialog`や`SimpleDialog`を表示。
- `actions`プロパティでボタンを追加し、ユーザーの応答を処理。
- `then`を使用して、ダイアログが閉じられた後の処理を行う。


