# 🔐 Firebase Auth Repository

[![pub package](https://img.shields.io/pub/v/flutter_firebase_auth_repository.svg)](https://pub.dev/packages/flutter_firebase_auth_repository)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![platforms](https://img.shields.io/badge/platforms-android%20|%20ios-lightgrey.svg)](https://pub.dev/packages/flutter_firebase_auth_repository)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.3.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%5E3.8.1-blue.svg)](https://dart.dev)

A comprehensive Flutter/Dart plugin for handling Firebase Authentication with multiple providers. Built with clean architecture, it integrates seamlessly with Firestore and supports Android/iOS out-of-the-box.

> **⚠️ Important**: This plugin requires proper Firebase setup and configuration. Please follow the detailed setup instructions below to avoid common integration issues.

---

## ✨ Features

- **Multiple Auth Providers**
  - Email & Password (Sign Up / Sign In / Password Reset)
  - Google Sign-In
  - Facebook Sign-In
  - GitHub Sign-In
  - Microsoft Sign-In
- **Real-time Auth State**: Listen for authentication state changes via `Stream<User?>`.
- **Firestore Integration**: Automatically creates a user document in Firestore on first sign-up.
- **Platform-Independent Core**: Pure Dart logic, works with any Flutter app.
- **Clean Architecture Ready**: Repository pattern, easy integration with BLoC, Riverpod, etc.
- **Easy Setup**: Minimal configuration required for Android/iOS.

---

## 📜 Table of Contents

- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
  - [Add Dependency](#1-add-dependency)
  - [Configure Firebase](#2-configure-firebase)
  - [Configure Social Providers](#3-configure-social-providers)
  - [Enable Providers in Firebase](#4-enable-providers-in-firebase)
- [Usage Examples](#-usage-examples)
  - [Basic Setup](#basic-setup)
  - [Email/Password Authentication](#emailpassword-authentication)
  - [Social Authentication](#social-authentication)
  - [Listening to Auth State](#listening-to-auth-state)
- [API Reference](#-api-reference)
- [Error Handling](#-error-handling)
- [Firestore Integration](#-firestore-integration)
- [Firestore Security Rules](#-firestore-security-rules)
- [Common Issues & Solutions](#-common-issues--solutions)
- [Plugin Structure](#-plugin-structure)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Maintainers](#-maintained-by)

---

## � Prerequisites

Before using this plugin, ensure you have:

- **Flutter SDK**: Version 3.3.0 or higher
- **Dart SDK**: Version 3.8.1 or higher
- **Firebase Project**: A configured Firebase project
- **Android**: API level 21 (Android 5.0) or higher
- **iOS**: iOS 11.0 or higher (for future iOS support)

## �🚀 Getting Started

Follow these steps carefully to integrate the Firebase Auth Repository into your Flutter project.

### 1. Add Dependency

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_firebase_auth_repository: ^1.0.0

  # Required Firebase dependencies (if not already added)
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.0
  cloud_firestore: ^6.0.0

  # For Google Sign-In
  google_sign_in: ^7.1.1

  # For Facebook Sign-In
  flutter_facebook_auth: ^7.1.2
```

Then, run:

```bash
flutter pub get
```

**Note**: The plugin automatically includes the required dependencies, but you might need to add them explicitly if you encounter version conflicts.

### 2. Configure Firebase

**Step 2.1: Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Follow the setup wizard

**Step 2.2: Configure Android App**

1. In Firebase Console, click "Add app" → Android
2. Enter your Android package name (found in `android/app/build.gradle` under `applicationId`)
3. Download `google-services.json`
4. Place the file in `android/app/` directory

**Step 2.3: Add Gradle Plugins (Android)**

Add these configurations to your Android files:

**In `android/build.gradle`** (project-level):

```groovy
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.1'
    }
}
```

**In `android/app/build.gradle`** (app-level):

```groovy
// Add at the top
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        // Ensure minimum SDK version is 21 or higher
        minSdkVersion 21
    }
}
```

**Step 2.4: Initialize Firebase in your app**

Add this to your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 3. Configure Social Providers

#### 3.1 Google Sign-In Setup

**Get your Server Client ID:**

1. Open your `android/app/google-services.json` file
2. Look for the `client` array and find the entry where `"client_type": 3`
3. Copy the `client_id` value - this is your **Server Client ID**

**Alternative method:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Find your **Web client** OAuth 2.0 Client ID
5. Copy the Client ID

**Example:**

```json
// In google-services.json
{
  "client": [
    {
      "client_id": "123456789-abcdefg.apps.googleusercontent.com",
      "client_type": 3
    }
  ]
}
```

#### 3.2 Facebook Sign-In Setup

**Important Requirements:**

- Minimum Android SDK: 21
- Facebook App configured properly

**Step 1: Configure minimum SDK**
In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for Facebook SDK v15.0.0+
    }
}
```

**Step 2: Create Facebook App**

1. Go to [Facebook for Developers](https://developers.facebook.com/)
2. Create a new app or use existing one
3. Add **Facebook Login** product
4. Configure Android platform with your package name and key hash

**Step 3: Get your credentials**

- **App ID**: Found in App Dashboard → Settings → Basic
- **Client Token**: Found in App Dashboard → Settings → Advanced

**Step 4: Add credentials to Android**
Create/edit `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
</resources>
```

**Step 5: Configure SHA-1 fingerprint**

1. Get your SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Add this fingerprint to your Firebase project (Project Settings → Your apps → SHA certificate fingerprints)
3. Add the same fingerprint to your Facebook app (Settings → Basic → Android → Key Hashes)

#### 3.3 GitHub & Microsoft Sign-In

These providers use Firebase's built-in OAuth flow and require minimal setup. Just enable them in Firebase Console and they'll work through web authentication.

### 4. Enable Providers in Firebase Console

1. Go to **Firebase Console** → **Authentication**
2. Click **Sign-in method** tab
3. Enable the providers you want:

**For Email/Password:**

- Click **Email/Password** → **Enable** → **Save**

**For Google:**

- Click **Google** → **Enable**
- Select your project support email
- Click **Save**

**For Facebook:**

- Click **Facebook** → **Enable**
- Enter your **App ID** and **App Secret** from Facebook Developer Console
- Click **Save**

**For GitHub:**

- Click **GitHub** → **Enable**
- You'll need to create a GitHub OAuth App:
  1. Go to GitHub → Settings → Developer settings → OAuth Apps
  2. Create new OAuth App
  3. Set Authorization callback URL to: `https://your-project-id.firebaseapp.com/__/auth/handler`
  4. Copy Client ID and Client Secret to Firebase

**For Microsoft:**

- Click **Microsoft** → **Enable**
- Similar to GitHub, you'll need Azure App registration

---

## 💻 Usage Examples

### Basic Setup

First, initialize the repository in your app:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_auth_repository/firebase_auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _authRepository = FirebaseAuthRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: AuthWrapper(authRepository: _authRepository),
    );
  }
}
```

### Email/Password Authentication

#### Sign Up with Email/Password

```dart
class SignUpScreen extends StatelessWidget {
  final FirebaseAuthRepository _authRepository;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  SignUpScreen({required FirebaseAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<void> _signUp() async {
    try {
      await _authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      // Success - user is automatically signed in
      print('Sign up successful!');
    } on FirebaseAuthException catch (e) {
      // Handle error - the plugin provides user-friendly messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Sign In with Email/Password

```dart
Future<void> _signIn() async {
  try {
    await _authRepository.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    print('Sign in successful!');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Sign in failed')),
    );
  }
}
```

#### Password Reset

```dart
Future<void> _resetPassword() async {
  try {
    await _authRepository.resetPassword(
      email: _emailController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent!')),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Failed to send reset email')),
    );
  }
}
```

### Social Authentication

#### Google Sign-In

```dart
Future<void> _signInWithGoogle() async {
  try {
    // Replace with your actual Server Client ID
    const serverClientId = '123456789-abcdefghijklmnop.apps.googleusercontent.com';

    await _authRepository.signInWithGoogle(
      serverClientId: serverClientId,
    );
    print('Google sign in successful!');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Google sign in failed')),
    );
  }
}
```

#### Facebook Sign-In

```dart
Future<void> _signInWithFacebook() async {
  try {
    await _authRepository.signInWithFacebook();
    print('Facebook sign in successful!');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Facebook sign in failed')),
    );
  }
}
```

#### GitHub Sign-In

```dart
Future<void> _signInWithGitHub() async {
  try {
    await _authRepository.signInWithGitHub();
    print('GitHub sign in successful!');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'GitHub sign in failed')),
    );
  }
}
```

#### Microsoft Sign-In

```dart
Future<void> _signInWithMicrosoft() async {
  try {
    await _authRepository.signInWithMicrosoft();
    print('Microsoft sign in successful!');
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Microsoft sign in failed')),
    );
  }
}
```

### Listening to Auth State

#### Auth State Wrapper

```dart
class AuthWrapper extends StatelessWidget {
  final FirebaseAuthRepository authRepository;

  const AuthWrapper({required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is signed in
          return HomeScreen(
            user: snapshot.data!,
            authRepository: authRepository,
          );
        } else {
          // User is not signed in
          return SignInScreen(authRepository: authRepository);
        }
      },
    );
  }
}
```

#### Home Screen with User Info

```dart
class HomeScreen extends StatelessWidget {
  final User user;
  final FirebaseAuthRepository authRepository;

  const HomeScreen({required this.user, required this.authRepository});

  Future<void> _signOut() async {
    try {
      await authRepository.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
              child: user.photoURL == null
                ? Icon(Icons.person, size: 50)
                : null,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome, ${user.displayName ?? user.email ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Text('Email: ${user.email ?? 'N/A'}'),
            Text('UID: ${user.uid}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📖 API Reference

### Constructor

```dart
FirebaseAuthRepository({
  FirebaseAuth? firebaseAuth,
  FirebaseFirestore? firebaseFirestore,
  GoogleSignIn? googleSignIn,
})
```

Create an instance of the repository. All parameters are optional and will use default instances if not provided.

### Properties

| Property           | Type            | Description                                                      |
| ------------------ | --------------- | ---------------------------------------------------------------- |
| `authStateChanges` | `Stream<User?>` | Stream that emits current user or `null` when auth state changes |

### Methods

| Method                | Parameters                  | Returns        | Description                                            |
| --------------------- | --------------------------- | -------------- | ------------------------------------------------------ |
| `signUp`              | `email`, `password`, `name` | `Future<void>` | Create user with email/password and Firestore document |
| `signIn`              | `email`, `password`         | `Future<void>` | Sign in with email/password                            |
| `signInWithGoogle`    | `serverClientId`            | `Future<void>` | Initiate Google Sign-In flow                           |
| `signInWithFacebook`  | -                           | `Future<void>` | Initiate Facebook Sign-In flow                         |
| `signInWithGitHub`    | -                           | `Future<void>` | Initiate GitHub Sign-In flow                           |
| `signInWithMicrosoft` | -                           | `Future<void>` | Initiate Microsoft Sign-In flow                        |
| `signOut`             | -                           | `Future<void>` | Sign out current user from all providers               |
| `resetPassword`       | `email`                     | `Future<void>` | Send password reset email                              |

### Method Details

#### signUp

```dart
Future<void> signUp({
  required String email,
  required String password,
  required String name,
}) async
```

Creates a new user account and automatically creates a user document in Firestore with the following structure:

```json
{
  "uid": "user_uid",
  "name": "User Name",
  "email": "user@example.com",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### signInWithGoogle

```dart
Future<void> signInWithGoogle({
  required String serverClientId,
}) async
```

**Important**: You must provide the `serverClientId` from your `google-services.json` file.

### Error Handling

All methods throw `FirebaseAuthException` with user-friendly messages. Common error codes:

| Error Code               | Message                                                    |
| ------------------------ | ---------------------------------------------------------- |
| `invalid-credential`     | Invalid credentials. Please check your email and password. |
| `invalid-email`          | The email address is badly formatted.                      |
| `user-disabled`          | This user account has been disabled.                       |
| `user-not-found`         | No account found for this email.                           |
| `wrong-password`         | Incorrect password. Please try again.                      |
| `email-already-in-use`   | This email is already registered with another account.     |
| `weak-password`          | Your password is too weak. Please use a stronger one.      |
| `network-request-failed` | Network error. Please check your internet connection.      |

---

## 🚨 Error Handling

The plugin provides comprehensive error handling with user-friendly messages. Here's how to handle errors properly:

### Basic Error Handling Pattern

```dart
try {
  await _authRepository.signIn(
    email: email,
    password: password,
  );
  // Success
} on FirebaseAuthException catch (e) {
  // The plugin automatically converts Firebase errors to user-friendly messages
  print('Auth Error: ${e.message}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message ?? 'An error occurred')),
  );
} catch (e) {
  // Handle any other errors
  print('Unexpected error: $e');
}
```

### Complete Error Handling Example

```dart
class AuthService {
  final FirebaseAuthRepository _authRepository = FirebaseAuthRepository();

  Future<AuthResult> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email: email, password: password);
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(e.message ?? 'Sign in failed');
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  AuthResult._(this.isSuccess, this.errorMessage);

  factory AuthResult.success() => AuthResult._(true, null);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}
```

---

## 🔗 Firestore Integration

The plugin automatically integrates with Firestore to create user documents. Here's what you need to know:

### Automatic User Document Creation

When a user signs up or signs in for the first time (with social providers), the plugin automatically creates a document in the `users` collection:

```json
{
  "uid": "firebase_user_uid",
  "name": "User Display Name",
  "email": "user@example.com",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### Accessing User Data from Firestore

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }
}
```

### Real-time User Data Stream

```dart
Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data());
}
```

---

## 🔒 Firestore Security Rules

**Critical**: You must configure Firestore security rules to protect user data. Here are recommended rules:

### Basic Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Example: Public read, authenticated write for a posts collection
    match /posts/{postId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Advanced Security Rules

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidUserData() {
      return request.resource.data.keys().hasAll(['uid', 'name', 'email']) &&
             request.resource.data.uid == request.auth.uid &&
             request.resource.data.email == request.auth.token.email;
    }

    // Users collection with validation
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow create: if isAuthenticated() && isOwner(userId) && isValidUserData();
      allow update: if isAuthenticated() && isOwner(userId) && isValidUserData();
      allow delete: if false; // Prevent deletion
    }
  }
}
```

### Testing Security Rules

Use the Firebase Console Rules Playground to test your rules:

1. Go to **Firestore Database** → **Rules**
2. Click **Rules playground**
3. Test different scenarios with authenticated/unauthenticated users

---

## ⚠️ Common Issues & Solutions

### 1. Google Sign-In Issues

**Problem**: "No server client ID provided" or "Google sign-in failed"

**Solutions**:

- Verify your `serverClientId` from `google-services.json`
- Ensure SHA-1 fingerprint is added to Firebase project
- Check if Google Sign-In is enabled in Firebase Console

```dart
// Correct way to get server client ID
// From google-services.json, find client with "client_type": 3
const serverClientId = "123456789-abcdefg.apps.googleusercontent.com";

await _authRepository.signInWithGoogle(serverClientId: serverClientId);
```

### 2. Facebook Sign-In Issues

**Problem**: Facebook login fails or shows configuration errors

**Solutions**:

- Verify `facebook_app_id` and `facebook_client_token` in `strings.xml`
- Ensure minSdkVersion is 21 or higher
- Add SHA-1 fingerprint to Facebook app settings
- Check if Facebook Login is enabled in Firebase Console

```xml
<!-- Correct strings.xml configuration -->
<resources>
    <string name="facebook_app_id">1234567890123456</string>
    <string name="facebook_client_token">abcdef1234567890abcdef1234567890</string>
</resources>
```

### 3. Firebase Initialization Issues

**Problem**: "Firebase not initialized" error

**Solution**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make sure Firebase is initialized before using any Firebase services
  await Firebase.initializeApp();

  runApp(MyApp());
}
```

### 4. Gradle Build Issues

**Problem**: Build fails with dependency conflicts

**Solutions**:

- Update Android Gradle Plugin version
- Ensure compatibility between Firebase and Google Services versions
- Clean and rebuild the project

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### 5. Firestore Permission Denied

**Problem**: "Missing or insufficient permissions" error

**Solutions**:

- Check Firestore security rules
- Ensure user is authenticated before accessing Firestore
- Verify document path and user permissions

### 6. Network/Connection Issues

**Problem**: "Network request failed" errors

**Solutions**:

- Check internet connection
- Verify Firebase project configuration
- Ensure API keys are correct and not restricted

### 7. SHA-1 Fingerprint Issues

**Problem**: Google/Facebook sign-in fails due to fingerprint mismatch

**Solution**:
Get and add your SHA-1 fingerprint:

```bash
# For debug builds
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias
```

Add the fingerprint to:

- Firebase Project Settings → Your apps → SHA certificate fingerprints
- Facebook App Settings → Basic → Android → Key Hashes

---

## 🔧 Plugin Structure

## 🛠️ For Maintainers & Contributors

This plugin follows Flutter's standard plugin architecture and was created with `flutter create --template=plugin`.

### Plugin Structure

```
flutter_firebase_auth_repository/
├── android/                          # Android-specific code
│   ├── build.gradle                  # Android build configuration
│   └── src/main/
│       ├── AndroidManifest.xml       # Plugin manifest with Facebook config
│       └── kotlin/com/example/firebase_auth_repository/
│           └── FirebaseAuthRepositoryPlugin.kt
├── lib/
│   └── firebase_auth_repository.dart # Main Dart implementation
├── pubspec.yaml                      # Plugin dependencies and metadata
├── README.md                         # This documentation
└── CHANGELOG.md                      # Version history
```

### Key Implementation Details

#### Native Android Configuration

The plugin includes its own `AndroidManifest.xml` that automatically merges with your app's manifest:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.INTERNET"/>
  <application>
    <meta-data android:name="com.facebook.sdk.ApplicationId"
               android:value="@string/facebook_app_id"/>
    <meta-data android:name="com.facebook.sdk.ClientToken"
               android:value="@string/facebook_client_token"/>
  </application>
</manifest>
```

#### Dependency Management

The plugin automatically includes required dependencies:

- `firebase_auth`: For Firebase Authentication
- `cloud_firestore`: For user document creation
- `google_sign_in`: For Google authentication
- `flutter_facebook_auth`: For Facebook authentication

### Development Setup

1. Clone the repository
2. Run `flutter pub get`
3. For testing, create a test app in the `example/` directory
4. Configure Firebase for the test app

### Contributing Guidelines

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes** with proper documentation
4. **Add tests** for new functionality
5. **Update documentation** including this README
6. **Submit a pull request**

### Code Style

- Follow Dart's official style guide
- Use meaningful variable and function names
- Add comprehensive documentation for public APIs
- Handle errors gracefully with user-friendly messages

### Testing

Run tests with:

```bash
flutter test
```

For integration testing:

```bash
flutter drive --target=test_driver/app.dart
```

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙌 Maintained By

Made with ❤️ by Dattaram Kolte

---

## 🐞 Troubleshooting

### Quick Checklist

Before opening an issue, please check:

- [ ] Flutter SDK version is 3.3.0+
- [ ] All required dependencies are added to `pubspec.yaml`
- [ ] Firebase project is properly configured
- [ ] `google-services.json` is in the correct location (`android/app/`)
- [ ] Gradle plugins are properly applied
- [ ] Authentication providers are enabled in Firebase Console
- [ ] SHA-1 fingerprints are added (for Google/Facebook)
- [ ] Facebook credentials are correctly set in `strings.xml`

### Debug Steps

1. **Enable debug logging**:

   ```dart
   import 'package:firebase_core/firebase_core.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Enable debug logging
     await Firebase.initializeApp(
       options: FirebaseOptions(
         // ... your options
       ),
     );

     runApp(MyApp());
   }
   ```

2. **Check Firebase connection**:

   ```dart
   void checkFirebaseConnection() {
     final app = Firebase.app();
     print('Firebase app name: ${app.name}');
     print('Firebase project ID: ${app.options.projectId}');
   }
   ```

3. **Verify auth state**:
   ```dart
   void checkAuthState() {
     FirebaseAuth.instance.authStateChanges().listen((user) {
       print('Auth state changed: ${user?.uid ?? 'No user'}');
     });
   }
   ```

### Getting Help

1. **Check existing issues** on GitHub
2. **Search Firebase documentation**
3. **Ask on Stack Overflow** with tags: `flutter`, `firebase-auth`, `dart`
4. **Open a GitHub issue** with:
   - Flutter/Dart versions
   - Error messages and stack traces
   - Steps to reproduce
   - Relevant configuration files (without sensitive data)

### Performance Tips

- Use `StreamBuilder` for auth state to avoid unnecessary rebuilds
- Cache user data locally when possible
- Implement proper loading states
- Handle offline scenarios gracefully

---

## 📱 Complete Example App

This plugin comes with a comprehensive example that demonstrates all features. The example app includes:

### 🚀 Try the Example

```bash
# Clone the repository
git clone https://github.com/MineHope16/Flutter-Dev-Firebase-Authentication-Repository.git

# Navigate to example
cd firebase_auth_repository/example

# Install dependencies
flutter pub get

# Run the example
flutter run
```

### 🎯 Example Features

The example app demonstrates:

- **✅ Email/Password Authentication**

  - User registration with validation
  - Sign-in with error handling
  - Password reset functionality
  - Real-time form validation

- **✅ Social Authentication**

  - Google Sign-In with proper configuration
  - Facebook Sign-In with custom UI
  - GitHub Sign-In integration
  - Microsoft Sign-In support

- **✅ Real-time Auth State Management**

  - StreamBuilder implementation
  - Automatic navigation between screens
  - Auth state persistence

- **✅ User Interface Examples**

  - Modern Material Design 3 UI
  - Loading states and error handling
  - Responsive design patterns
  - Custom social sign-in buttons

- **✅ Firestore Integration**
  - Automatic user document creation
  - User profile display
  - Timestamp handling

### 📁 Example Structure

```
example/
├── lib/
│   ├── main.dart                 # Main app with StreamBuilder auth wrapper
│   ├── pages/                    # Screen implementations
│   └── widgets/
│       ├── email_password_form.dart      # Reusable email/password form
│       └── social_signin_buttons.dart    # Social sign-in button widgets
├── android/                      # Android configuration
│   ├── app/
│   │   ├── build.gradle         # Android build configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml      # App manifest with Facebook config
│   │       └── res/values/
│   │           └── strings.xml           # Facebook app credentials
│   └── build.gradle             # Project-level build configuration
├── SETUP.md                     # Detailed setup instructions
└── README.md                    # Example-specific documentation
```

### 🔧 Quick Setup for Example

1. **Firebase Configuration**:

   ```bash
   # Download google-services.json from Firebase Console
   # Place it in example/android/app/
   ```

2. **Update Google Client ID**:

   ```dart
   // In example/lib/main.dart, replace:
   const serverClientId = 'YOUR_GOOGLE_SERVER_CLIENT_ID';
   // With your actual Web Client ID from google-services.json
   ```

3. **Facebook Setup** (Optional):

   ```xml
   <!-- In example/android/app/src/main/res/values/strings.xml -->
   <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
   ```

4. **Run the Example**:
   ```bash
   cd example
   flutter run
   ```

### 📖 Learning from the Example

#### Auth State Management

```dart
// example/lib/main.dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authRepository = FirebaseAuthRepository();

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasData) {
          return HomePage(authRepository: authRepository);
        } else {
          return LoginPage(authRepository: authRepository);
        }
      },
    );
  }
}
```

#### Email/Password Authentication

```dart
// example/lib/widgets/email_password_form.dart
Future<void> _handleEmailAuth() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    if (_isSignUp) {
      await widget.authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } else {
      await widget.authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  } catch (e) {
    _showErrorMessage(e.toString());
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Social Authentication

```dart
// example/lib/widgets/social_signin_buttons.dart
Future<void> _handleGoogleSignIn() async {
  try {
    const serverClientId = 'YOUR_GOOGLE_SERVER_CLIENT_ID';
    await widget.authRepository.signInWithGoogle(
      serverClientId: serverClientId,
    );
    _showSuccessMessage('Google sign-in successful!');
  } catch (e) {
    _showErrorMessage('Google sign-in failed: ${e.toString()}');
  }
}
```

### 📚 Step-by-Step Tutorial

For detailed setup instructions, see:

- **[SETUP.md](example/SETUP.md)** - Complete setup guide with screenshots
- **[README.md](example/README.md)** - Example-specific documentation

### 🐛 Common Example Issues

#### Google Sign-In Not Working

```bash
# Check if you're using the correct serverClientId
# It should be the Web Client ID from google-services.json
# Look for "client_type": 3 in the JSON file
```

#### Facebook Sign-In Issues

```bash
# Verify Facebook App ID in strings.xml
# Check if your app hash is added to Facebook Developer Console
# Ensure Facebook app is in Live mode for production
```

#### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd example
flutter run
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute

- **Report bugs**: Open issues with detailed descriptions
- **Suggest features**: Propose new authentication providers or features
- **Improve documentation**: Help make this README even better
- **Submit code**: Fix bugs or add new features
- **Write tests**: Help improve test coverage

### Contribution Process

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Add tests** for new functionality
5. **Update documentation**
6. **Commit your changes**: `git commit -m 'Add amazing feature'`
7. **Push to the branch**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**

### Development Guidelines

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Write comprehensive tests
- Update documentation for API changes
- Ensure backward compatibility when possible

### Code of Conduct

Please be respectful and inclusive. We're here to build great software together!
