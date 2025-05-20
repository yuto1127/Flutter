// Flutterのマテリアルデザインウィジェットをインポート
// これにより、MaterialAppやTextなどの基本的なウィジェットが使用可能になります
import 'package:flutter/material.dart';

// アプリケーションのエントリーポイントとなる関数
// Flutterアプリは必ずmain関数から開始されます
void main() {
  // runApp関数でアプリケーションを起動
  // MyAppウィジェットをルートとして設定
  runApp(MyApp());
}

// StatelessWidgetを継承したMyAppクラス
// StatelessWidgetは状態を持たないウィジェットで、
// 一度作成されると変更されない静的なUIを構築するのに適しています
class MyApp extends StatelessWidget {
  // buildメソッドはウィジェットのUIを構築するために呼び出されます
  // BuildContextはウィジェットツリーの位置情報を提供します
  @override
  Widget build(BuildContext context) {
    // MaterialAppはFlutterアプリケーションのルートウィジェット
    // マテリアルデザインのテーマやナビゲーションなどの基本機能を提供
    return MaterialApp(
      // アプリケーションのタイトル（主にAndroidのタスクマネージャーで表示）
      title: 'Flutter Demo',
      // アプリケーションのホーム画面を定義
      // Textウィジェットで「Hello,Flutter World!!」を表示
      home: Text(
        'Hello,Flutter World!!',
        // テキストのスタイルを設定
        // fontSizeで文字サイズを32.0に設定
        style: TextStyle(fontSize: 32.0),
      ),
    );
  }
}
