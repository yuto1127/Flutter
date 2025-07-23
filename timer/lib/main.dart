import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'web_audio_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web用音声ヘルパーの初期化
  WebAudioHelper.initialize();

  // 通知の初期化（モバイルのみ）
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ポモドーロタイマー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B73FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PomodoroTimerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  int _workDuration = 25; // 分
  int _breakDuration = 5; // 分
  int _longBreakDuration = 15; // 分
  int _sets = 4;
  int _currentSet = 1;
  int _currentTime = 0;
  int _totalTime = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  TimerState _currentState = TimerState.work;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupAnimation();
    _setupNotifications();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  void _setupNotifications() {
    // Webとデスクトップでは通知を無効化
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'pomodoro_timer',
          'ポモドーロタイマー',
          channelDescription: 'ポモドーロタイマーの通知',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workDuration = prefs.getInt('workDuration') ?? 25;
      _breakDuration = prefs.getInt('breakDuration') ?? 5;
      _longBreakDuration = prefs.getInt('longBreakDuration') ?? 15;
      _sets = prefs.getInt('sets') ?? 4;
    });
    _resetTimer();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDuration', _workDuration);
    await prefs.setInt('breakDuration', _breakDuration);
    await prefs.setInt('longBreakDuration', _longBreakDuration);
    await prefs.setInt('sets', _sets);
  }

  void _resetTimer() {
    _currentTime = _workDuration * 60;
    _totalTime = _currentTime;
    _currentState = TimerState.work;
    _currentSet = 1;
    _animationController.reset();
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentTime > 0) {
            _currentTime--;

            // 5秒前に警告音を鳴らす
            if (_currentTime == 5) {
              _playWarningSound();
            }

            // 時間切れ
            if (_currentTime == 0) {
              _handleTimerComplete();
            }
          }
        });
      });

      _animationController.repeat();
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      setState(() {
        _isPaused = true;
      });
      _timer.cancel();
      _animationController.stop();
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      _startTimer();
    }
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    _timer.cancel();
    _animationController.stop();
    _resetTimer();
  }

  void _playWarningSound() async {
    if (kIsWeb) {
      WebAudioHelper.playWarningSound();
      return;
    }

    try {
      await _audioPlayer.play(AssetSource('audio/warning.mp3'));
    } catch (e) {
      // 音声ファイルがない場合はシステム音を鳴らす
      HapticFeedback.mediumImpact();
    }
  }

  void _playCompleteSound() async {
    if (kIsWeb) {
      WebAudioHelper.playCompleteSound();
      return;
    }

    try {
      await _audioPlayer.play(AssetSource('audio/complete.mp3'));
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }

  void _handleTimerComplete() {
    _playCompleteSound();
    _showNotification();

    if (_currentState == TimerState.work) {
      if (_currentSet < _sets) {
        setState(() {
          _currentState = TimerState.break_;
          _currentTime = _breakDuration * 60;
          _totalTime = _currentTime;
        });
      } else {
        setState(() {
          _currentState = TimerState.longBreak;
          _currentTime = _longBreakDuration * 60;
          _totalTime = _currentTime;
        });
      }
    } else if (_currentState == TimerState.break_) {
      setState(() {
        _currentState = TimerState.work;
        _currentSet++;
        _currentTime = _workDuration * 60;
        _totalTime = _currentTime;
      });
    } else {
      // 長い休憩が終了
      _stopTimer();
    }
  }

  void _showNotification() {
    String title = '';
    String body = '';

    switch (_currentState) {
      case TimerState.work:
        title = '作業時間終了！';
        body = '休憩時間です。';
        break;
      case TimerState.break_:
        title = '休憩時間終了！';
        body = '次のセットを開始します。';
        break;
      case TimerState.longBreak:
        title = '長い休憩終了！';
        body = 'お疲れさまでした！';
        break;
    }

    if (kIsWeb) {
      WebAudioHelper.showWebNotification(title, body);
    } else if (Platform.isAndroid || Platform.isIOS) {
      _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(),
      );
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getStateColor() {
    switch (_currentState) {
      case TimerState.work:
        return const Color(0xFFE74C3C);
      case TimerState.break_:
        return const Color(0xFF27AE60);
      case TimerState.longBreak:
        return const Color(0xFF3498DB);
    }
  }

  String _getStateText() {
    switch (_currentState) {
      case TimerState.work:
        return '作業時間';
      case TimerState.break_:
        return '休憩時間';
      case TimerState.longBreak:
        return '長い休憩';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ポモドーロタイマー',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // プログレス円
            Expanded(
              flex: 4,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: 320,
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // プログレス円
                          SizedBox(
                            width: 320,
                            height: 320,
                            child: CircularProgressIndicator(
                              value: _totalTime > 0
                                  ? (_totalTime - _currentTime) / _totalTime
                                  : 0,
                              strokeWidth: 16,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStateColor(),
                              ),
                            ),
                          ),
                          // 中央のコンテンツ
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getStateText(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _formatTime(_currentTime),
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: _getStateColor(),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStateColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'セット $_currentSet / $_sets',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _getStateColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
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
            ),

            // コントロールボタン
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // メインボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isRunning)
                        _buildControlButton(
                          '開始',
                          Icons.play_arrow,
                          _getStateColor(),
                          _startTimer,
                        )
                      else if (_isPaused)
                        _buildControlButton(
                          '再開',
                          Icons.play_arrow,
                          _getStateColor(),
                          _resumeTimer,
                        )
                      else
                        _buildControlButton(
                          '一時停止',
                          Icons.pause,
                          _getStateColor(),
                          _pauseTimer,
                        ),

                      _buildControlButton(
                        'リセット',
                        Icons.stop,
                        Colors.grey[600]!,
                        _stopTimer,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 設定表示
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSettingItem(
                          '作業',
                          '$_workDuration分',
                          Colors.red[100]!,
                        ),
                        _buildSettingItem(
                          '休憩',
                          '$_breakDuration分',
                          Colors.green[100]!,
                        ),
                        _buildSettingItem(
                          '長い休憩',
                          '$_longBreakDuration分',
                          Colors.blue[100]!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        workDuration: _workDuration,
        breakDuration: _breakDuration,
        longBreakDuration: _longBreakDuration,
        sets: _sets,
        onSave: (work, break_, longBreak, sets) {
          setState(() {
            _workDuration = work;
            _breakDuration = break_;
            _longBreakDuration = longBreak;
            _sets = sets;
          });
          _saveSettings();
          _resetTimer();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum TimerState { work, break_, longBreak }

class SettingsDialog extends StatefulWidget {
  final int workDuration;
  final int breakDuration;
  final int longBreakDuration;
  final int sets;
  final Function(int, int, int, int) onSave;

  const SettingsDialog({
    super.key,
    required this.workDuration,
    required this.breakDuration,
    required this.longBreakDuration,
    required this.sets,
    required this.onSave,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int _workDuration;
  late int _breakDuration;
  late int _longBreakDuration;
  late int _sets;

  @override
  void initState() {
    super.initState();
    _workDuration = widget.workDuration;
    _breakDuration = widget.breakDuration;
    _longBreakDuration = widget.longBreakDuration;
    _sets = widget.sets;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('設定'),
          const SizedBox(height: 4),
          Text(
            '※ すべての値は1以上に設定してください',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDurationSetting('作業時間', _workDuration, (value) {
            setState(() => _workDuration = value);
          }),
          _buildDurationSetting('休憩時間', _breakDuration, (value) {
            setState(() => _breakDuration = value);
          }),
          _buildDurationSetting('長い休憩時間', _longBreakDuration, (value) {
            setState(() => _longBreakDuration = value);
          }),
          _buildDurationSetting('セット数', _sets, (value) {
            setState(() => _sets = value);
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed:
              (_workDuration > 0 &&
                  _breakDuration > 0 &&
                  _longBreakDuration > 0 &&
                  _sets > 0)
              ? () {
                  widget.onSave(
                    _workDuration,
                    _breakDuration,
                    _longBreakDuration,
                    _sets,
                  );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildDurationSetting(
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: Icon(
                  Icons.remove,
                  color: value > 0 ? null : Colors.grey[400],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: value > 0 ? Colors.grey[100] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: value == 0
                      ? Border.all(color: Colors.red[300]!, width: 1)
                      : null,
                ),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: value == 0 ? Colors.red[600] : null,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
