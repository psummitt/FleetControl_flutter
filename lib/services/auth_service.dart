import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> getUserCompanyId() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    return data?['companyId'] as String?;
  }

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String companyName,
    String? firstName,
    String? lastName,
  }) async {
    final companyRef = await _firestore.collection('companies').add({
      'name': companyName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'companyId': companyRef.id,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('companies').doc(companyRef.id).update({
      'createdBy': uid,
    });
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<Company?> getCompany() async {
    final companyId = await getUserCompanyId();
    if (companyId == null) return null;

    final doc = await _firestore.collection('companies').doc(companyId).get();
    if (!doc.exists) return null;
    return Company.fromDocument(doc);
  }
}
