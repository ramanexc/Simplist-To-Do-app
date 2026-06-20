import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import '../database/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } catch (e) {
        debugPrint("Anonymous sign-in failed (enable it in Firebase Console > Authentication > Sign-in method): $e");
        // App continues to work offline without auth
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      OAuthCredential credential;

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        // WINDOWS: Use desktop_webview_auth
        // IMPORTANT: You must create a "Desktop app" OAuth Client ID in Google Cloud Console
        // https://console.cloud.google.com/apis/credentials
        const String desktopClientId = '972214616753-9e88sduibofrlh42i930fb3qfv0quqlf.apps.googleusercontent.com';
        
        if (desktopClientId.contains('YOUR_WINDOWS')) {
          debugPrint("Please set your desktopClientId in firestore_service.dart to enable Windows Google Sign-In");
          return null;
        }

        final args = GoogleSignInArgs(
          clientId: desktopClientId,
          redirectUri: 'http://localhost',
          scope: 'email profile',
        );
        
        final result = await DesktopWebviewAuth.signIn(args);
        if (result == null) return null;

        credential = GoogleAuthProvider.credential(
          accessToken: result.accessToken,
          idToken: result.idToken,
        );
      } else {
        // ANDROID / IOS / WEB
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }

      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        try {
          return await _auth.currentUser!.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            // This Google account already has data! Switch to it.
            return await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    await signInAnonymously();
  }

  Stream<List<Task>> getTasks() {
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addTask(Task task) async {
    if (uid == null || task.id == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id.toString())
        .set(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    if (uid == null || task.id == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id.toString())
        .set(task.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteTask(int taskId) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId.toString())
        .delete();
  }
}
