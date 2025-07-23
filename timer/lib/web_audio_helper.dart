import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

class WebAudioHelper {
  static html.AudioElement? _warningAudio;
  static html.AudioElement? _completeAudio;

  static void initialize() {
    if (kIsWeb) {
      try {
        _warningAudio = html.AudioElement()
          ..src = 'assets/audio/warning.mp3'
          ..preload = 'auto';

        _completeAudio = html.AudioElement()
          ..src = 'assets/audio/complete.mp3'
          ..preload = 'auto';
      } catch (e) {
        // 音声ファイルがない場合は無視
      }
    }
  }

  static void playWarningSound() {
    if (kIsWeb && _warningAudio != null) {
      try {
        _warningAudio!.play();
      } catch (e) {
        // 音声再生に失敗した場合は無視
      }
    }
  }

  static void playCompleteSound() {
    if (kIsWeb && _completeAudio != null) {
      try {
        _completeAudio!.play();
      } catch (e) {
        // 音声再生に失敗した場合は無視
      }
    }
  }

  static void showWebNotification(String title, String body) {
    if (kIsWeb) {
      try {
        // Web通知APIを使用
        if (html.window.navigator.permissions != null) {
          html.window.navigator.permissions!
              .query({'name': 'notifications'})
              .then((permission) {
                if (permission.state == 'granted') {
                  html.Notification.requestPermission().then((permission) {
                    if (permission == 'granted') {
                      html.Notification(title, body: body);
                    }
                  });
                }
              });
        }
      } catch (e) {
        // 通知が利用できない場合は無視
      }
    }
  }
}
