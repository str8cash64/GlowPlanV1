# GlowPlan

## Firebase Setup Instructions

To fix the "No such module 'FirebaseAuth'" error, you need to:

1. Install CocoaPods if you haven't already:
   ```
   sudo gem install cocoapods
   ```

2. Run pod install in the project directory:
   ```
   cd /path/to/GlowPlan
   pod install
   ```

3. Make sure to use the `.xcworkspace` file, not the `.xcodeproj` file after running pod install.

4. Add your Firebase configuration file:
   - Create a Firebase project at https://console.firebase.google.com/
   - Add an iOS app to your Firebase project with your app's bundle ID
   - Download the `GoogleService-Info.plist` file
   - Add it to your Xcode project (drag and drop into your project navigator)

For more detailed setup instructions, please refer to the Firebase-Setup.md file in the project.