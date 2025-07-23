import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const EmotionDiaryApp());
}

class EmotionDiaryApp extends StatelessWidget {
  const EmotionDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '感情日記',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DiaryHomePage(),
    );
  }
}

class DiaryEntry {
  final String emoji;
  final Color color;
  final String note;
  final DateTime date;

  DiaryEntry({
    required this.emoji,
    required this.color,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'color': color.value,
    'note': note,
    'date': date.toIso8601String(),
  };

  static DiaryEntry fromJson(Map<String, dynamic> json) => DiaryEntry(
    emoji: json['emoji'],
    color: Color(json['color']),
    note: json['note'],
    date: DateTime.parse(json['date']),
  );
}

class EmotionCount {
  final String emoji;
  final int count;
  final Color color;
  EmotionCount(this.emoji, this.count, this.color);
}

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  final _noteController = TextEditingController();
  String _selectedEmoji = '😊';
  Color _selectedColor = Colors.blue;
  List<DiaryEntry> _entries = [];
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/emotion_diary.json');
  }

  Future<void> _saveEntries() async {
    final file = await _localFile;
    final jsonStr = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonStr);
  }

  Future<void> _loadEntries() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final list = jsonDecode(jsonStr) as List;
        setState(() {
          _entries = list.map((e) => DiaryEntry.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  void _addEntry() async {
    final entry = DiaryEntry(
      emoji: _selectedEmoji,
      color: _selectedColor,
      note: _noteController.text,
      date: DateTime.now(),
    );
    setState(() {
      _entries.insert(0, entry);
      _noteController.clear();
    });
    await _saveEntries();
  }

  void _editEntry(int idx) async {
    final entry = _entries[idx];
    final editNoteController = TextEditingController(text: entry.note);
    String editEmoji = entry.emoji;
    Color editColor = entry.color;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('記録の編集'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: editEmoji,
                    items:
                        [
                              '😊',
                              '😢',
                              '😡',
                              '😱',
                              '😴',
                              '😍',
                              '🤔',
                              '😇',
                              '😭',
                              '😆',
                            ]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) =>
                        setStateDialog(() => editEmoji = v ?? '😊'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<Color>(
                    value: editColor,
                    items:
                        [
                              Colors.blue,
                              Colors.red,
                              Colors.green,
                              Colors.yellow,
                              Colors.purple,
                              Colors.orange,
                            ]
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  color: c,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) =>
                        setStateDialog(() => editColor = v ?? Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: editNoteController,
                    decoration: const InputDecoration(hintText: '一言日記'),
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
                    setState(() {
                      _entries[idx] = DiaryEntry(
                        emoji: editEmoji,
                        color: editColor,
                        note: editNoteController.text,
                        date: entry.date,
                      );
                    });
                    await _saveEntries();
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteEntry(int idx) async {
    setState(() {
      _entries.removeAt(idx);
    });
    await _saveEntries();
  }

  Widget _buildRecordTab() {
    return Column(
      children: [
        Row(
          children: [
            DropdownButton<String>(
              value: _selectedEmoji,
              items:
                  ['😊', '😢', '😡', '😱', '😴', '😍', '🤔', '😇', '😭', '😆']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 24)),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _selectedEmoji = v ?? '😊'),
            ),
            const SizedBox(width: 16),
            DropdownButton<Color>(
              value: _selectedColor,
              items:
                  [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple,
                        Colors.orange,
                      ]
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Container(width: 24, height: 24, color: c),
                        ),
                      )
                      .toList(),
              onChanged: (v) =>
                  setState(() => _selectedColor = v ?? Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(hintText: '一言日記'),
              ),
            ),
            ElevatedButton(onPressed: _addEntry, child: const Text('記録')),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        const Text('履歴', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (context, idx) {
              final e = _entries[idx];
              return ListTile(
                leading: Text(e.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(e.note),
                subtitle: Text('${e.date.year}/${e.date.month}/${e.date.day}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 24, height: 24, color: e.color),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editEntry(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEntry(idx),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGraphTab() {
    final Map<String, EmotionCount> emotionMap = {};
    for (var e in _entries) {
      if (emotionMap.containsKey(e.emoji)) {
        emotionMap[e.emoji] = EmotionCount(
          e.emoji,
          emotionMap[e.emoji]!.count + 1,
          e.color,
        );
      } else {
        emotionMap[e.emoji] = EmotionCount(e.emoji, 1, e.color);
      }
    }
    final data = emotionMap.values.toList();
    if (data.isEmpty) {
      return const Center(child: Text('記録がありません'));
    }
    return Column(
      children: [
        const Text('感情傾向グラフ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: data
                  .map(
                    (e) => PieChartSectionData(
                      value: e.count.toDouble(),
                      color: e.color,
                      title: '${e.emoji}\n${e.count}',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiTab() {
    if (_entries.isEmpty) {
      return const Center(child: Text('記録がありません'));
    }
    final recent = _entries.first;
    final Map<String, int> emotionCount = {};
    for (var e in _entries) {
      emotionCount[e.emoji] = (emotionCount[e.emoji] ?? 0) + 1;
    }
    final mostEmotion = emotionCount.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final advice = _adviceForEmotion(mostEmotion);
    final quote = _quoteForEmotion(mostEmotion);
    final music = _musicForEmotion(mostEmotion);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最近の感情: ${recent.emoji}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('傾向: ${mostEmotion}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('AIアドバイス: $advice', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('名言: $quote', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('癒し音楽: $music', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _adviceForEmotion(String emoji) {
    switch (emoji) {
      case '😊':
        return 'その調子でポジティブに！';
      case '😢':
        return '無理せず、ゆっくり休もう。';
      case '😡':
        return '深呼吸してリラックスしよう。';
      case '😱':
        return '不安な時は誰かに相談してみて。';
      case '😴':
        return 'しっかり睡眠をとろう。';
      case '😍':
        return '好きなことに没頭しよう！';
      case '🤔':
        return '考えすぎず、気分転換も大切。';
      case '😇':
        return '自分を褒めてあげよう。';
      case '😭':
        return '涙も大事。心をリセットしよう。';
      case '😆':
        return 'たくさん笑って過ごそう！';
      default:
        return '今日もお疲れさま！';
    }
  }

  String _quoteForEmotion(String emoji) {
    switch (emoji) {
      case '😊':
        return '「笑う門には福来る」';
      case '😢':
        return '「雨の後には虹が出る」';
      case '😡':
        return '「怒りは一晩寝かせて」';
      case '😱':
        return '「心配事の9割は起こらない」';
      case '😴':
        return '「休むことも大切な仕事」';
      case '😍':
        return '「好きこそ物の上手なれ」';
      case '🤔':
        return '「案ずるより産むが易し」';
      case '😇':
        return '「自分を信じて」';
      case '😭':
        return '「涙の数だけ強くなれる」';
      case '😆':
        return '「笑顔は最強の魔法」';
      default:
        return '「今日という日は二度と来ない」';
    }
  }

  String _musicForEmotion(String emoji) {
    switch (emoji) {
      case '😊':
        return 'Happy - Pharrell Williams';
      case '😢':
        return 'Let It Be - The Beatles';
      case '😡':
        return 'Don\'t Worry Be Happy - Bobby McFerrin';
      case '😱':
        return 'Heal The World - Michael Jackson';
      case '😴':
        return 'Weightless - Marconi Union';
      case '😍':
        return 'Sugar - Maroon 5';
      case '🤔':
        return 'Imagine - John Lennon';
      case '😇':
        return 'Beautiful - Christina Aguilera';
      case '😭':
        return 'Story - AI';
      case '😆':
        return 'Can\'t Stop The Feeling! - Justin Timberlake';
      default:
        return '好きな音楽を聴こう！';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildRecordTab(),
      _buildHistoryTab(),
      _buildGraphTab(),
      _buildAiTab(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('感情日記')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tabs[_tabIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '記録'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '履歴'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'グラフ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'AIアシスト',
          ),
        ],
      ),
    );
  }
}
