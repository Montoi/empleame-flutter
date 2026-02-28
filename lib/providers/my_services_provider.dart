import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/services/service_repository.dart';

// ── Repository provider ──────────────────────────────────────────────────────

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

// ── Worker's services stream ─────────────────────────────────────────────────

/// Emits the real-time list of services for the current worker.
final myServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final uid = ref.watch(currentUserStreamProvider).valueOrNull?.uid ?? '';
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(serviceRepositoryProvider).watchWorkerServices(uid);
});

// ── Form state ───────────────────────────────────────────────────────────────

class ServiceFormState {
  final String title;
  final String category;
  final String description;
  final String rate; // kept as String for TextField binding
  final List<File> localImages;
  final bool isSaving;
  final String? error;

  /// When editing, holds the original service being edited.
  final ServiceModel? editing;

  const ServiceFormState({
    this.title = '',
    this.category = '',
    this.description = '',
    this.rate = '',
    this.localImages = const [],
    this.isSaving = false,
    this.error,
    this.editing,
  });

  bool get isValid =>
      title.trim().isNotEmpty &&
      category.isNotEmpty &&
      description.trim().isNotEmpty &&
      (double.tryParse(rate) ?? 0) > 0;

  ServiceFormState copyWith({
    String? title,
    String? category,
    String? description,
    String? rate,
    List<File>? localImages,
    bool? isSaving,
    String? error,
    ServiceModel? editing,
  }) => ServiceFormState(
    title: title ?? this.title,
    category: category ?? this.category,
    description: description ?? this.description,
    rate: rate ?? this.rate,
    localImages: localImages ?? this.localImages,
    isSaving: isSaving ?? this.isSaving,
    error: error, // explicit null clears it
    editing: editing ?? this.editing,
  );
}

class ServiceFormNotifier extends StateNotifier<ServiceFormState> {
  final ServiceRepository _repo;
  final String _workerId;

  ServiceFormNotifier(this._repo, this._workerId)
    : super(const ServiceFormState());

  void loadForEdit(ServiceModel service) {
    state = ServiceFormState(
      title: service.title,
      category: service.category,
      description: service.description,
      rate: service.rate.toStringAsFixed(0),
      editing: service,
    );
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setCategory(String v) => state = state.copyWith(category: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setRate(String v) => state = state.copyWith(rate: v);
  void setImages(List<File> files) =>
      state = state.copyWith(localImages: files);
  void addImages(List<File> files) =>
      state = state.copyWith(localImages: [...state.localImages, ...files]);
  void removeImage(int index) {
    final updated = [...state.localImages]..removeAt(index);
    state = state.copyWith(localImages: updated);
  }

  void reset() => state = const ServiceFormState();

  Future<String?> save() async {
    if (!state.isValid) return null;
    state = state.copyWith(isSaving: true);

    try {
      // ── Placeholder image URLs (Spark plan) ─────────────────────────────
      // Each local photo gets a picsum placeholder so the Firestore doc has
      // at least one image URL even without Firebase Storage.
      final placeholders = state.localImages.isEmpty
          ? ['https://picsum.photos/seed/$_workerId/400/300']
          : List.generate(
              state.localImages.length,
              (i) => 'https://picsum.photos/seed/${_workerId}_$i/400/300',
            );

      // --- STORAGE UPLOAD (uncomment when Blaze plan active) ---------------
      // final storageRef = FirebaseStorage.instance.ref('services/$workerId');
      // final uploadedUrls = <String>[];
      // for (int i = 0; i < state.localImages.length; i++) {
      //   final compressed = await FlutterImageCompress.compressAndGetFile(
      //     state.localImages[i].absolute.path,
      //     '${state.localImages[i].path}_compressed.jpg',
      //     quality: 75,
      //   );
      //   final file = compressed ?? state.localImages[i];
      //   final task = storageRef.child('$i.jpg').putFile(file);
      //   final snap = await task;
      //   uploadedUrls.add(await snap.ref.getDownloadURL());
      // }
      // final imageUrls = uploadedUrls;
      // -----------------------------------------------------------------------

      final model = ServiceModel(
        id: state.editing?.id ?? '',
        title: state.title.trim(),
        category: state.category,
        description: state.description.trim(),
        rate: double.parse(state.rate),
        workerId: _workerId,
        imageUrls: placeholders,
        status: 'pending_review',
      );

      String id;
      if (state.editing != null) {
        await _repo.updateService(model.copyWith(id: state.editing!.id));
        id = state.editing!.id;
      } else {
        id = await _repo.createService(model);
      }

      state = state.copyWith(isSaving: false);
      return id;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }
}

/// NOT autoDispose — state persists even if user navigates away accidentally.
/// Call notifier.reset() explicitly on successful save or intentional discard.
final serviceFormProvider =
    StateNotifierProvider<ServiceFormNotifier, ServiceFormState>((ref) {
      final repo = ref.watch(serviceRepositoryProvider);
      final uid = ref.watch(currentUserStreamProvider).valueOrNull?.uid ?? '';
      return ServiceFormNotifier(repo, uid);
    });
