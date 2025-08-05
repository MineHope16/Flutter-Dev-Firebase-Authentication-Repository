/// {@template firebase_auth_repository}
/// A comprehensive Flutter/Dart repository that handles all authentication-related
/// operations with Firebase Auth and multiple social providers.
///
/// ## Features
///
/// This repository provides a clean, simple interface for:
///
/// ### Authentication Methods
/// - **Email & Password**: Sign up, sign in, and password reset
/// - **Google Sign-In**: OAuth integration with Google accounts
/// - **Facebook Sign-In**: OAuth integration with Facebook accounts
/// - **GitHub Sign-In**: OAuth integration with GitHub accounts
/// - **Microsoft Sign-In**: OAuth integration with Microsoft accounts
///
/// ### Additional Features
/// - **Real-time Auth State**: Stream of authentication state changes
/// - **Firestore Integration**: Automatic user document creation
/// - **Error Handling**: User-friendly error messages for all Firebase Auth errors
/// - **Platform Support**: Works on Android and iOS
/// - **Clean Architecture**: Repository pattern for easy testing and maintenance
///
/// ## Usage
///
/// ```dart
/// final authRepository = FirebaseAuthRepository();
///
/// // Listen to auth state changes
/// authRepository.authStateChanges.listen((user) {
///   if (user != null) {
///     print('User signed in: ${user.email}');
///   } else {
///     print('User signed out');
///   }
/// });
///
/// // Sign up with email and password
/// await authRepository.signUp(
///   email: 'user@example.com',
///   password: 'securePassword123',
///   name: 'John Doe',
/// );
///
/// // Sign in with Google
/// await authRepository.signInWithGoogle(
///   serverClientId: 'your-google-server-client-id',
/// );
/// ```
///
/// ## Error Handling
///
/// All methods throw [FirebaseAuthException] with user-friendly error messages:
///
/// ```dart
/// try {
///   await authRepository.signIn(
///     email: email,
///     password: password,
///   );
/// } on FirebaseAuthException catch (e) {
///   print('Auth Error: ${e.message}');
/// }
/// ```
/// {@endtemplate}
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// {@macro firebase_auth_repository}
class FirebaseAuthRepository {
  /// Firebase Authentication instance for handling auth operations
  final FirebaseAuth _firebaseAuth;

  /// Firestore instance for creating and managing user documents
  final FirebaseFirestore _firebaseFirestore;

  /// Google Sign-In instance for Google OAuth authentication
  final GoogleSignIn _googleSignIn;

  /// Creates a [FirebaseAuthRepository] instance.
  ///
  /// Accepts optional instances of [FirebaseAuth], [FirebaseFirestore], and
  /// [GoogleSignIn] for dependency injection, making testing easier.
  ///
  /// If no instances are provided, the default instances will be used.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Using default instances
  /// final authRepository = FirebaseAuthRepository();
  ///
  /// // Using custom instances for testing
  /// final authRepository = FirebaseAuthRepository(
  ///   firebaseAuth: mockFirebaseAuth,
  ///   firebaseFirestore: mockFirestore,
  ///   googleSignIn: mockGoogleSignIn,
  /// );
  /// ```
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// A stream that emits the current authenticated user or `null`.
  ///
  /// This stream provides real-time updates about the user's authentication state.
  /// It emits a [User] object when the user is signed in and `null` when the
  /// user is signed out.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// StreamBuilder<User?>(
  ///   stream: authRepository.authStateChanges,
  ///   builder: (context, snapshot) {
  ///     if (snapshot.hasData) {
  ///       // User is signed in
  ///       return HomePage(user: snapshot.data!);
  ///     } else {
  ///       // User is signed out
  ///       return LoginPage();
  ///     }
  ///   },
  /// )
  /// ```
  ///
  /// This stream is useful for:
  /// - Automatically navigating between login and authenticated screens
  /// - Updating UI based on authentication state
  /// - Persisting authentication state across app restarts
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Creates a new user account with email, password, and display name.
  ///
  /// This method creates a new user in Firebase Authentication and automatically
  /// creates a corresponding user document in Firestore under the "users" collection.
  ///
  /// ## Process
  ///
  /// 1. Creates a new Firebase Auth user with email and password
  /// 2. Creates a Firestore document with user information
  /// 3. Document ID matches the user's UID for easy querying
  ///
  /// ## Firestore Document Structure
  ///
  /// ```json
  /// {
  ///   "uid": "firebase_user_uid",
  ///   "name": "User Display Name",
  ///   "email": "user@example.com",
  ///   "createdAt": "2024-01-01T00:00:00.000Z"
  /// }
  /// ```
  ///
  /// ## Parameters
  ///
  /// - [email] - The email address for the new user account
  /// - [password] - The password for the new user account
  /// - [name] - The display name for the new user
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.signUp(
  ///     email: 'john.doe@example.com',
  ///     password: 'securePassword123',
  ///     name: 'John Doe',
  ///   );
  ///   print('Account created successfully!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Sign up failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] with user-friendly messages for:
  /// - `email-already-in-use` - Email is already registered
  /// - `invalid-email` - Email format is invalid
  /// - `weak-password` - Password is too weak
  /// - `operation-not-allowed` - Email/password auth is disabled
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

  /// Signs in an existing user with email and password.
  ///
  /// This method authenticates a user using Firebase Authentication with the
  /// provided email and password credentials.
  ///
  /// ## Parameters
  ///
  /// - [email] - The email address of the user account
  /// - [password] - The password for the user account
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.signIn(
  ///     email: 'john.doe@example.com',
  ///     password: 'userPassword123',
  ///   );
  ///   print('Sign in successful!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Sign in failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] with user-friendly messages for:
  /// - `invalid-credential` - Email or password is incorrect
  /// - `user-disabled` - User account has been disabled
  /// - `user-not-found` - No account exists for this email
  /// - `wrong-password` - Password is incorrect
  /// - `invalid-email` - Email format is invalid
  /// - `too-many-requests` - Too many failed sign-in attempts
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

  /// Signs in a user with their Google account.
  ///
  /// This method initiates the Google Sign-In flow and authenticates the user
  /// with Firebase using their Google credentials. For new users, it automatically
  /// creates a Firestore document with their profile information.
  ///
  /// ## Setup Required
  ///
  /// Before using this method, ensure you have:
  /// 1. Added your SHA-1 fingerprint to Firebase Console
  /// 2. Enabled Google Sign-In in Firebase Authentication
  /// 3. Obtained the Server Client ID from your `google-services.json`
  ///
  /// ## Parameters
  ///
  /// - [serverClientId] - The Web Client ID from your Firebase project.
  ///   Find this in your `google-services.json` file where `"client_type": 3`
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Get this from google-services.json
  /// const serverClientId = '123456789-abcdef.apps.googleusercontent.com';
  ///
  /// try {
  ///   await authRepository.signInWithGoogle(
  ///     serverClientId: serverClientId,
  ///   );
  ///   print('Google sign in successful!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Google sign in failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Firestore Integration
  ///
  /// For new users, automatically creates a document in `users` collection:
  ///
  /// ```json
  /// {
  ///   "uid": "firebase_user_uid",
  ///   "name": "User's Google Display Name",
  ///   "email": "user@gmail.com",
  ///   "createdAt": "2024-01-01T00:00:00.000Z"
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] with user-friendly messages for common Google Sign-In errors
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

  /// Signs in a user with their Facebook account.
  ///
  /// This method initiates the Facebook Sign-In flow and authenticates the user
  /// with Firebase using their Facebook credentials. For new users, it automatically
  /// creates a Firestore document with their profile information.
  ///
  /// ## Setup Required
  ///
  /// Before using this method, ensure you have:
  /// 1. Created a Facebook app at [Facebook for Developers](https://developers.facebook.com/)
  /// 2. Added Facebook Login product to your app
  /// 3. Added your app's key hash to Facebook app settings
  /// 4. Enabled Facebook Sign-In in Firebase Authentication
  /// 5. Added Facebook App ID and Client Token to your Android app
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.signInWithFacebook();
  ///   print('Facebook sign in successful!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Facebook sign in failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Behavior
  ///
  /// - If user cancels the Facebook login, the method returns without error
  /// - For new users, creates a Firestore document with Facebook profile data
  /// - Existing users are signed in without creating duplicate documents
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] with user-friendly messages for Facebook Sign-In errors
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

  /// Signs in a user with their GitHub account.
  ///
  /// This method uses Firebase's built-in OAuth provider to authenticate users
  /// with their GitHub credentials. For new users, it automatically creates a
  /// Firestore document with their profile information.
  ///
  /// ## Setup Required
  ///
  /// Before using this method, ensure you have:
  /// 1. Created a GitHub OAuth App in GitHub Developer Settings
  /// 2. Set the Authorization callback URL to: `https://your-project-id.firebaseapp.com/__/auth/handler`
  /// 3. Added Client ID and Client Secret to Firebase Authentication
  /// 4. Enabled GitHub Sign-In in Firebase Authentication
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.signInWithGitHub();
  ///   print('GitHub sign in successful!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('GitHub sign in failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Features
  ///
  /// - Uses Firebase's web-based OAuth flow
  /// - Works on both Android and iOS
  /// - Automatically handles token exchange
  /// - Creates Firestore document for new users
  ///
  /// ## Throws
  ///
  /// - [FirebaseAuthException] for Firebase-related errors
  /// - [GoogleSignInException] for platform-specific errors
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

  /// Signs in a user with their Microsoft account.
  ///
  /// This method uses Firebase's OAuth provider to authenticate users with their
  /// Microsoft/Azure AD credentials. For new users, it automatically creates a
  /// Firestore document with their profile information.
  ///
  /// ## Setup Required
  ///
  /// Before using this method, ensure you have:
  /// 1. Created an Azure App registration in Azure Portal
  /// 2. Added redirect URI for your Firebase project
  /// 3. Added Client ID to Firebase Authentication
  /// 4. Enabled Microsoft Sign-In in Firebase Authentication
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.signInWithMicrosoft();
  ///   print('Microsoft sign in successful!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Microsoft sign in failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## OAuth Scopes
  ///
  /// This method requests the following Microsoft Graph scopes:
  /// - `user.read` - Read user's profile information
  ///
  /// ## Features
  ///
  /// - Works with personal Microsoft accounts and Azure AD
  /// - Uses Firebase's web-based OAuth flow
  /// - Automatically handles token exchange
  /// - Creates Firestore document for new users
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] with user-friendly messages for Microsoft Sign-In errors
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

  /// Sends a password reset email to the specified email address.
  ///
  /// This method uses Firebase Authentication to send a password reset email
  /// to the provided email address. The user can then follow the instructions
  /// in the email to reset their password.
  ///
  /// ## Parameters
  ///
  /// - [email] - The email address to send the password reset email to
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.resetPassword(
  ///     email: 'user@example.com',
  ///   );
  ///   print('Password reset email sent!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Failed to send reset email: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Behavior
  ///
  /// - If the email is not registered, Firebase still returns success (for security)
  /// - The email contains a link that expires after a certain time
  /// - Users can request multiple reset emails
  /// - The reset link can only be used once
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] with user-friendly messages for:
  /// - `invalid-email` - Email format is invalid
  /// - `user-not-found` - No account exists for this email (rare)
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Signs out the current user from all authentication providers.
  ///
  /// This method signs out the current user from:
  /// - Firebase Authentication
  /// - Google Sign-In (if the user signed in with Google)
  /// - All other active sessions
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   await authRepository.signOut();
  ///   print('User signed out successfully!');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Sign out failed: ${e.message}');
  /// }
  /// ```
  ///
  /// ## Behavior
  ///
  /// - Clears the authentication state
  /// - Triggers `authStateChanges` stream to emit `null`
  /// - Signs out from Google Sign-In to prevent automatic re-authentication
  /// - Does not delete user data from Firestore
  ///
  /// ## Post Sign-Out
  ///
  /// After calling this method:
  /// - `authStateChanges` stream will emit `null`
  /// - User will need to sign in again to access protected resources
  /// - Any cached user data should be cleared from your app
  ///
  /// ## Throws
  ///
  /// [FirebaseAuthException] if the sign-out process fails (rare)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    }
  }

  /// Converts Firebase error codes into user-friendly error messages.
  ///
  /// This internal helper method takes a [FirebaseAuthException] and returns
  /// a new exception with a more user-friendly error message based on the error code.
  ///
  /// ## Supported Error Codes
  ///
  /// The method handles common Firebase Auth error codes and provides
  /// appropriate user-facing messages for:
  ///
  /// ### Authentication Errors
  /// - `invalid-credential` - Invalid email or password
  /// - `user-not-found` - Account doesn't exist
  /// - `wrong-password` - Incorrect password
  /// - `user-disabled` - Account has been disabled
  ///
  /// ### Registration Errors
  /// - `email-already-in-use` - Email already registered
  /// - `weak-password` - Password too weak
  /// - `invalid-email` - Invalid email format
  ///
  /// ### Social Auth Errors
  /// - `account-exists-with-different-credential` - Account exists with different provider
  /// - `popup-closed-by-user` - User cancelled social sign-in
  ///
  /// ### Network & Rate Limiting
  /// - `network-request-failed` - Network connectivity issues
  /// - `too-many-requests` - Rate limiting active
  /// - `operation-not-allowed` - Auth method disabled
  ///
  /// ## Parameters
  ///
  /// - [e] - The original [FirebaseAuthException] to convert
  ///
  /// ## Returns
  ///
  /// A new [FirebaseAuthException] with the same code but a user-friendly message
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Original Firebase error:
  /// // FirebaseAuthException(code: 'user-not-found', message: 'There is no user record...')
  ///
  /// // Converted error:
  /// // FirebaseAuthException(code: 'user-not-found', message: 'No account found for this email.')
  /// ```
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
