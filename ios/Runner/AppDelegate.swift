import UIKit
import Flutter
import GoogleMaps
import Firebase
import flutter_local_notifications


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "googleMapApiKey") as? String {
        print("DEBUG: found googleMapApiKey in Info.plist = '\(apiKey)'")
        if apiKey.starts(with: "$") {
            print("ERROR: Google Map Api Key variable not substituted! Check xcconfig.")
        } else {
            GMSServices.provideAPIKey(apiKey)
        }
    } else {
        print("ERROR: googleMapApiKey not found in Info.plist")
    }

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
