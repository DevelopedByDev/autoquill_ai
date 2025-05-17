import Cocoa
import FlutterMacOS
import AVFoundation
import Vision
import CoreGraphics

// Screen OCR utility class for extracting text from screenshots
class ScreenOCR {
    static let shared = ScreenOCR()
    
    private init() {}
    
    func captureScreenAndExtractText(completion: @escaping (String) -> Void) {
        // Create a temporary file path for the screenshot
        let tempDir = FileManager.default.temporaryDirectory
        let screenshotPath = tempDir.appendingPathComponent("autoquill_screenshot.png")
        
        // Use the screencapture command line tool
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-x", screenshotPath.path] // -x for silent capture (no sound)
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 && FileManager.default.fileExists(atPath: screenshotPath.path) {
                // Extract text using OCR
                self.extractTextFromImage(at: screenshotPath.path, completion: completion)
            } else {
                completion("Error: Failed to capture screenshot")
            }
        } catch {
            completion("Error: \(error.localizedDescription)")
        }
    }
    
    private func extractTextFromImage(at path: String, completion: @escaping (String) -> Void) {
        let imageURL = URL(fileURLWithPath: path)
        guard let image = NSImage(contentsOf: imageURL),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion("Error: Could not load image for OCR")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            let text = observations.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(text)
        }
        
        request.recognitionLanguages = ["en-US"]
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            completion("OCR Error: \(error.localizedDescription)")
        }
    }
}

// Blinking label for recording indicator
class BlinkingLabel: NSTextField {
    private var blinkTimer: Timer?
    private var isVisible = true
    
    // Text states for different recording and transcription states
    enum TextState {
        case recording(mode: String)
        case stopped
        case processing
        case completed
        
        var text: String {
            switch self {
            case .recording(let mode):
                if mode.isEmpty {
                    return "Recording..."
                } else {
                    return "Recording...\n(\(mode) mode)"
                }
            case .stopped: return "Recording stopped"
            case .processing: return "Processing..."
            case .completed: return "Transcription copied"
            }
        }
        
        var shouldBlink: Bool {
            switch self {
            case .recording, .processing:
                return true
            default:
                return false
            }
        }
    }
    
    private var currentState: TextState = .recording(mode: "")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.stringValue = TextState.recording(mode: "").text
        self.alignment = .center
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        self.drawsBackground = false
        self.textColor = NSColor.white
        self.font = NSFont.boldSystemFont(ofSize: 14)
    }
    
    func setState(_ state: TextState) {
        self.currentState = state
        self.stringValue = state.text
        
        if state.shouldBlink {
            startBlinking()
        } else {
            stopBlinking()
        }
    }
    
    func startBlinking() {
        // Stop any existing timer
        stopBlinking()
        
        // Only blink if the current state should blink
        guard currentState.shouldBlink else { return }
        
        // Create a new timer that fires every 1 second
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Animate the alpha value smoothly
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                self.animator().alphaValue = self.isVisible ? 0.3 : 1.0
            })
            
            // Toggle visibility state
            self.isVisible = !self.isVisible
        }
    }
    
    func stopBlinking() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        self.alphaValue = 1.0
    }
    
    deinit {
        stopBlinking()
    }
}

// Enhanced RecordingOverlayWindow with neumorphic glow and rounded blur
class RecordingOverlayWindow: NSPanel {
    static let shared = RecordingOverlayWindow()
    private let blinkingLabel = BlinkingLabel(frame: NSRect(x: 10, y: 20, width: 160, height: 40))

    // Define window dimensions as class properties
    private let windowWidth: CGFloat = 180
    private let windowHeight: CGFloat = 80
    
    private init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = true
        self.isMovableByWindowBackground = false

        if let screenFrame = NSScreen.main?.visibleFrame {
            let xPos = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
            let yPos = screenFrame.origin.y + 20  // 20 points from bottom of the visible area

            self.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }

        // Neumorphic Glass Background
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        if #available(macOS 10.14, *) {
            visualEffectView.material = .windowBackground
            visualEffectView.appearance = NSAppearance(named: .darkAqua)
        } else {
            // Fallback for older macOS versions
            visualEffectView.material = .ultraDark
        }
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 20
        visualEffectView.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        visualEffectView.layer?.borderWidth = 1
        visualEffectView.layer?.shadowColor = NSColor.systemPink.cgColor
        visualEffectView.layer?.shadowOpacity = 0.3
        visualEffectView.layer?.shadowOffset = .zero
        visualEffectView.layer?.shadowRadius = 10

        // Glow pulse animation
        let glow = CABasicAnimation(keyPath: "shadowRadius")
        glow.fromValue = 8
        glow.toValue = 14
        glow.duration = 1.5
        glow.autoreverses = true
        glow.repeatCount = .infinity
        visualEffectView.layer?.add(glow, forKey: "glowPulse")

        visualEffectView.addSubview(blinkingLabel)
        self.contentView = visualEffectView
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    func showOverlay() {
        showOverlayWithMode("")
    }
    
    func showOverlayWithMode(_ mode: String) {
        DispatchQueue.main.async {
            self.orderFront(nil)
            self.alphaValue = 0
            self.setIsVisible(true)
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.35
                self.animator().alphaValue = 1.0
                self.animator().contentView?.layer?.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            })
            // Set initial state to recording with the specified mode and start blinking
            self.setOverlayState(.recording(mode: mode))
        }
    }

    func hideOverlay() {
        DispatchQueue.main.async {
            self.blinkingLabel.stopBlinking()
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
    }
    
    func setOverlayState(_ state: BlinkingLabel.TextState) {
        DispatchQueue.main.async {
            self.blinkingLabel.setState(state)
        }
    }
    
    func setRecordingStopped() {
        setOverlayState(.stopped)
    }
    
    func setProcessingAudio() {
        setOverlayState(.processing)
    }
    
    func setTranscriptionCompleted() {
        setOverlayState(.completed)
    }

    func updateAudioLevel(_ level: Float) {
        // (Optional) Use level to animate future VU meter here
    }
}

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
      case "extractVisibleText":
        ScreenOCR.shared.captureScreenAndExtractText { text in
          result(text)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
