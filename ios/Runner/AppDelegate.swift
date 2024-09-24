import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          print("Documents Directory: \(documentsDirectory.path)")
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
