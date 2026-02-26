import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empleame/models/user_model.dart';
import 'package:empleame/models/worker_profile_model.dart';

/// Typed error for Firestore permission issues.
class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);
  @override
  String toString() => 'PermissionDeniedException: $message';
}

/// Typed error for missing documents.
class DocumentNotFoundException implements Exception {
  final String message;
  const DocumentNotFoundException(this.message);
  @override
  String toString() => 'DocumentNotFoundException: $message';
}

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  // ── Collection references ──────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _workerProfiles =>
      _db.collection('profiles_worker');

  // ── Real-time stream ───────────────────────────────────────────

  /// Emits the latest [AppUser] whenever the Firestore doc changes.
  /// Emits `null` if the document doesn't exist yet.
  Stream<AppUser?> watchUser(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return null;
          return AppUser.fromFirestore(snap);
        })
        .handleError((Object e) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            throw PermissionDeniedException('Cannot read users/$uid');
          }
          throw e;
        });
  }

  // ── Write operations ───────────────────────────────────────────

  /// Creates the user document if it does not exist.
  /// If the doc already exists but has blank profile fields (e.g. created
  /// offline with no data), those fields are patched with the provided values.
  Future<void> createUser(AppUser user) async {
    try {
      final ref = _users.doc(user.uid);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) {
          // Brand new user — write the full document.
          tx.set(ref, {
            ...user.toJson(),
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Doc exists: patch only blank profile fields so names/photos
          // that were missing (e.g. written while offline) are filled in.
          final data = snap.data()!;
          final patches = <String, dynamic>{};
          if ((data['displayName'] as String? ?? '').isEmpty &&
              user.displayName.isNotEmpty) {
            patches['displayName'] = user.displayName;
          }
          if ((data['photoUrl'] as String? ?? '').isEmpty &&
              user.photoUrl.isNotEmpty) {
            patches['photoUrl'] = user.photoUrl;
          }
          if ((data['email'] as String? ?? '').isEmpty &&
              user.email.isNotEmpty) {
            patches['email'] = user.email;
          }
          if (patches.isNotEmpty) tx.update(ref, patches);
        }
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException('Cannot write users/${user.uid}');
      }
      rethrow;
    }
  }

  /// Partially updates user fields (e.g. displayName, photoUrl).
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _users.doc(uid).update(fields);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw DocumentNotFoundException('users/$uid not found');
      }
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException('Cannot update users/$uid');
      }
      rethrow;
    }
  }

  /// Creates or overwrites a worker profile in `profiles_worker/{uid}`.
  Future<void> createWorkerProfile(WorkerProfile profile) async {
    try {
      await _workerProfiles.doc(profile.uid).set(profile.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(
          'Cannot write profiles_worker/${profile.uid}',
        );
      }
      rethrow;
    }
  }

  /// Fetches the worker profile once (non-reactive).
  Future<WorkerProfile?> getWorkerProfile(String uid) async {
    try {
      final snap = await _workerProfiles.doc(uid).get();
      if (!snap.exists) return null;
      return WorkerProfile.fromFirestore(snap);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException('Cannot read profiles_worker/$uid');
      }
      rethrow;
    }
  }
}
