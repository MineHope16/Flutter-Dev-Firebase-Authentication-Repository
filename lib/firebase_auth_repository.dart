/// {@template auth_repository}
/// A repository that handles all authentication-related operations with Firebase Auth and other providers.
///
/// This repository provides methods for:
/// - Signing up new users with email and password.
/// - Signing in existing users with email and password.
/// - Signing in with Google.
/// - Signing in with Facebook.
/// - Signing in with GitHub.
/// - Signing in with Microsoft.
/// - Sending password reset emails.
/// - Signing out users.
///
/// It also includes error handling for common Firebase Authentication errors.
/// {@endtemplate}
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// {@macro auth_repository}
class FirebaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final GoogleSignIn _googleSignIn;

  /// Constructor for `AuthRepository`.
  ///
  /// Accepts optional instances of `FirebaseAuth`, `FirebaseFirestore`, and `GoogleSignIn` for dependency injection, allowing for easier testing.
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// A stream that emits the current authenticated user or null.
  ///
  /// This stream provides a way to listen for changes in the user's authentication state. It emits a `User` object when the user is signed in and `null` when the user is signed out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Creates a new user account with the given email, password, and name. Also creates a corresponding user document in Firestore.
  ///
  /// This method first creates a new user in Firebase Authentication with the provided email and password. If the user creation is successful, it then creates a corresponding document in Cloud Firestore under the "users" collection. The document ID is set to the user's UID, and the document contains the user's UID, name, email, and a timestamp indicating when the account was created.
  ///
  /// Parameters:
  ///   - `email`: The email address of the new user.
  ///   - `password`: The password for the new user's account.
  ///   - `name`: The display name for the new user.
  ///
  /// Throws:
  ///   - A `FirebaseAuthException` with a user-friendly message if any error occurs during the user creation or Firestore document creation process.
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Create a user document in Firestore.
        await _firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Signs in a user with the given email and password.
  ///
  /// This method uses Firebase Authentication to sign in a user with the provided email and password.
  ///
  /// Parameters:
  ///   - `email`: The email address of the user.
  ///   - `password`: The password for the user's account.
  ///
  /// Throws:
  ///   - A `FirebaseAuthException` with a user-friendly message if any error occurs during the sign-in process.
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Initiates the Google Sign-In flow and authenticates with Firebase. Creates a Firestore document for new users.
  ///
  /// This method uses the Google Sign-In SDK to initiate the sign-in flow. After the user successfully signs in with their Google account, it exchanges the Google credentials for Firebase credentials and signs the user into Firebase. If the user is signing in for the first time, it also creates a corresponding document in Cloud Firestore under the "users" collection. The document ID is set to the user's UID, and the document contains the user's UID, display name, email, and a timestamp indicating when the account was created.
  ///
  /// Throws:
  ///   - A `FirebaseAuthException` with a user-friendly message if any error occurs during the sign-in process.
  Future<void> signInWithGoogle({required String serverClientId}) async {
    try {
      _googleSignIn.initialize(serverClientId: serverClientId);

      // Obtain the auth details from the request
      final GoogleSignInAccount googleAccount = await _googleSignIn
          .authenticate();

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAccount.authentication.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName ?? '',
          "email": user.email ?? '',
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Initiates the Facebook Sign-In flow and authenticates with Firebase. Creates a Firestore document for new users.
  Future<void> signInWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) {
        return; // User cancelled or failed
      }

      final credential = FacebookAuthProvider.credential(
        loginResult.accessToken!.tokenString,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName ?? '',
          "email": user.email ?? '',
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Initiates the GitHub Sign-In flow and authenticates with Firebase. Creates a Firestore document for new users.
  Future<void> signInWithGitHub() async {
    try {
      final githubProvider = GithubAuthProvider();
      final userCredential = await _firebaseAuth.signInWithProvider(
        githubProvider,
      );
      final user = userCredential.user;

      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName ?? '',
          "email": user.email ?? '',
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    } on GoogleSignInException catch (e) {
      throw GoogleSignInException(code: e.code);
    }
  }

  /// Initiates the Microsoft Sign-In flow and authenticates with Firebase. Creates a Firestore document for new users.
  Future<void> signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider("microsoft.com");
      microsoftProvider.addScope('user.read');
      final userCredential = await _firebaseAuth.signInWithProvider(
        microsoftProvider,
      );
      final user = userCredential.user;

      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName,
          "email": user.email,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Sends a password reset email to the given email address.
  ///
  /// This method uses Firebase Authentication to send a password reset email to the provided email address. The user can then follow the instructions in the email to reset their password.
  ///
  /// Parameters:
  ///   - `email`: The email address to send the password reset email to.
  ///
  /// Throws:
  ///   - A `FirebaseAuthException` with a user-friendly message if any error occurs during the process.
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Signs out the current user from Firebase and Google Sign-In.
  ///
  /// This method signs out the current user from Firebase Authentication and also signs out from Google Sign-In if the user is currently signed in with their Google account.
  ///
  /// Throws:
  ///   - A `FirebaseAuthException` with a user-friendly message if any error occurs during the sign-out process.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// A helper function to convert Firebase error codes into user-friendly messages.
  ///
  /// This function takes a `FirebaseAuthException` as input and returns a new `FirebaseAuthException` with a more user-friendly error message based on the error code.
  ///
  /// Parameters:
  ///   - `e`: The `FirebaseAuthException` to convert.
  ///
  /// Returns:
  ///   - A new `FirebaseAuthException` with a user-friendly error message.
  FirebaseAuthException _getFirebaseErrorMessage(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-credential':
        message = 'Invalid credentials. Please check your email and password.';
        break;
      case 'invalid-email':
        message = 'The email address is badly formatted.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No account found for this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'This email is already registered with another account.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed. Please contact support.';
        break;
      case 'weak-password':
        message = 'Your password is too weak. Please use a stronger one.';
        break;
      case 'popup-closed-by-user':
        message = 'Sign-in was cancelled.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'account-exists-with-different-credential':
        message =
            'An account already exists with this email. Please sign in with the original method.';
        break;
      default:
        message = 'An unexpected error occurred. Please try again.';
    }
    return FirebaseAuthException(code: e.code, message: message);
  }
}
