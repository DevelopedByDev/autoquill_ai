import Cocoa
import FlutterMacOS

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
}
