import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

// ─────────────────────────────────────────────────────────────────────────────
// iOS Push Notifications Setup Guide
//
// BEFORE building for a real device you MUST complete these steps in Xcode:
//
// 1. Open ios/Runner.xcworkspace in Xcode.
// 2. Select the "Runner" target → "Signing & Capabilities" tab.
// 3. Click "+ Capability" → add "Push Notifications".
// 4. Click "+ Capability" → add "Background Modes".
//    ✅ Check "Remote notifications" under Background Modes.
// 5. Ensure GoogleService-Info.plist is dragged into the Runner target
//    (Target Membership must include Runner).
// 6. In Firebase Console → Project Settings → Cloud Messaging → Apple app →
//    upload your APNs Authentication Key (.p8) or APNs Certificate.
//
// Once a Developer Account is active, flutter_local_notifications and
// firebase_messaging will handle the rest automatically.
// ─────────────────────────────────────────────────────────────────────────────

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Flutter plugin registration (includes Firebase, FCM, local notifications)
    GeneratedPluginRegistrant.register(with: self)

    // Set UNUserNotificationCenter delegate so FCM can intercept notifications
    // when the app is in the foreground.
    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called when APNs successfully registered — forward the token to Firebase.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
