import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empleame/models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore _db;

  ServiceRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _services =>
      _db.collection('services');

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<ServiceModel>> watchWorkerServices(String workerId) {
    return _services
        .where('workerId', isEqualTo: workerId)
        .where('status', isNotEqualTo: 'deleted')
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ServiceModel.fromFirestore).toList());
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

  Future<void> deleteService(String id) async {
    await _services.doc(id).delete();
  }
}
