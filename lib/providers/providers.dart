import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/models/user_model.dart';
import 'package:empleame/services/user_repository.dart';
import 'package:empleame/services/auth_service.dart';
import 'package:empleame/services/notification_service.dart';
import 'package:empleame/services/notification_repository.dart';
import 'package:empleame/config/router.dart';

/// Singleton AuthService — lives for the entire app lifetime.
/// Using a Riverpod Provider guarantees the same instance survives
/// locale / theme rebuilds and is never recreated.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Singleton GoRouter — depends on [authServiceProvider].
/// Riverpod caches this for the app lifetime, so switching the locale
/// (which rebuilds MyApp) NEVER creates a fresh router or resets navigation.
final routerProvider = Provider<GoRouter>(
  (ref) => createRouter(ref.read(authServiceProvider)),
);

/// Provides the FirebaseAuth singleton.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

/// Provides the UserRepository singleton.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

/// Provides the [NotificationService] singleton.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

/// Provides the [NotificationRepository] singleton.
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

/// Reactively watches the Firestore document for the currently signed-in user.
/// Emits Firebase Auth user data immediately (offline-safe), then enriches
/// with the Firestore document once it arrives. If Firestore is unreachable
/// the stream keeps emitting the auth fallback without entering error state.
final currentUserStreamProvider = StreamProvider<AppUser?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  final repo = ref.watch(userRepositoryProvider);

  final firebaseUser = auth.currentUser;

  if (firebaseUser == null) {
    yield null;
    return;
  }

  // Always available locally — shown instantly without waiting for Firestore.
  final fallback = AppUser(
    uid: firebaseUser.uid,
    displayName: firebaseUser.displayName ?? '',
    email: firebaseUser.email ?? '',
    photoUrl: firebaseUser.photoURL ?? '',
    role: UserRole.client,
  );

  yield fallback; // immediate paint

  try {
    await for (final user in repo.watchUser(firebaseUser.uid)) {
      yield user ?? fallback; // Firestore doc wins when present
    }
  } catch (_) {
    // Firestore unreachable — fallback already displayed, no error state.
  }
});
