import Cocoa
import FlutterMacOS
import AVFoundation
import CoreGraphics

class MainFlutterWindow: NSWindow {
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
      // The extractVisibleText case has been removed as we now use the screen_capturer package
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
} 