import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../shared/data/shared_pref_data.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> signUp(String email, String password, String name, String phone) async {
    try {
      setLoading(true);
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Save user details to Firestore
      if (credential.user != null) {
        await _firestore.collection("users").doc(credential.user!.uid).set({
          'name': name,
          'phone': phone,
          'email': email,
          'uid': credential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      log(e.toString());
      return _handleAuthError(e);
    } catch (e) {
      setLoading(false);
      return "An unknown error occurred: $e";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      log(e.code);
      return _handleAuthError(e);
    } catch (e) {
      setLoading(false);
      return "An unknown error occurred: $e";
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      setLoading(false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      log(e.code);
      return _handleAuthError(e);
    } catch (e) {
      setLoading(false);
      log(e.toString());
      return "An unknown error occurred: $e";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await AppPref.clearAll();
    notifyListeners();
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      setLoading(true);
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        setLoading(false);
        return null;
      } else {
        setLoading(false);
        return "User not found. Please login again.";
      }
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      return _handleAuthError(e);
    } catch (e) {
      setLoading(false);
      return "An unknown error occurred: $e";
    }
  }

  User? get currentUser => _auth.currentUser;

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'unknown-error':
        return "Invalid Email or Password.";
      case 'email-already-in-use':
        return "Email already registered. Please login.";
      case 'weak-password':
        return "Password provided is too weak.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'requires-recent-login':
        return "Security check failed. Please verify again.";
      default:
        return e.message ?? "Authentication failed.";
    }
  }
}
