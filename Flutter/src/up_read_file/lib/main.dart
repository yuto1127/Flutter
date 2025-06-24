import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ファイル読み書きアプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FileReadWritePage(),
    );
  }
}

class FileReadWritePage extends StatefulWidget {
  const FileReadWritePage({super.key});

  @override
  State<FileReadWritePage> createState() => _FileReadWritePageState();
}

class _FileReadWritePageState extends State<FileReadWritePage> {
  final TextEditingController _textController = TextEditingController();
  final List<FileData> _savedDataList = [];
  final String _dataDirectory = 'saved_data';
  bool _isWriteMode = true; // true: 書き込みモード, false: 読み込みモード

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // データディレクトリを取得
  Future<Directory> _getDataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${appDir.path}/$_dataDirectory');
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return dataDir;
  }

  // ファイルにデータを保存する
  Future<void> _saveToFile() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('テキストを入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final dataDir = await _getDataDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'data_$timestamp.txt';
      final file = File('${dataDir.path}/$fileName');

      // ファイルにテキストを書き込み
      await file.writeAsString(_textController.text.trim());

      // テキストフィールドを初期化
      _textController.clear();

      // ローカルのリストに追加
      setState(() {
        _savedDataList.add(
          FileData(
            fileName: fileName,
            content: _textController.text.trim(),
            timestamp: timestamp,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('データを保存しました（${_savedDataList.length}件目）'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存エラー: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ファイルからデータを読み込む
  Future<void> _loadFromFile() async {
    try {
      final dataDir = await _getDataDirectory();

      if (await dataDir.exists()) {
        final List<FileSystemEntity> files = await dataDir.list().toList();
        final List<FileData> loadedData = [];

        for (final file in files) {
          if (file is File && file.path.endsWith('.txt')) {
            try {
              final content = await file.readAsString();
              final fileName = file.path.split('/').last;
              final timestamp =
                  int.tryParse(
                    fileName.replaceAll('data_', '').replaceAll('.txt', ''),
                  ) ??
                  0;

              loadedData.add(
                FileData(
                  fileName: fileName,
                  content: content,
                  timestamp: timestamp,
                ),
              );
            } catch (e) {
              print('ファイル読み込みエラー: ${file.path} - $e');
            }
          }
        }

        // タイムスタンプでソート（新しい順）
        loadedData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        setState(() {
          _savedDataList.clear();
          _savedDataList.addAll(loadedData);
          _isWriteMode = false; // 読み込みモードに切り替え
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loadedData.length}件のデータを読み込みました'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        setState(() {
          _savedDataList.clear();
          _isWriteMode = false; // 読み込みモードに切り替え
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データディレクトリが見つかりません'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('読み込みエラー: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 特定のデータを削除する
  Future<void> _deleteData(int index) async {
    try {
      final dataDir = await _getDataDirectory();
      final fileData = _savedDataList[index];
      final file = File('${dataDir.path}/${fileData.fileName}');

      if (await file.exists()) {
        await file.delete();

        setState(() {
          _savedDataList.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データを削除しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除エラー: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ファイルの内容を表示するダイアログ
  void _showFileContent(FileData fileData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ファイル: ${fileData.fileName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '作成日時: ${DateTime.fromMillisecondsSinceEpoch(fileData.timestamp)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(fileData.content),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  // 書き込みモードに切り替え
  void _switchToWriteMode() {
    setState(() {
      _isWriteMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isWriteMode ? 'ファイル書き込みモード' : 'ファイル読み込みモード'),
        actions: [
          if (!_isWriteMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _switchToWriteMode,
              tooltip: '書き込みモードに切り替え',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // モード切り替えボタン
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isWriteMode ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isWriteMode ? Colors.blue[200]! : Colors.green[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWriteMode ? Icons.edit : Icons.folder_open,
                    color: _isWriteMode ? Colors.blue : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isWriteMode ? '書き込みモード' : '読み込みモード',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isWriteMode ? Colors.blue : Colors.green,
                    ),
                  ),
                  const Spacer(),
                  if (_isWriteMode && _savedDataList.isNotEmpty)
                    Text(
                      '保存データ: ${_savedDataList.length}件',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // テキストフィールド（書き込みモードのみ表示）
            if (_isWriteMode) ...[
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'テキストを入力してください',
                  hintText: 'ここにテキストを入力...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 保存されたデータの表示エリア
            if (_savedDataList.isNotEmpty) ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              '保存されたファイル (${_savedDataList.length}件):',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            if (_isWriteMode)
                              ElevatedButton.icon(
                                onPressed: _loadFromFile,
                                icon: const Icon(Icons.refresh),
                                label: const Text('更新'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _savedDataList.length,
                          itemBuilder: (context, index) {
                            final fileData = _savedDataList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  fileData.content,
                                  maxLines: _isWriteMode ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ファイル: ${fileData.fileName}'),
                                    Text(
                                      '作成: ${DateTime.fromMillisecondsSinceEpoch(fileData.timestamp)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _showFileContent(fileData),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteData(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ボタンエリア
            if (_isWriteMode) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveToFile,
                      icon: const Icon(Icons.save),
                      label: const Text('ファイルに保存'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadFromFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('ファイルを読み込み'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 読み込みモードのボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _switchToWriteMode,
                  icon: const Icon(Icons.edit),
                  label: const Text('書き込みモードに切り替え'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ファイルデータを管理するクラス
class FileData {
  final String fileName;
  final String content;
  final int timestamp;

  FileData({
    required this.fileName,
    required this.content,
    required this.timestamp,
  });
}
