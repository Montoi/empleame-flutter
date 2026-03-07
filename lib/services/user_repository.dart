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

/// Thrown when a referral code is not found in Firestore.
class InvalidReferralCodeException implements Exception {
  @override
  String toString() => 'InvalidReferralCodeException: code not found';
}

/// Thrown when the inviter has no available slots.
class NoAvailableUpdatesException implements Exception {
  @override
  String toString() =>
      'NoAvailableUpdatesException: inviter has no available slots';
}

// ── Value object returned by lookupReferralCode ──────────────────────────────

class InviterInfo {
  final String uid;
  final String displayName;
  final String photoUrl;
  final int availableUpdates;

  const InviterInfo({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.availableUpdates,
  });
}

// ── Repository ────────────────────────────────────────────────────────────────

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  // ── Collection references ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _workerProfiles =>
      _db.collection('profiles_worker');

  // ── Real-time stream ─────────────────────────────────────────────────────

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

  // ── Write operations ─────────────────────────────────────────────────────

  /// Creates the user document if it does not exist.
  /// If the doc already exists but has blank profile fields (e.g. created
  /// offline with no data), those fields are patched with the provided values.
  Future<void> createUser(AppUser user) async {
    try {
      final ref = _users.doc(user.uid);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) {
          // Brand new user — referralCode = uid, availableUpdates = 0.
          tx.set(ref, {
            ...user.toJson(),
            'uid': user.uid,
            'referralCode': user.uid,
            'availableUpdates': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Doc exists: patch only blank profile fields.
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
          // Backfill referralCode for legacy docs.
          if ((data['referralCode'] as String? ?? '').isEmpty) {
            patches['referralCode'] = user.uid;
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

  /// Adds or removes a service ID from the user's savedServices array.
  Future<void> toggleSavedService({
    required String uid,
    required String serviceId,
    required bool save,
  }) async {
    try {
      await _users.doc(uid).update({
        'savedServices': save
            ? FieldValue.arrayUnion([serviceId])
            : FieldValue.arrayRemove([serviceId]),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException(
          'Cannot modify saved services for users/$uid',
        );
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

  // ── Worker conversion ────────────────────────────────────────────────────

  /// Looks up the inviter by [referralCode] and validates that they have
  /// at least one available slot. Returns [InviterInfo] on success.
  ///
  /// Throws [InvalidReferralCodeException] if no user owns the code.
  /// Throws [NoAvailableUpdatesException] if the inviter has 0 slots.
  Future<InviterInfo> lookupReferralCode(String referralCode) async {
    final query = await _users
        .where('referralCode', isEqualTo: referralCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw InvalidReferralCodeException();

    final doc = query.docs.first;
    final data = doc.data();
    final available = (data['availableUpdates'] as num? ?? 0).toInt();

    if (available <= 0) throw NoAvailableUpdatesException();

    return InviterInfo(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Invitador',
      photoUrl: data['photoUrl'] as String? ?? '',
      availableUpdates: available,
    );
  }

  /// Atomically converts [userId] from client → worker using [referralCode].
  ///
  /// Transaction steps:
  /// 1. Re-reads inviter inside txn (race-safe check availableUpdates > 0).
  /// 2. Decrements inviter's `availableUpdates` by 1.
  /// 3. Sets user `role = worker` and `referredBy = inviterUid`.
  /// 4. Creates `profiles_worker/{userId}` with blank defaults.
  Future<void> convertToWorker({
    required String userId,
    required String referralCode,
  }) async {
    // Find inviter outside transaction (Firestore queries can't run inside txn)
    final query = await _users
        .where('referralCode', isEqualTo: referralCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw InvalidReferralCodeException();

    final inviterRef = _users.doc(query.docs.first.id);
    final userRef = _users.doc(userId);
    final workerProfileRef = _workerProfiles.doc(userId);

    try {
      await _db.runTransaction((tx) async {
        final inviterSnap = await tx.get(inviterRef);
        final available = (inviterSnap.data()?['availableUpdates'] as num? ?? 0)
            .toInt();

        if (available <= 0) throw NoAvailableUpdatesException();

        // Atomically apply all 3 writes
        tx.update(inviterRef, {'availableUpdates': FieldValue.increment(-1)});
        tx.update(userRef, {'role': 'worker', 'referredBy': inviterRef.id});
        tx.set(workerProfileRef, {
          'uid': userId,
          'services': <String>[],
          'bio': '',
          'rating': 0.0,
          'isVerified': false,
          'subscriptionStatus': 'free',
          'referredBy': inviterRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionDeniedException('Worker conversion denied');
      }
      rethrow;
    }
  }
}
