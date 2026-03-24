// lib/providers/draft_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a "new task" draft so text survives navigation and app minimization.
class DraftProvider extends ChangeNotifier {
  static const _keyTitle = 'draft_title';
  static const _keyDescription = 'draft_description';

  String _title = '';
  String _description = '';

  String get title => _title;
  String get description => _description;

  bool get hasDraft => _title.isNotEmpty || _description.isNotEmpty;

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    _title = prefs.getString(_keyTitle) ?? '';
    _description = prefs.getString(_keyDescription) ?? '';
    notifyListeners();
  }

  Future<void> saveDraft({required String title, required String description}) async {
    _title = title;
    _description = description;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTitle, title);
    await prefs.setString(_keyDescription, description);
    // No notifyListeners() here — called continuously on every keystroke
  }

  Future<void> clearDraft() async {
    _title = '';
    _description = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTitle);
    await prefs.remove(_keyDescription);
    notifyListeners();
  }
}