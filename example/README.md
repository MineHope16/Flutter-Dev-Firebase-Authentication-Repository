# Firebase Auth Repository Example

This example demonstrates how to use the `flutter_firebase_auth_repository` plugin in a Flutter application. It showcases all the authentication methods supported by the plugin.

## 🚀 Quick Start

### Prerequisites

Before running this example, make sure you have:

1. **Flutter SDK** installed (>= 3.3.0)
2. **Android Studio** or **VS Code** with Flutter extensions
3. **Firebase project** created at [Firebase Console](https://console.firebase.google.com/)
4. **Google Cloud Console** access for OAuth configurations

### 1. Firebase Setup

#### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable Authentication and Firestore Database

#### Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Package name: `com.example.firebase_auth_repository_example`
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### Step 3: Enable Authentication Methods

In Firebase Console → Authentication → Sign-in method, enable:

- ✅ Email/Password
- ✅ Google
- ✅ Facebook (optional)
- ✅ GitHub (optional)
- ✅ Microsoft (optional)

### 2. Google Sign-In Configuration

#### Get Google Server Client ID

1. Open your `google-services.json` file
2. Find the `client_id` where `"client_type": 3` (Web client ID)
3. Copy this value
4. Replace `YOUR_GOOGLE_SERVER_CLIENT_ID` in `lib/main.dart` with this value

**Example:**

```dart
const serverClientId = '123456789-abcdefg.apps.googleusercontent.com';
```

### 3. Facebook Sign-In Configuration (Optional)

#### Step 1: Create Facebook App

1. Go to [Facebook for Developers](https://developers.facebook.com/)
2. Create a new app
3. Add Facebook Login product

#### Step 2: Configure Android

1. In Facebook app settings, add Android platform
2. Add your package name: `com.example.firebase_auth_repository_example`
3. Add your key hashes (for development, you can use debug keystore)

#### Step 3: Update Credentials

In `android/app/src/main/res/values/strings.xml`, replace:

```xml
<string name="facebook_app_id">YOUR_ACTUAL_FACEBOOK_APP_ID</string>
<string name="facebook_client_token">YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
```

#### Step 4: Add to Firebase

In Firebase Console → Authentication → Sign-in method → Facebook:

- Add your Facebook App ID and App Secret

### 4. GitHub Sign-In Configuration (Optional)

#### Step 1: Create GitHub OAuth App

1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Create a new OAuth App
3. Authorization callback URL: `https://YOUR_PROJECT_ID.firebaseapp.com/__/auth/handler`

#### Step 2: Add to Firebase

In Firebase Console → Authentication → Sign-in method → GitHub:

- Add your GitHub Client ID and Client Secret

### 5. Microsoft Sign-In Configuration (Optional)

#### Step 1: Azure App Registration

1. Go to [Azure Portal](https://portal.azure.com/)
2. Register a new application
3. Add redirect URI: `https://YOUR_PROJECT_ID.firebaseapp.com/__/auth/handler`

#### Step 2: Add to Firebase

In Firebase Console → Authentication → Sign-in method → Microsoft:

- Add your Microsoft Application ID

### 6. Run the Example

```bash
# Navigate to the example directory
cd example

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 Features Demonstrated

This example app demonstrates:

### ✅ Email/Password Authentication

- User registration with name, email, and password
- User sign-in with email and password
- Password reset functionality
- Form validation and error handling

### ✅ Social Authentication

- Google Sign-In
- Facebook Sign-In (when configured)
- GitHub Sign-In (when configured)
- Microsoft Sign-In (when configured)

### ✅ Real-time Auth State

- Listen to authentication state changes
- Automatic navigation between login and home screens
- User information display

### ✅ Firestore Integration

- Automatic user document creation on first sign-up
- User data storage (UID, name, email, creation timestamp)

### ✅ Error Handling

- User-friendly error messages for common Firebase Auth errors
- Network error handling
- Form validation

## 🎯 Code Structure

```
lib/
├── main.dart           # Main app entry point
├── auth_wrapper.dart   # Handles auth state changes
├── login_page.dart     # Login/Registration UI
└── home_page.dart      # Authenticated user home screen
```

### Key Components

#### AuthWrapper

Listens to authentication state changes and routes users to appropriate screens:

```dart
StreamBuilder<User?>(
  stream: authRepository.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return HomePage();
    } else {
      return LoginPage();
    }
  },
)
```

#### Email/Password Auth

```dart
// Sign Up
await authRepository.signUp(
  email: email,
  password: password,
  name: name,
);

// Sign In
await authRepository.signIn(
  email: email,
  password: password,
);
```

#### Social Authentication

```dart
// Google
await authRepository.signInWithGoogle(
  serverClientId: 'YOUR_GOOGLE_SERVER_CLIENT_ID',
);

// Facebook
await authRepository.signInWithFacebook();

// GitHub
await authRepository.signInWithGitHub();

// Microsoft
await authRepository.signInWithMicrosoft();
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Google Sign-In Not Working

- **Problem**: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)`
- **Solution**: Make sure you're using the correct `serverClientId` from your `google-services.json`

#### 2. Facebook Sign-In Not Working

- **Problem**: Facebook login button doesn't respond
- **Solution**:
  - Verify Facebook App ID in `strings.xml`
  - Check if Facebook app is in development/live mode
  - Ensure your SHA-1 key hash is added to Facebook app

#### 3. Build Errors

- **Problem**: Android build fails
- **Solution**:
  - Run `flutter clean && flutter pub get`
  - Check if `google-services.json` is in the correct location
  - Verify minimum SDK version is 21

#### 4. Firebase Not Initialized

- **Problem**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`
- **Solution**: Ensure `Firebase.initializeApp()` is called before `runApp()`

### Debug Tips

1. **Check Firebase Console Logs**: Monitor authentication events in Firebase Console
2. **Enable Debug Mode**: Add `--debug` flag when running Flutter app
3. **Check Network**: Ensure device has internet connection
4. **Verify Configuration**: Double-check all configuration files and credentials

## 📚 Additional Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [Facebook Login Plugin](https://pub.dev/packages/flutter_facebook_auth)

## 🆘 Need Help?

If you encounter issues:

1. Check this README thoroughly
2. Verify all configuration steps
3. Check the [plugin documentation](../README.md)
4. Search for existing issues on GitHub
5. Create a new issue with detailed error logs

## 📄 License

This example is part of the Firebase Auth Repository plugin and is licensed under the MIT License.
