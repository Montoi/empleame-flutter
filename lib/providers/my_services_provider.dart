import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/providers/providers.dart';
import 'package:empleame/services/service_repository.dart';
import 'package:empleame/services/storage_service.dart';

// ── Repository provider ──────────────────────────────────────────────────────

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

// ── Worker's services stream ─────────────────────────────────────────────────

/// Emits the list of services for the current worker.
final myServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final uid = ref.watch(currentUserStreamProvider).valueOrNull?.uid ?? '';
  if (uid.isEmpty) return [];
  return ref.watch(serviceRepositoryProvider).getWorkerServices(uid);
});

/// Emits the list of pending services for the Admin Moderation panel.
final pendingServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  return ref.watch(serviceRepositoryProvider).getPendingServices();
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

    final isNew = state.editing == null;
    final String serviceId = isNew ? _repo.generateServiceId() : state.editing!.id;
    final uploadedUrls = <String>[];

    try {
      // 1. Upload Images to Storage
      // If we are editing, we currently start with no new logic for keeping old ones (would append or replace). 
      // For now, we assume localImages are the final intended list.
      if (state.localImages.isNotEmpty) {
        final storage = StorageService();
        for (int i = 0; i < state.localImages.length; i++) {
          final url = await storage.uploadServiceImage(serviceId, state.localImages[i], i);
          if (url != null) {
            uploadedUrls.add(url);
          }
        }
      }

      // Handle edited items that might have pre-existing URLs
      final currentUrls = state.editing?.imageUrls ?? [];
      final finalUrls = [...currentUrls, ...uploadedUrls];
      
      // Fallback if no images were provided (using a placeholder)
      if (finalUrls.isEmpty) {
        finalUrls.add('https://picsum.photos/seed/$_workerId/400/300');
      }

      final model = ServiceModel(
        id: serviceId,
        title: state.title.trim(),
        category: state.category,
        description: state.description.trim(),
        rate: double.parse(state.rate),
        workerId: _workerId,
        imageUrls: finalUrls,
        status: 'pending_review',
      );

      // 2. Save to Firestore
      if (!isNew) {
        await _repo.updateService(model);
      } else {
        await _repo.createServiceWithId(serviceId, model);
      }

      state = state.copyWith(isSaving: false);
      return serviceId;
    } catch (e) {
      // 🚨 Rollback: Si los datos fallaron al guardar en Firestore (e.g timeout/reglas de seguridad)
      // Iteramos y borramos las imagenes huerfanas subidas en este intento.
      for (final url in uploadedUrls) {
        await StorageService().deleteImageByUrl(url);
      }

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
