import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/services/user_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

enum WorkerConversionStatus {
  idle,
  validating, // debounce fired, Firestore query in progress
  valid, // code found and inviter has availableUpdates > 0
  invalidCode, // code not found
  noSlots, // inviter found but availableUpdates == 0
  converting, // transaction in progress
  success, // role changed to worker
  error, // unexpected error
}

class WorkerConversionState {
  final WorkerConversionStatus status;
  final InviterInfo? inviter; // non-null when status == valid
  final String? errorMessage; // non-null when status == error

  const WorkerConversionState({
    this.status = WorkerConversionStatus.idle,
    this.inviter,
    this.errorMessage,
  });

  WorkerConversionState copyWith({
    WorkerConversionStatus? status,
    InviterInfo? inviter,
    String? errorMessage,
  }) => WorkerConversionState(
    status: status ?? this.status,
    inviter: inviter ?? this.inviter,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  /// Convenience getters used by the UI.
  bool get isLoading =>
      status == WorkerConversionStatus.validating ||
      status == WorkerConversionStatus.converting;

  bool get canConfirm => status == WorkerConversionStatus.valid;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WorkerConversionNotifier extends StateNotifier<WorkerConversionState> {
  final UserRepository _repo;
  final String _currentUserId;

  WorkerConversionNotifier(this._repo, this._currentUserId)
    : super(const WorkerConversionState());

  /// Called by the debounced TextField listener.
  Future<void> validateCode(String code) async {
    if (code.trim().isEmpty) {
      state = const WorkerConversionState();
      return;
    }

    state = const WorkerConversionState(
      status: WorkerConversionStatus.validating,
    );

    try {
      final inviter = await _repo.lookupReferralCode(code.trim());
      state = WorkerConversionState(
        status: WorkerConversionStatus.valid,
        inviter: inviter,
      );
    } on InvalidReferralCodeException {
      state = const WorkerConversionState(
        status: WorkerConversionStatus.invalidCode,
      );
    } on NoAvailableUpdatesException {
      state = const WorkerConversionState(
        status: WorkerConversionStatus.noSlots,
      );
    } catch (e) {
      state = WorkerConversionState(
        status: WorkerConversionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Called when the user taps "Confirmar". Only proceeds when state is valid.
  Future<void> confirm(String referralCode) async {
    if (!state.canConfirm) return;

    state = state.copyWith(status: WorkerConversionStatus.converting);

    try {
      await _repo.convertToWorker(
        userId: _currentUserId,
        referralCode: referralCode.trim(),
      );
      state = state.copyWith(status: WorkerConversionStatus.success);
    } on InvalidReferralCodeException {
      state = const WorkerConversionState(
        status: WorkerConversionStatus.invalidCode,
      );
    } on NoAvailableUpdatesException {
      state = const WorkerConversionState(
        status: WorkerConversionStatus.noSlots,
      );
    } catch (e) {
      state = WorkerConversionState(
        status: WorkerConversionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const WorkerConversionState();
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Scoped to the BecomeWorkerScreen — dispose on pop.
final workerConversionProvider =
    StateNotifierProvider.autoDispose<
      WorkerConversionNotifier,
      WorkerConversionState
    >((ref) {
      final repo = ref.watch(userRepositoryProvider);
      // currentUserStreamProvider emits AppUser? — we need the uid synchronously.
      // Use requireValue only after the UI has guarded for the loading state.
      final userAsync = ref.watch(currentUserStreamProvider);
      final uid = userAsync.valueOrNull?.uid ?? '';
      return WorkerConversionNotifier(repo, uid);
    });
