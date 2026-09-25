import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get userChanges => _auth.userChanges(); 
  User? get currentUser => _auth.currentUser;
  bool get isGuest => _auth.currentUser?.isAnonymous ?? true;

  // 1. Silent guest sign-in on app start
  Future<void> initializeAuth() async {
    if (_auth.currentUser == null) {
      await signInAnonymously();
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  // 2. Register/Sign up with Email
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user != null && user.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email.trim(),
          password: password.trim(),
        );
        final userCredential = await user.linkWithCredential(credential);
        await userCredential.user?.sendEmailVerification();
        return userCredential;
      } else {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        await credential.user?.sendEmailVerification();
        return credential;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        // Account already exists: Sign in instead and re-send link if unverified
        final credential = await signInWithEmail(
          email: email,
          password: password,
        );
        if (credential?.user != null && !credential!.user!.emailVerified) {
          await credential.user!.sendEmailVerification();
          throw "Account exists but is not verified. A new verification link has been sent to your email.";
        }
        return credential;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 3. Sign in with Email
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final guestUid = _auth.currentUser?.isAnonymous == true
          ? _auth.currentUser?.uid
          : null;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final newUid = credential.user?.uid;
      if (guestUid != null && newUid != null && guestUid != newUid) {
        await _migrateGuestData(guestUid: guestUid, targetUid: newUid);
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // 4. Resend Verification Link
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.reload();
      if (!_auth.currentUser!.emailVerified) {
        await user.sendEmailVerification();
      }
    }
  }

  // 5. Check Verification Status On-Demand
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    }
    return false;
  }

  // 6. Sign in / Link with Google
// 6. Sign in / Link with Google
Future<UserCredential?> signInWithGoogle() async {
  try {
    final user = _auth.currentUser;
    final guestUid = user?.isAnonymous == true ? user?.uid : null;

    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId:
          '905177408871-pi1474fadbnt14in3r3u49fmqaldl03v.apps.googleusercontent.com',
    );

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final clientAuth = await googleUser.authorizationClient.authorizeScopes([
      'email',
      'profile',
    ]);

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: clientAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential? userCredential;

    // If user is currently a guest, convert account in-place
    if (user != null && user.isAnonymous) {
      try {
        userCredential = await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        // If this Google account already exists in Firebase, sign into it and migrate guest records
        if (e.code == 'credential-already-in-use') {
          userCredential = await _auth.signInWithCredential(credential);
          final newUid = userCredential.user?.uid;
          if (guestUid != null && newUid != null && guestUid != newUid) {
            await _migrateGuestData(guestUid: guestUid, targetUid: newUid);
          }
        } else {
          rethrow;
        }
      }
    } else {
      userCredential = await _auth.signInWithCredential(credential);
    }

    // 💡 FIX: LinkWithCredential keeps displayName null. Sync details manually from Google:
    final updatedUser = _auth.currentUser;
    if (updatedUser != null) {
      if (updatedUser.displayName == null || updatedUser.displayName!.isEmpty) {
        await updatedUser.updateDisplayName(googleUser.displayName);
        await updatedUser.updatePhotoURL(googleUser.photoUrl);
      }
      // Force reload so authStateChanges emits updated profile data instantly
      await updatedUser.reload();
    }

    return userCredential;
  } catch (e) {
    throw "Google Sign-In failed: $e";
  }
}

  // 7. Migrate Guest Records to Target User Collection
  Future<void> _migrateGuestData({
    required String guestUid,
    required String targetUid,
  }) async {
    final guestRecords = await _db
        .collection('users')
        .doc(guestUid)
        .collection('records')
        .get();

    if (guestRecords.docs.isEmpty) return;

    final batch = _db.batch();

    for (var doc in guestRecords.docs) {
      final newDocRef = _db
          .collection('users')
          .doc(targetUid)
          .collection('records')
          .doc(doc.id);

      batch.set(newDocRef, doc.data());
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // 8. Sign Out and Re-initialize Guest Session
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
    await signInAnonymously();
  }
}