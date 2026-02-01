import '../value_objects/draft_record.dart';

abstract class DraftRepository {
  Future<List<DraftRecord>> getAllDrafts();
  Future<DraftRecord?> getDraft(String id);
  Future<void> saveDraft(DraftRecord draft);
  Future<void> deleteDraft(String id);
}
