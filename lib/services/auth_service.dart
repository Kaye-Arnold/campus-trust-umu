import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Signs in with Google and saves user doc to Firestore on first login.
  Future<UserModel?> signInWithGoogle() async {
    // Open the Google account picker
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCred =
        await _auth.signInWithCredential(credential);
    final User? user = userCred.user;
    if (user == null) return null;

    final model = UserModel(
      uid: user.uid,
      name: user.displayName ?? 'CampusTrust User',
      email: user.email ?? '',
    );

    // Merge so existing data is never overwritten on repeat sign-ins
    await _db
        .collection('users')
        .doc(user.uid)
        .set(model.toMap(), SetOptions(merge: true));

    return model;
  }

  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
  }
}
