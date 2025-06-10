import Cocoa
import FlutterMacOS
import AudioToolbox

@main
class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private let whisperKitService = WhisperKitService()
  private var progressEventSink: FlutterEventSink?
  
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
    
    // Set up the WhisperKit method channel
    let whisperKitChannel = FlutterMethodChannel(
      name: "com.autoquill.whisperkit",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    whisperKitChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleWhisperKitMethodCall(call: call, result: result)
    }
    
    // Set up the WhisperKit progress event channel
    let progressEventChannel = FlutterEventChannel(
      name: "com.autoquill.whisperkit.progress",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    progressEventChannel.setStreamHandler(self)
    
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
  
  // MARK: - WhisperKit Method Call Handler
  
  private func handleWhisperKitMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitializeWhisperKit(call: call, result: result)
    case "downloadModel":
      handleDownloadModel(call: call, result: result)
    case "getDownloadedModels":
      handleGetDownloadedModels(call: call, result: result)
    case "isModelDownloaded":
      handleIsModelDownloaded(call: call, result: result)
    case "deleteModel":
      handleDeleteModel(call: call, result: result)
    case "getModelSize":
      handleGetModelSize(call: call, result: result)
    case "getModelsDirectory":
      handleGetModelsDirectory(call: call, result: result)
    case "openModelsDirectory":
      handleOpenModelsDirectory(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleInitializeWhisperKit(call: FlutterMethodCall, result: @escaping FlutterResult) {
    Task {
      do {
        try await whisperKitService.initialize()
        DispatchQueue.main.async {
          result(nil)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "INITIALIZATION_ERROR", message: "Failed to initialize WhisperKit: \(error)", details: nil))
        }
      }
    }
  }
  
  private func handleDownloadModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelName = args["modelName"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid model name", details: nil))
      return
    }
    
    Task {
      do {
        try await whisperKitService.downloadModel(modelName) { [weak self] progress in
          DispatchQueue.main.async {
            self?.progressEventSink?([
              "modelName": modelName,
              "progress": progress
            ])
          }
        }
        DispatchQueue.main.async {
          result(nil)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "DOWNLOAD_ERROR", message: "Failed to download model \(modelName): \(error)", details: nil))
        }
      }
    }
  }
  
  private func handleGetDownloadedModels(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let downloadedModels = whisperKitService.getDownloadedModels()
    result(downloadedModels)
  }
  
  private func handleIsModelDownloaded(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelName = args["modelName"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid model name", details: nil))
      return
    }
    
    let isDownloaded = whisperKitService.isModelDownloaded(modelName)
    result(isDownloaded)
  }
  
  private func handleDeleteModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelName = args["modelName"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid model name", details: nil))
      return
    }
    
    let success = whisperKitService.deleteModel(modelName)
    result(success)
  }
  
  private func handleGetModelSize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let modelName = args["modelName"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid model name", details: nil))
      return
    }
    
    let size = whisperKitService.getModelSize(modelName)
    result(size)
  }
  
  private func handleGetModelsDirectory(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let directory = whisperKitService.getModelsDirectory()
    result(directory)
  }
  
  private func handleOpenModelsDirectory(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let success = whisperKitService.openModelsDirectory()
    result(success)
  }
  
  // MARK: - FlutterStreamHandler
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    progressEventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    progressEventSink = nil
    return nil
  }
}
