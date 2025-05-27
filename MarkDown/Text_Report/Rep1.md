#### 2025/05/20のまとめ
##### flutterのプロジェクトを作成したとき様々なフォルダ・ファイルが作成されるが主に変更を加えるのはlibフォルダのmain.dart
> main.dart
```
// Flutterのマテリアルデザインウィジェットをインポート
import 'package:flutter/material.dart';

// アプリケーションのエントリーポイント
void main() {
  // MyAppウィジェットをルートとして実行
  runApp(MyApp());
}

// StatelessWidgetを継承したMyAppクラス
// 状態を持たない静的なUIを構築
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialAppはFlutterアプリケーションのルートウィジェット
    return MaterialApp(
      // アプリケーションのタイトル
      title: 'Flutter Demo',
      // Scaffoldはマテリアルデザインの基本的なレイアウト構造を提供
      home: Scaffold(
        // アプリバーの設定
        appBar: AppBar(
          // アプリバーのタイトル
          title: Text('Hello Flutter!'),
        ),
        // メインコンテンツ部分
        body: Text(
          'Hello,Flutter World!!',
          // テキストのスタイル設定
          style: TextStyle(fontSize: 32.0),
        ),
      ),
    );
  }
}
```

画面表示は**ウィジェット**と呼ばれる部品によって作成される
アプリ画面はウィジェットを**階層的に**組み込んで構成していき、
その構造を**ウィジェットツリー**と呼ぶ


## アプリ実行の仕組み
Flutterアプリケーションはmain()関数から実行される
```
// アプリケーションのエントリーポイント
void main() {
  // ウィジェットをルートとして実行
  runApp(ウィジェット);
}
```
---

## StatelessWidgetクラス
runApp関数の引数に指定されているのは、MyAppクラスのインスタンス。
このクラスは**StatelessWidget**というクラスのサブクラスである。
>StatelessWidgetはステート（状態を表す値）を持たないウィジェットのベース
```
class クラス名 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
    );
  }
}
```
このクラスのウィジェットは特にデザインを扱うことはなくStatelessWidgetでMaterialAppをreturnすることでマテリアルデザインによるアプリの表示が行われる。

MaterialAppのインスタンスを作成する際、画面に表示するウィジェットを引数に設定。

すべてのクラスは**Widget**tというクラスのサブクラスとして用意され、このサブクラスのインスタンスを生成し、MaterialAppに組み込んでreturnすることでウィジェットとして画面に組み込まれ表示される。

---

**build**メソッドでは、**BuildContext**というクラスのインスタンスが引数として渡される。
>BuildContextは組み込まれたウィジェットに関する機能がまとめられたもので、ウィジェットの組み込み状態（ウィジェットが組み込まれている親や子の情報などに関する機能が揃っている

## MaterialAppクラス

```
return MaterialApp(
  title:'Flutter Demo',
  home:Text(
    'Hello, Flutter World!!',
    style:TextStyle(fontSize:32.0),
  ),
);
```

ここではtitleとhomeという２つの名前付き引数が用意されています。
titleはアプリケーションのタイトルを
homeは、このアプリケーションに組み込まれるウィジェットを示すもの。
>homeで指定されたウィジェットがMaterialAppの表示になる

---

## Flutterのマテリアルデザイン

## 概要
マテリアルデザインは、Googleが提唱するデザインシステムで、視覚的な一貫性とユーザー体験の向上を目的としています。Flutterはこのマテリアルデザインを簡単に実装できるように設計されている。

## 主なウィジェット

- **MaterialApp**: アプリ全体の設定を行うルートウィジェット。
- **Scaffold**: アプリの基本的なレイアウト構造を提供するウィジェット。
- **AppBar**: アプリの上部に表示されるバーで、タイトルやアクションを配置可能。
- **Text**: テキストを表示するためのウィジェット。
- **Button**: ユーザーの操作を受け付けるためのボタンウィジェット。

## 特徴

- **一貫性**: マテリアルデザインは、アプリ全体で一貫したデザインを提供
- **レスポンシブ**: さまざまなデバイスサイズに対応したデザインが可能
- **カスタマイズ性**: デフォルトのスタイルを簡単にカスタマイズできる

## 例

基本的なマテリアルデザインを使用したFlutterアプリの例

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hello Flutter!'),
        ),
        body: Center(
          child: Text(
            'Hello, Flutter World!',
            style: TextStyle(fontSize: 32.0),
          ),
        ),
      ),
    );
  }
}
```

# ScaffoldとAppBar

## Scaffold

### 概要
`Scaffold`は、Flutterアプリの基本的なレイアウト構造を提供するウィジェットで、アプリの主要なUI要素を配置するための土台。

### 主なプロパティ
- **appBar**: アプリの上部に表示される`AppBar`ウィジェットを設定
- **body**: アプリのメインコンテンツを配置するための領域
- **floatingActionButton**: 画面の右下に表示されるフローティングアクションボタンを設定
- **drawer**: 画面の左側からスライドして表示されるナビゲーションドロワーを設定

### 例
```dart
Scaffold(
  appBar: AppBar(
    title: Text('My App'),
  ),
  body: Center(
    child: Text('Hello, World!'),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

## AppBar

### 概要
`AppBar`は、アプリの上部に表示されるバーで、タイトルやアクションボタンを配置するために使用される

### 主なプロパティ
- **title**: バーの中央に表示されるタイトルを設定
- **actions**: バーの右側に表示されるアクションボタンのリストを設定
- **leading**: バーの左側に表示されるウィジェットを設定します。通常、ナビゲーションアイコンが配置される
- **backgroundColor**: バーの背景色を設定

### 例
```dart
AppBar(
  title: Text('My App'),
  actions: <Widget>[
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)
```

# appBarプロパティとAppBarクラス

## appBarプロパティ

### 概要
`appBar`プロパティは、`Scaffold`ウィジェットの一部で、アプリの上部に表示される`AppBar`ウィジェットを設定するために使用

### 特徴
- `appBar`プロパティに`AppBar`ウィジェットを指定することで、アプリの上部にナビゲーションバーを表示できる
- `AppBar`にはタイトルやアクションボタンを配置することができる

### 使用例
```dart
Scaffold(
  appBar: AppBar(
    title: Text('My App'),
  ),
  body: Center(
    child: Text('Hello, World!'),
  ),
)
```

## AppBarクラス

### 概要
`AppBar`クラスは、アプリの上部に表示されるバーを作成するためのウィジェット。タイトル、アクションボタン、ナビゲーションアイコンなどを配置することができる。

### 主なプロパティ
- **title**: バーの中央に表示されるタイトルを設定。
- **actions**: バーの右側に表示されるアクションボタンのリストを設定
- **leading**: バーの左側に表示されるウィジェットを設定します。通常、ナビゲーションアイコンが配置される
- **backgroundColor**: バーの背景色を設定
- **elevation**: バーの影の深さを設定

### 使用例
```dart
AppBar(
  title: Text('My App'),
  actions: <Widget>[
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)
```


# bodyプロパティ

## 概要
`body`プロパティは、`Scaffold`ウィジェットの一部で、アプリのメインコンテンツを配置するための領域を指定。この領域には、さまざまなウィジェットを配置して、アプリの主要なUIを構築。

## 特徴
- `body`プロパティには、`Widget`を指定して、アプリのメインコンテンツを定義
- `Column`や`Row`、`ListView`などのレイアウトウィジェットを使用して、複雑なUIを構築することができる
- `Center`ウィジェットを使用して、コンテンツを中央に配置することができる

## 使用例
```dart
Scaffold(
  appBar: AppBar(
    title: Text('My App'),
  ),
  body: Center(
    child: Text('Hello, World!'),
  ),
)
```

この例では、`body`プロパティに`Center`ウィジェットを指定し、その中に`Text`ウィジェットを配置。これにより、テキストが画面の中央に表示される。
