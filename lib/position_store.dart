import 'package:shared_preferences/shared_preferences.dart';

class PositionStore {
  static const String _posPrefix = 'pos_';
  static const String _durPrefix = 'dur_';

  Future<Duration?> getPosition(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('$_posPrefix$url');
    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }

  Future<void> savePosition(String url, Duration position, Duration? total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_posPrefix$url', position.inMilliseconds);
    if (total != null) {
      await prefs.setInt('$_durPrefix$url', total.inMilliseconds);
    }
  }

  Future<void> clear(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_posPrefix$url');
    await prefs.remove('$_durPrefix$url');
  }
}