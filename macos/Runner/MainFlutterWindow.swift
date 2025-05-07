import Cocoa
import FlutterMacOS
import AVFoundation

// Blinking label for recording indicator
class BlinkingLabel: NSTextField {
    private var blinkTimer: Timer?
    private var isVisible = true
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.stringValue = "Recording..."
        self.alignment = .center
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        self.drawsBackground = false
        self.textColor = NSColor.white
        self.font = NSFont.boldSystemFont(ofSize: 14)
    }
    
    func startBlinking() {
        // Stop any existing timer
        stopBlinking()
        
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

// Recording overlay window implementation
class RecordingOverlayWindow: NSPanel {
    static let shared = RecordingOverlayWindow()
    private let blinkingLabel = BlinkingLabel(frame: NSRect(x: 0, y: 0, width: 180, height: 80))
    
    private init() {
        // Create a borderless panel that stays on top of all other windows
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 180, height: 80),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        // Configure the window
        self.level = .floating // Make it float above other windows
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        
        // Position in the top-right corner of the screen
        if let screenFrame = NSScreen.main?.visibleFrame {
            let xPos = screenFrame.width - 200
            let yPos = screenFrame.height - 100
            self.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        // Create a visual effect view for the background (semi-transparent)
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 180, height: 80))
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 15
        
        // Configure the blinking label to fill the entire window
        blinkingLabel.frame = NSRect(x: 0, y: 0, width: 180, height: 80)
        
        // Add the view
        visualEffectView.addSubview(blinkingLabel)
        self.contentView = visualEffectView
        
        // Make the window level high enough to appear above full-screen apps
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
    
    func showOverlay() {
        DispatchQueue.main.async {
            self.orderFront(nil)
            
            // Add a subtle animation
            self.alphaValue = 0
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 1.0
            })
            
            // Start the blinking animation
            self.blinkingLabel.startBlinking()
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async {
            // Stop the blinking animation
            self.blinkingLabel.stopBlinking()
            
            // Animate out
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
    }
    
    // Method to update audio level (now a no-op since we're not showing audio levels)
    func updateAudioLevel(_ level: Float) {
        // No-op since we're not showing audio levels anymore
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
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
