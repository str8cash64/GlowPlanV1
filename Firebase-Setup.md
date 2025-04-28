# Firebase Setup for GlowPlan

> ⚠️ **IMPORTANT**: You must complete the setup steps below and add your `GoogleService-Info.plist` file to the project before the app will function correctly. The app is designed to gracefully handle missing Firebase configuration, but core features like user accounts and data synchronization require Firebase.

This document provides instructions for setting up Firebase in your GlowPlan app.

## Prerequisites

- Xcode 14.0 or later
- CocoaPods (if not installed, run `sudo gem install cocoapods`)
- A Google account for Firebase access

## Setup Instructions

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project
4. Make sure to enable Google Analytics if prompted

### 2. Register Your iOS App with Firebase

1. In the Firebase project console, click "Add app" and select iOS
2. Enter your app's bundle ID (e.g., `com.yourcompany.glowplan`)
3. (Optional) Enter an app nickname and App Store ID
4. Click "Register App"
5. Download the `GoogleService-Info.plist` file

### 3. Add the Configuration File to Your Project

1. Move the downloaded `GoogleService-Info.plist` file to your Xcode project's root directory
2. In Xcode, right-click on your project in the navigator
3. Select "Add Files to [Your Project Name]"
4. Select the `GoogleService-Info.plist` file
5. Make sure "Copy items if needed" is checked
6. Click "Add"

### 4. Install Dependencies with CocoaPods

The project already includes a `Podfile` with the necessary Firebase dependencies. To install them:

1. Open Terminal and navigate to your project directory
2. Run `pod install`
3. After installation completes, open the `.xcworkspace` file, not the `.xcodeproj` file

### 5. Enable Authentication Methods

1. In the Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable "Email/Password" authentication
3. Save your changes

### 6. Set Up Firestore Database

1. In the Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose either "Start in production mode" or "Start in test mode" (for development)
4. Select a location for your database
5. Click "Enable"

### 7. Configure Firestore Security Rules

For development, you can use these permissive rules (update them before production):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /profile/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /routines/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

To set these rules:
1. In the Firebase Console, go to "Firestore Database" > "Rules"
2. Replace the existing rules with the ones above
3. Click "Publish"

## Troubleshooting

- **Error with multiple occurrences in collection**: This typically means your GoogleService-Info.plist is not properly configured or added to the project
- If you see "No such module 'Firebase'", make sure you've run `pod install` and are opening the `.xcworkspace` file
- If authentication fails, check that you've properly enabled Email/Password authentication in the Firebase Console
- For build errors related to iOS version compatibility, ensure your `Podfile` has the correct iOS platform version

## Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore) 