import Cocoa
import FlutterMacOS
import AudioToolbox

@main
class AppDelegate: FlutterAppDelegate {
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Get the main Flutter view controller
    let controller: FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    
    // Set up the permissions method channel
    let permissionChannel = FlutterMethodChannel(
      name: "com.autoquill.permissions",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    permissionChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handlePermissionMethodCall(call: call, result: result)
    }
    
    // Set up the sound settings method channel
    let soundChannel = FlutterMethodChannel(
      name: "com.autoquill.sound",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    soundChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleSoundMethodCall(call: call, result: result)
    }
    
    super.applicationDidFinishLaunching(notification)
  }
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  // MARK: - Permission Method Call Handler
  
  private func handlePermissionMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(macOS 11.0, *) else {
      result(FlutterError(code: "UNSUPPORTED", message: "macOS 11.0 or later required", details: nil))
      return
    }
    
    switch call.method {
    case "checkPermission":
      handleCheckPermission(call: call, result: result)
    case "requestPermission":
      handleRequestPermission(call: call, result: result)
    case "openSystemPreferences":
      handleOpenSystemPreferences(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  @available(macOS 11.0, *)
  private func handleCheckPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let typeString = args["type"] as? String,
          let permissionType = PermissionService.PermissionType(rawValue: typeString) else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid permission type", details: nil))
      return
    }
    
    let status = PermissionService.checkPermission(for: permissionType)
    result(status.rawValue)
  }
  
  @available(macOS 11.0, *)
  private func handleRequestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let typeString = args["type"] as? String,
          let permissionType = PermissionService.PermissionType(rawValue: typeString) else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid permission type", details: nil))
      return
    }
    
    PermissionService.requestPermission(for: permissionType) { status in
      DispatchQueue.main.async {
        result(status.rawValue)
      }
    }
  }
  
  @available(macOS 11.0, *)
  private func handleOpenSystemPreferences(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let typeString = args["type"] as? String,
          let permissionType = PermissionService.PermissionType(rawValue: typeString) else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid permission type", details: nil))
      return
    }
    
    PermissionService.openSystemPreferences(for: permissionType)
    result(nil)
  }
  
  // MARK: - Sound Method Call Handler
  
  private func handleSoundMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setSoundEnabled":
      handleSetSoundEnabled(call: call, result: result)
    case "getSoundEnabled":
      handleGetSoundEnabled(call: call, result: result)
    case "playSystemSound":
      handlePlaySystemSound(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleSetSoundEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enabled = args["enabled"] as? Bool else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid enabled value", details: nil))
      return
    }
    
    // Store the sound preference in UserDefaults for platform-specific access
    UserDefaults.standard.set(enabled, forKey: "sound_enabled")
    result(nil)
  }
  
  private func handleGetSoundEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let soundEnabled = UserDefaults.standard.object(forKey: "sound_enabled") as? Bool ?? true
    result(soundEnabled)
  }
  
  private func handlePlaySystemSound(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let soundType = args["type"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid sound type", details: nil))
      return
    }
    
    // Check if sounds are enabled
    let soundEnabled = UserDefaults.standard.object(forKey: "sound_enabled") as? Bool ?? true
    if !soundEnabled {
      result(nil)
      return
    }
    
    // Play system sounds based on type
    switch soundType {
    case "glass":
      NSSound(named: "Glass")?.play()
    case "ping":
      NSSound(named: "Ping")?.play()
    case "pop":
      NSSound(named: "Pop")?.play()
    case "purr":
      NSSound(named: "Purr")?.play()
    case "sosumi":
      NSSound(named: "Sosumi")?.play()
    case "submarine":
      NSSound(named: "Submarine")?.play()
    case "blow":
      NSSound(named: "Blow")?.play()
    case "bottle":
      NSSound(named: "Bottle")?.play()
    case "frog":
      NSSound(named: "Frog")?.play()
    case "funk":
      NSSound(named: "Funk")?.play()
    case "morse":
      NSSound(named: "Morse")?.play()
    default:
      // Default to a simple beep using AudioServicesPlaySystemSound
      AudioServicesPlaySystemSound(1000) // System sound ID for beep
    }
    
    result(nil)
  }
}
