# 🔧 Setup Guide for Firebase Auth Repository Example

This guide will walk you through setting up the Firebase Auth Repository example app step by step.

## ⚡ Quick Setup Checklist

Before you start, make sure you have these ready:

- [ ] Flutter SDK installed (>= 3.3.0)
- [ ] Android Studio or VS Code with Flutter extensions
- [ ] Google account for Firebase Console access
- [ ] Android device/emulator for testing

## 📋 Step-by-Step Setup

### 1. Firebase Project Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `firebase-auth-repository-example`
4. Enable Google Analytics (optional)
5. Choose or create Analytics account
6. Click "Create project"

#### Add Android App

1. In Firebase project overview, click Android icon
2. **Package name**: `com.example.firebase_auth_repository_example`
3. **App nickname**: Firebase Auth Repository Example
4. **Debug signing certificate SHA-1**: (optional for now)
5. Click "Register app"
6. **Download `google-services.json`**
7. Place it in `android/app/` directory

#### Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable these providers:
   - ✅ **Email/Password**: Click → Enable → Save
   - ✅ **Google**: Click → Enable → Save
   - ✅ **Facebook**: Click → Enable (configure later) → Save
   - ✅ **GitHub**: Click → Enable (configure later) → Save
   - ✅ **Microsoft**: Click → Enable (configure later) → Save

#### Enable Firestore

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select location closest to you
5. Click "Done"

### 2. Google Sign-In Configuration

#### Get Server Client ID

1. **Open `google-services.json`** (downloaded earlier)
2. **Find the Web Client ID**:
   ```json
   {
     "client": [
       {
         "client_info": {...},
         "client_type": 3  // Look for this type
       }
     ]
   }
   ```
3. **Copy the `client_id`** from the entry where `"client_type": 3`
4. **Update the code**: In `lib/main.dart`, replace:
   ```dart
   const serverClientId = 'YOUR_GOOGLE_SERVER_CLIENT_ID';
   ```
   with your actual client ID:
   ```dart
   const serverClientId = '123456789-abcdefg.apps.googleusercontent.com';
   ```

### 3. Facebook Sign-In Configuration (Optional)

#### Create Facebook App

1. Go to [Facebook for Developers](https://developers.facebook.com/)
2. Click "My Apps" → "Create App"
3. Choose "Consumer" → "Next"
4. App name: `Firebase Auth Repository Example`
5. Contact email: Your email
6. Click "Create App"

#### Add Facebook Login

1. In Facebook app dashboard, click "Add Product"
2. Find "Facebook Login" → Click "Set Up"
3. Choose "Android" → "Next"

#### Configure Android Platform

1. **Package Name**: `com.example.firebase_auth_repository_example`
2. **Class Name**: `com.example.firebase_auth_repository_example.MainActivity`
3. **Key Hashes**:
   - For development, use debug keystore hash
   - Run this command to get debug hash:
     ```bash
     keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
     ```
   - Default password: `android`

#### Get Facebook Credentials

1. In Facebook app, go to "Settings" → "Basic"
2. Copy **App ID** and **App Secret**
3. In Firebase Console → Authentication → Sign-in method → Facebook:
   - **App ID**: Paste Facebook App ID
   - **App Secret**: Paste Facebook App Secret
   - Click "Save"

#### Update Android Configuration

1. In `android/app/src/main/res/values/strings.xml`, replace:
   ```xml
   <string name="facebook_app_id">YOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
   ```
2. To find Client Token:
   - Facebook App → Settings → Advanced → Client Token

### 4. GitHub Sign-In Configuration (Optional)

#### Create GitHub OAuth App

1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. **Application name**: Firebase Auth Repository Example
4. **Homepage URL**: `https://your-project-id.firebaseapp.com`
5. **Authorization callback URL**: `https://your-project-id.firebaseapp.com/__/auth/handler`
6. Click "Register application"

#### Configure Firebase

1. Copy **Client ID** and **Client Secret**
2. In Firebase Console → Authentication → Sign-in method → GitHub:
   - **Client ID**: Paste GitHub Client ID
   - **Client Secret**: Paste GitHub Client Secret
   - Click "Save"

### 5. Microsoft Sign-In Configuration (Optional)

#### Azure App Registration

1. Go to [Azure Portal](https://portal.azure.com/)
2. Navigate to "Azure Active Directory" → "App registrations"
3. Click "New registration"
4. **Name**: Firebase Auth Repository Example
5. **Redirect URI**: `https://your-project-id.firebaseapp.com/__/auth/handler`
6. Click "Register"

#### Configure Firebase

1. Copy **Application (client) ID**
2. In Firebase Console → Authentication → Sign-in method → Microsoft:
   - **Client ID**: Paste Azure Application ID
   - Click "Save"

### 6. Run the Example

```bash
# Navigate to example directory
cd example

# Get dependencies
flutter pub get

# Check for issues
flutter doctor

# Run on Android device/emulator
flutter run
```

## 🎯 Verification Steps

### Test Each Authentication Method

1. **Email/Password**:

   - Try signing up with a new email
   - Try signing in with existing credentials
   - Test password reset

2. **Google Sign-In**:

   - Tap "Continue with Google"
   - Should open Google sign-in flow
   - Should redirect back to app upon success

3. **Social Sign-Ins** (if configured):
   - Test Facebook, GitHub, Microsoft
   - Verify they work without errors

### Check Firestore Integration

1. In Firebase Console → Firestore Database
2. After signing up a user, verify a document was created in `users` collection
3. Document should contain: `uid`, `name`, `email`, `createdAt`

## 🚨 Common Issues & Solutions

### Build Errors

#### "google-services.json not found"

- **Solution**: Ensure `google-services.json` is in `android/app/` directory
- **Check**: File should be at `android/app/google-services.json`

#### "Minimum SDK version"

- **Error**: Facebook SDK requires minimum SDK 21
- **Solution**: Already set in `android/app/build.gradle` (minSdkVersion 21)

#### "Gradle build failed"

- **Solution**:
  ```bash
  cd android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  ```

### Authentication Errors

#### Google Sign-In Fails

- **Error**: `PlatformException(sign_in_failed)`
- **Solution**: Double-check `serverClientId` in code matches Web Client ID from `google-services.json`

#### Facebook Sign-In Fails

- **Error**: Login dialog doesn't appear
- **Solutions**:
  - Verify Facebook App ID in `strings.xml`
  - Check if Facebook app is in "Live" mode (not Development)
  - Ensure key hashes are correct

### Network Errors

- **Error**: "Network request failed"
- **Solution**: Check internet connection, Firebase project status

## 📱 Testing on Device

### Android Testing

1. **Enable Developer Options** on your Android device
2. **Enable USB Debugging**
3. Connect device via USB
4. Run `flutter devices` to verify connection
5. Run `flutter run` to install and test

### Emulator Testing

1. **Start Android Emulator** from Android Studio
2. **Google Play Services**: Ensure emulator has Google Play Services for Google Sign-In
3. **Internet Connection**: Verify emulator has internet access

## 🔐 Security Considerations

### Development vs Production

#### For Development:

- ✅ Use debug keystore (already configured)
- ✅ Test mode for Firestore rules
- ✅ Facebook app in Development mode

#### For Production:

- 🔥 Generate production keystore
- 🔥 Update SHA-1 fingerprints in Firebase and Facebook
- 🔥 Update Firestore security rules
- 🔥 Set Facebook app to Live mode

### Firestore Security Rules

Replace test mode rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📞 Getting Help

### If you're stuck:

1. **Double-check this guide** - Most issues are configuration problems
2. **Check Flutter doctor**: `flutter doctor -v`
3. **Review error logs** carefully
4. **Check Firebase Console** for auth events
5. **Search GitHub issues** for similar problems

### Debug Commands:

```bash
# Check Flutter installation
flutter doctor -v

# Clean and rebuild
flutter clean && flutter pub get

# Run with verbose logging
flutter run -v

# Check connected devices
flutter devices
```

---

🎉 **Congratulations!** If you've followed this guide, you should now have a fully functional Firebase Authentication app with multiple sign-in providers!
