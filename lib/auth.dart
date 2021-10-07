import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

/// Sign out
Future<bool> signOut() async {
  await _auth.signOut();
  return true;
}

/// Sign with Google
Future<bool> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;
  OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  if (userCredential.user != null && !userCredential.user!.isAnonymous) {
    return true;
  }
  return false;
}

/// Check if user loggedIn
Future<Null> ensureSignIn() async {
  assert(_auth.currentUser != null);
  assert(_auth.currentUser!.isAnonymous == false);
  print("We are loggedIn into the Firebase");
}

/// Get user IF of Login user
Future<String> userId() async {
  await ensureSignIn();
  String userID = _auth.currentUser!.uid;
  return userID;
}
