// Currently disabled as we focus on Wizard Draft (Single File)
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import '../../domain/value_objects/draft_record.dart';
// import '../../domain/repositories/draft_repository.dart';
// import '../../infrastructure/repositories/draft_repository_impl.dart';

// part 'draft_providers.g.dart';

// // Repository Provider
// @riverpod
// DraftRepository draftRepository(Ref ref) {
//   // return DraftRepositoryImpl(); // Mismatch: implementation is currently for Wizard (CreationState)
//   throw UnimplementedError();
// }

// // Controller / Notifier for the Draft List
// /*
// @riverpod
// class DraftListController extends _$DraftListController {
//   @override
//   Future<List<DraftRecord>> build() async {
//     final repo = ref.watch(draftRepositoryProvider);
//     return repo.getAllDrafts();
//   }

//   Future<void> refresh() async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final repo = ref.read(draftRepositoryProvider);
//       return repo.getAllDrafts();
//     });
//   }

//   Future<void> deleteDraft(String id) async {
//     final repo = ref.read(draftRepositoryProvider);
//     await repo.deleteDraft(id);
//     await refresh();
//   }
// }
// */
