import Cocoa
import FlutterMacOS
import AVFoundation
import CoreGraphics

class MainFlutterWindow: NSWindow {
  
  // Static reference to the method channel for overlay communication
  private static var overlayChannel: FlutterMethodChannel?
  
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Set up method channel for recording overlay
    setupMethodChannel(flutterViewController: flutterViewController)

    super.awakeFromNib()
  }
  
  private func setupMethodChannel(flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "com.autoquill.recording_overlay",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    
    // Store the channel reference for use by the close button
    MainFlutterWindow.overlayChannel = channel
    
    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "showOverlay":
        RecordingOverlayWindow.shared.showOverlay()
        result(nil)
      case "showOverlayWithMode":
        if let args = call.arguments as? [String: Any],
           let mode = args["mode"] as? String {
          RecordingOverlayWindow.shared.showOverlayWithMode(mode)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", 
                             message: "Expected mode parameter", 
                             details: nil))
        }
      case "showOverlayWithModeAndHotkeys":
        if let args = call.arguments as? [String: Any],
           let mode = args["mode"] as? String {
          let finishHotkey = args["finishHotkey"] as? String
          let cancelHotkey = args["cancelHotkey"] as? String
          RecordingOverlayWindow.shared.showOverlayWithModeAndHotkeys(mode, finishHotkey: finishHotkey, cancelHotkey: cancelHotkey)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", 
                             message: "Expected mode parameter", 
                             details: nil))
        }
      case "hideOverlay":
        RecordingOverlayWindow.shared.hideOverlay()
        result(nil)
      case "updateAudioLevel":
        if let args = call.arguments as? [String: Any],
           let level = args["level"] as? Double {
          // Convert to Float for the audio level update
          RecordingOverlayWindow.shared.updateAudioLevel(Float(level))
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", 
                             message: "Expected level parameter", 
                             details: nil))
        }
      case "setRecordingStopped":
        RecordingOverlayWindow.shared.setRecordingStopped()
        result(nil)
      case "setProcessingAudio":
        RecordingOverlayWindow.shared.setProcessingAudio()
        result(nil)
      case "setTranscriptionCompleted":
        RecordingOverlayWindow.shared.setTranscriptionCompleted()
        result(nil)
      case "cancelRecording":
        // Handle close button press from overlay
        // Send the cancel message back to Flutter to handle the recording cancellation
        channel.invokeMethod("cancelRecording", arguments: nil)
        result(nil)
      // The extractVisibleText case has been removed as we now use the screen_capturer package
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  /// Static method to handle close button press from overlay
  static func handleOverlayCloseButtonPressed() {
    print("MainFlutterWindow: Handling overlay close button press")
    
    // Send the cancel message through the method channel
    overlayChannel?.invokeMethod("cancelRecording", arguments: nil) { result in
      if let error = result as? FlutterError {
        print("Error calling cancelRecording: \(error.message ?? "Unknown error")")
      } else {
        print("cancelRecording called successfully")
      }
    }
  }
} 