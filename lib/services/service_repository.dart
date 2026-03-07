import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empleame/models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore _db;

  ServiceRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _services =>
      _db.collection('services');

  // ── Queries (Futures for Pull-To-Refresh) ──────────────────────────────────

  Future<List<ServiceModel>> getWorkerServices(String workerId) async {
    final query = await _services
        .where('workerId', isEqualTo: workerId)
        .where('status', isNotEqualTo: 'deleted')
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map(ServiceModel.fromFirestore).toList();
  }

  // ── Streams (Live UI Feeds) ───────────────────────────────────────────────

  /// Streams the newest active services, limited to [limit] for efficiency.
  Stream<List<ServiceModel>> watchRecentServices({int limit = 20}) {
    return _services
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ServiceModel.fromFirestore).toList());
  }

  /// Streams active services ordered by their rate (as popularity metric), limited.
  Stream<List<ServiceModel>> watchPopularServices({int limit = 10}) {
    return _services
        .where('status', isEqualTo: 'active')
        .orderBy('rate', descending: false)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ServiceModel.fromFirestore).toList());
  }

  /// Streams a single service by ID for robust deep linking and caching.
  Stream<ServiceModel?> watchServiceById(String id) {
    return _services.doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ServiceModel.fromFirestore(snap);
    });
  }

  Future<List<ServiceModel>> getPendingServices() async {
    final query = await _services
        .where('status', isEqualTo: 'pending_review')
        .orderBy('createdAt', descending: false)
        .get();
    return query.docs.map(ServiceModel.fromFirestore).toList();
  }

  /// Fetches multiple services by their IDs, handling Firestore's 10-item whereIn limit.
  Future<List<ServiceModel>> getServicesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<ServiceModel> results = [];
    // Firestore 'whereIn' supports a maximum of 10 elements per query.
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final query = await _services
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(query.docs.map(ServiceModel.fromFirestore));
    }
    return results;
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Creates a new service document. Returns the Firestore-assigned [id].
  Future<String> createService(ServiceModel service) async {
    final ref = _services.doc();
    await ref.set({
      ...service.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Overwrites the mutable fields of an existing service.
  Future<void> updateService(ServiceModel service) async {
    await _services.doc(service.id).update({
      'title': service.title,
      'category': service.category,
      'description': service.description,
      'rate': service.rate,
      'imageUrls': service.imageUrls,
      'status': service.status,
    });
  }

  /// Changes the status of a service (used by Admin)
  Future<void> updateServiceStatus(
    String id,
    String status, {
    String? adminNotes,
  }) async {
    final Map<String, dynamic> data = {'status': status};
    if (adminNotes != null) {
      data['adminNotes'] = adminNotes;
    }
    await _services.doc(id).update(data);
  }

  Future<void> deleteService(String id) async {
    await _services.doc(id).delete();
  }
}
