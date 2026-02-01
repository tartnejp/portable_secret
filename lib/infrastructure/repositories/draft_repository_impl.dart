import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/providers/creation_state.dart';

part 'draft_repository_impl.g.dart';

@riverpod
WizardDraftRepository wizardDraftRepository(Ref ref) {
  return WizardDraftRepositoryImpl();
}

abstract class WizardDraftRepository {
  Future<void> saveDraft(CreationState state);
  Future<CreationState?> loadDraft();
  Future<void> deleteDraft();
  Future<bool> hasDraft();
}

class WizardDraftRepositoryImpl implements WizardDraftRepository {
  static const _key = 'creation_draft';

  @override
  Future<void> saveDraft(CreationState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.toJson());
    await prefs.setString(_key, jsonStr);
  }

  @override
  Future<CreationState?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;
    try {
      final jsonMap = jsonDecode(jsonStr);
      return CreationState.fromJson(jsonMap);
    } catch (e) {
      // Invalidate if schema changed
      await deleteDraft();
      return null;
    }
  }

  @override
  Future<void> deleteDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  @override
  Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }
}
