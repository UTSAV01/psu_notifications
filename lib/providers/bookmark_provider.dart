import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a provider we can call from anywhere
final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, List<String>>((ref) {
  return BookmarkNotifier();
});

class BookmarkNotifier extends StateNotifier<List<String>> {
  static const _key = 'saved_psu_jobs';

  BookmarkNotifier() : super([]) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    state = saved;
  }

  Future<void> toggleBookmark(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentSaved = prefs.getStringList(_key) ?? [];
    
    if (currentSaved.contains(jobId)) {
      currentSaved.remove(jobId);
    } else {
      currentSaved.add(jobId);
    }
    
    // Save to Disk
    await prefs.setStringList(_key, currentSaved);
    // Update Riverpod State
    state = currentSaved;
  }
}
