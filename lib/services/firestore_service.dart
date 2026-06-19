import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
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
        .update(task.toMap());
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
