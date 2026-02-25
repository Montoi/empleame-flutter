import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Google Sign-In Service Class
class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn instance with Web Client ID for idToken generation
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '1095778627171-9pleqv2doetvis0k57t10h7h8r046vot.apps.googleusercontent.com',
  );

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Disconnect any stale cached account — prevents silent failures
      // where a previous account state causes signIn() to return null silently.
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Sign-In did not return an idToken. '
          'Make sure the Web Client ID is set correctly.',
        );
      }

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Save user profile to Firestore in the background.
      // This must NOT block or throw — auth succeeds independently of Firestore.
      _saveUserToFirestore(userCredential.user).catchError((e) {
        print('GoogleSignInService: Firestore save failed (non-fatal): $e');
      });

      return userCredential;
    } catch (e) {
      print('GoogleSignInService error: $e');
      rethrow;
    }
  }

  // Save user profile to Firestore (only on first sign-in)
  static Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
