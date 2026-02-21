import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/value_objects/secret_data.dart';
import '../../domain/value_objects/lock_method.dart';
import 'encryption_providers.dart';
// import 'di/services_provider.dart'; // Removed
import 'package:nfc_toolkit/nfc_toolkit.dart';
import '../../application/services/capacity_calculator.dart';

// Actually NfcData exposes `ndef` which returns `Ndef?` from `nfc_manager`, so we might need it for type checking if we use it directly.
// The lint complained about unused import, so let's see.
// We used `Ndef` in `startCapacityScan` inside the new code `scanState.data.ndef`.
// `scanState.data` is `NfcData`. `NfcData` is imported from `../../application/services/nfc_data.dart`.
// `NfcData.ndef` returns `Ndef?` which is from `package:nfc_manager`.
// So we likely need `nfc_manager` import if we interact with `Ndef` object properties like `maxSize`.

import 'dart:typed_data';
import '../../infrastructure/repositories/draft_repository_impl.dart';

import 'creation_state.dart';
export 'creation_state.dart';

part 'creation_providers.g.dart';

// CreationState and CreationStep moved to creation_state.dart

@Riverpod(keepAlive: true)
class CreationNotifier extends _$CreationNotifier {
  @override
  CreationState build() {
    return const CreationState();
  }

  void reset() {
    state = const CreationState();
  }

  // ... (Existing methods selectMethod, nextFromMethodSelection etc.)
  void selectMethod(LockType type) {
    state = state.copyWith(selectedType: type, error: null);
  }

  void nextFromMethodSelection() {
    state = state.copyWith(step: CreationStep.capacityCheck, error: null);
  }

  // ... (Capacity check methods) ...
  // ... (Capacity check methods) ...
  Future<void> startCapacityScan({void Function(String)? onError}) async {
    final nfc = ref.read(nfcServiceProvider);
    state = state.copyWith(error: "タグをタッチしてください...");

    // Make sure we are in idle/valid state
    nfc.resetSession(onError: onError);

    try {
      final data = await nfc.backgroundTagStream.where((d) => d != null).first;
      final ndef = data!.ndef;
      int capacity = ndef?.maxSize ?? 137;

      state = state.copyWith(
        maxCapacity: capacity,
        step: CreationStep.inputData,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: "NFCエラー: $e");
    }
  }

  void selectManualCapacity(int capacity) {
    state = state.copyWith(
      maxCapacity: capacity,
      step: CreationStep.inputData,
      error: null,
      isEditMode: false,
    );
  }

  // Initialize for Edit Mode from SVS
  void initializeForEdit(
    SecretData secret,
    LockType type,
    bool isManualUnlockRequired,
    int capacity,
  ) {
    state = state.copyWith(
      items: secret.items,
      selectedType: type,
      isManualUnlockRequired: isManualUnlockRequired,
      maxCapacity: capacity,
      step: CreationStep.inputData, // Jump directly to Input Data
      isEditMode: true, // Mark as Edit Mode
      error: null,
      isDraftSaved: false,
      lockInput: "",
      firstInput: "",
      isConfirming: false,
    );
  }

  // ... (Item methods) ...
  void addItem(String key, String value) {
    if (value.isEmpty) return;
    state = state.copyWith(
      items: [
        ...state.items,
        SecretItem(key: key, value: value),
      ],
      error: null,
      isDraftSaved: false,
    );
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<SecretItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: newItems, isDraftSaved: false);
  }

  Future<void> saveDraft() async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: "保存するデータがありません");
      return;
    }
    try {
      final repo = ref.read(wizardDraftRepositoryProvider);
      await repo.saveDraft(state);
      state = state.copyWith(isDraftSaved: true, error: null);
    } catch (e) {
      state = state.copyWith(error: "保存に失敗しました: $e");
    }
  }

  Future<void> loadDraft() async {
    try {
      final repo = ref.read(wizardDraftRepositoryProvider);
      final draft = await repo.loadDraft();
      if (draft != null) {
        // Restore state but keep default step?
        // User said "Edit draft", so restoring full state is good.
        // But usually we start at inputData step if Items are present?
        // The draft saves 'step' as well.
        state = draft;
      }
    } catch (e) {
      state = state.copyWith(error: "復元に失敗しました: $e");
    }
  }

  Future<void> deleteDraft() async {
    final repo = ref.read(wizardDraftRepositoryProvider);
    await repo.deleteDraft();
    state = state.copyWith(isDraftSaved: false);
  }

  void nextFromInputData() {
    if (state.items.isEmpty) {
      state = state.copyWith(error: "1つ以上のデータを登録してください");
      return;
    }
    state = state.copyWith(step: CreationStep.lockConfig, error: null);
  }

  // --- Step 4: Lock Config ---
  void updateLockTypeInInput(LockType type) {
    state = state.copyWith(selectedType: type);
  }

  void updateUnlockPreference(bool isManualRequired) {
    state = state.copyWith(isManualUnlockRequired: isManualRequired);
  }

  void updateLockInput(String input) {
    state = state.copyWith(lockInput: input, error: null);
  }

  void retryLockInput() {
    state = state.copyWith(
      isConfirming: false,
      lockInput: "",
      firstInput: "",
      error: null,
    );
  }

  void nextFromLockConfig() {
    // ... implementation unchanged ...
    if (state.lockInput.isEmpty) {
      state = state.copyWith(error: "ロック解除キーを入力してください");
      return;
    }

    if ((state.selectedType == LockType.pin ||
            (state.selectedType == LockType.patternAndPin &&
                state.isLockSecondStage)) &&
        !RegExp(r'^\d+$').hasMatch(state.lockInput)) {
      state = state.copyWith(error: "PINは数字のみで入力してください");
      return;
    }

    if (!state.isConfirming) {
      state = state.copyWith(
        firstInput: state.lockInput,
        lockInput: "",
        isConfirming: true,
        error: null,
      );
    } else {
      if (state.lockInput != state.firstInput) {
        if (state.selectedType == LockType.pattern ||
            (state.selectedType == LockType.patternAndPin &&
                !state.isLockSecondStage)) {
          state = state.copyWith(
            error: "パターンが一致しません。再度入力してください",
            lockInput: "",
          );
        } else {
          state = state.copyWith(
            error: "入力内容が一致しません。最初からやり直してください。",
            lockInput: "",
            firstInput: "",
            isConfirming: false,
          );
        }
        return;
      }

      // Verification Successful
      if (state.selectedType == LockType.patternAndPin &&
          !state.isLockSecondStage) {
        // Pattern verified, move to PIN
        state = state.copyWith(
          isLockSecondStage: true,
          tempFirstLockInput: state.firstInput, // Save validated pattern
          firstInput: "",
          lockInput: "",
          isConfirming: false,
          error: null,
        );
      } else {
        // All done (or Single stage done)
        state = state.copyWith(step: CreationStep.write, error: null);
      }
    }
  }

  // --- Step 5: Write ---
  Future<void> writeToNfc({void Function(String)? onError}) async {
    String verificationHash = state.lockInput;
    if (state.selectedType == LockType.patternAndPin) {
      // Combine [Pattern]:[PIN]
      // Assuming PIN is currently in lockInput (validated)
      // and Pattern is in tempFirstLockInput
      verificationHash = "${state.tempFirstLockInput}:${state.lockInput}";
    }

    final lockMethod = LockMethod(
      type: state.selectedType,
      verificationHash: verificationHash,
      salt: null,
    );
    final secretData = SecretData(items: state.items);

    try {
      final encService = ref.read(encryptionServiceProvider);
      final encryptedBytes = await encService.encrypt(secretData, lockMethod);

      // Opaque Blob with Optional Hint
      // Format: [Hint (1 byte)] + [Encrypted Blob]
      // Hint: 0x00 (Unknown/Secure), else index+1
      // FIXED: Specifically check for automatic unlock preference
      int hintByte = 0x00;
      if (!state.isManualUnlockRequired) {
        hintByte = state.selectedType.index + 1;
      }
      // Debug print for verification (Remove in production or use logger)
      // print('DEBUG: Writing HintByte: $hintByte, ManualUnlockRequired: ${state.isManualUnlockRequired}, SelectedType: ${state.selectedType}');

      final payloadBuilder = BytesBuilder();
      payloadBuilder.addByte(hintByte);
      payloadBuilder.add(encryptedBytes);

      final payloadBytes = payloadBuilder.toBytes();

      // Check capacity
      // We use CapacityCalculator for pre-check, but here we can also just check the final payload + estimated NDEF overhead.
      // Or simply trust the exact calculation.
      final estimatedTotal = CapacityCalculator.calculateTotalBytes(
        state.items,
      );
      if (estimatedTotal > state.maxCapacity && state.maxCapacity > 0) {
        state = state.copyWith(
          error: "データサイズが大きすぎます ($estimatedTotal / ${state.maxCapacity} bytes)",
        );
        return;
      }

      // Create NDEF Message  -- Removed manual construction
      // final record = NdefRecord(...)
      // final message = NdefMessage(...)

      final nfc = ref.read(nfcServiceProvider);

      void handleWrite(bool allowOverwrite) async {
        try {
          final stream = await nfc.startWrite([
            NfcWriteDataUri(
              Uri.parse('https://static-site-wzq.pages.dev/unlock'),
            ),
            NfcWriteDataMime('application/portablesec', payloadBytes),
          ], allowOverwrite: allowOverwrite);

          stream.listen(
            (writeState) {
              if (writeState is NfcWriteSuccess) {
                // Determine if we should pause scanning
                // While the Success Dialog is open, we don't want the OS or App to re-scan this tag immediately.
                // Refactored: We keep the session open! This prevents the OS from firing new discovery intents.
                // We will reset the session (and thus close the write session) when the user clicks OK.
                // ref.read(isNfcScanPausedProvider.notifier).state = true;

                // nfc.resetSession(); // DELAYED until finishWriting
                state = state.copyWith(isSuccess: true, error: null);
              } else if (writeState is NfcWriteOverwriteRequired) {
                // Auto-confirm overwrite
                handleWrite(true);
              } else if (writeState is NfcCapacityError) {
                state = state.copyWith(error: writeState.message);
                nfc.resetSession();
              } else if (writeState is NfcWriteError) {
                state = state.copyWith(error: "書き込みエラー: ${writeState.message}");
                nfc.resetSession();
              }
            },
            onError: (err) {
              state = state.copyWith(error: "NFCエラー: $err");
              nfc.resetSession();
            },
            cancelOnError: true,
          );
        } catch (e) {
          state = state.copyWith(error: "開始エラー: $e");
          nfc.resetSession();
        }
      }

      handleWrite(false);

      state = state.copyWith(error: "タグをタッチしてください...");
    } catch (e) {
      state = state.copyWith(error: "準備エラー: $e");
    }
  }

  void finishWriting() {
    // Reset success state
    state = state.copyWith(isSuccess: false, error: null);

    // Close the write session and resume background listening
    ref.read(nfcServiceProvider).resetSession();

    // Go back to Home happens in UI
  }

  void backToMethodSelection() {
    state = state.copyWith(step: CreationStep.methodSelection, error: null);
  }

  void backToCapacityCheck() {
    state = state.copyWith(step: CreationStep.capacityCheck, error: null);
  }

  void backToInputData() {
    state = state.copyWith(step: CreationStep.inputData, error: null);
  }

  void backToLockConfig() {
    state = state.copyWith(step: CreationStep.lockConfig, error: null);
  }
}
