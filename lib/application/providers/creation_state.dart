import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/value_objects/secret_data.dart';
import '../../domain/value_objects/lock_method.dart';

part 'creation_state.freezed.dart';
part 'creation_state.g.dart';

enum CreationStep {
  methodSelection, // Step 1: Select Lock Method
  capacityCheck, // Step 2: Check Tag Capacity
  inputData, // Step 3: Input Secret Data (Save Draft available)
  lockConfig, // Step 4: Configure Lock (PIN/Pass based on selection)
  write, // Step 5: Write to NFC
}

@freezed
abstract class CreationState with _$CreationState {
  const factory CreationState({
    @Default(CreationStep.methodSelection) CreationStep step,
    @Default([]) List<SecretItem> items,

    // Lock Configuration
    @Default("") String lockInput, // The raw pin/password input
    @Default(LockType.pin) LockType selectedType,

    // Confirmation Logic
    @Default(false) bool isConfirming,
    @Default("") String firstInput,

    // Tag Capacity
    @Default(0) int maxCapacity,

    // Validation/Error
    String? error,
    @Default(false) bool isSuccess,

    // Draft Status
    @Default(false) bool isDraftSaved,

    // Preferences
    @Default(true) bool isManualUnlockRequired,

    // For Pattern+PIN: Second stage (PIN input after Pattern)
    @Default(false) bool isLockSecondStage,
    @Default("") String tempFirstLockInput,

    // Edit Mode (from SVS)
    @Default(false) bool isEditMode,
  }) = _CreationState;

  factory CreationState.fromJson(Map<String, dynamic> json) =>
      _$CreationStateFromJson(json);
}
