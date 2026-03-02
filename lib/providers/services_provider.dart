import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:empleame/models/service_model.dart';
import 'package:empleame/services/service_repository.dart';

/// Singleton provider for the generic ServiceRepository methods
final globalServiceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

/// Streams the most recent [active] services, limited to 20 for scalability
final recentServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final repo = ref.watch(globalServiceRepositoryProvider);
  return repo.watchRecentServices(limit: 20);
});

/// Streams the [active] services sorted by popularity/rate, limited to 10 for the Home Screen
final popularServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final repo = ref.watch(globalServiceRepositoryProvider);
  return repo.watchPopularServices(limit: 10);
});

/// Streams a specific service by its ID.
/// Useful for Deep Linking so the [ServiceDetailScreen] can just pass the ID
/// and let Riverpod handle the caching automatically.
final serviceDetailProvider = StreamProvider.family<ServiceModel?, String>((
  ref,
  id,
) {
  final repo = ref.watch(globalServiceRepositoryProvider);
  return repo.watchServiceById(id);
});
