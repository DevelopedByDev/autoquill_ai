import Cocoa
import FlutterMacOS
import AVFoundation

// Pulsating sphere view for audio visualization
class PulsatingSphereView: NSView {
    private var currentAmplitude: CGFloat = 0.2
    private let minRadius: CGFloat = 10
    private let maxRadius: CGFloat = 25
    private let baseColor = NSColor(calibratedRed: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
    private var animationTimer: Timer?
    
    // Layer for the sphere
    private let sphereLayer = CAShapeLayer()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.wantsLayer = true
        self.layer?.masksToBounds = false
        
        // Configure the sphere layer
        sphereLayer.fillColor = baseColor.cgColor
        sphereLayer.shadowColor = baseColor.cgColor
        sphereLayer.shadowOffset = CGSize(width: 0, height: 0)
        sphereLayer.shadowRadius = 10
        sphereLayer.shadowOpacity = 0.7
        
        if let layer = self.layer {
            layer.addSublayer(sphereLayer)
        }
        
        updateSphereSize()
    }
    
    private func updateSphereSize() {
        let radius = minRadius + (maxRadius - minRadius) * currentAmplitude
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        // Create the sphere path
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: centerX, y: centerY), 
                   radius: radius, 
                   startAngle: 0, 
                   endAngle: 2 * .pi, 
                   clockwise: false)
        
        // Update the layer with the new path
        sphereLayer.path = path
        
        // Update shadow to match the size
        sphereLayer.shadowRadius = radius * 0.4
        
        // Update color intensity based on amplitude
        let intensity = 0.2 + (0.8 * currentAmplitude)
        sphereLayer.fillColor = baseColor.withAlphaComponent(intensity).cgColor
    }
    
    override func layout() {
        super.layout()
        updateSphereSize()
    }
    
    func updateWithAmplitude(_ amplitude: CGFloat) {
        // Clamp amplitude between 0 and 1
        let clampedAmplitude = min(max(amplitude, 0), 1)
        
        // Smoothly transition to the new amplitude
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        
        // Update the current amplitude
        self.currentAmplitude = clampedAmplitude
        
        // Update the sphere size and color
        updateSphereSize()
        
        CATransaction.commit()
    }
    
    // Simulate animation when no actual audio data is available
    func startSimulation() {
        // Stop any existing timer
        animationTimer?.invalidate()
        
        // Start a new timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Generate a somewhat realistic audio pattern
            let baseLevel = 0.2
            let randomComponent = CGFloat.random(in: 0...0.6)
            let spike = CGFloat.random(in: 0...1) < 0.1 ? CGFloat.random(in: 0.2...0.4) : 0.0
            
            let amplitude = min(1.0, baseLevel + randomComponent + spike)
            self.updateWithAmplitude(amplitude)
        }
    }
    
    func stopSimulation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// Recording overlay window implementation
class RecordingOverlayWindow: NSPanel {
    static let shared = RecordingOverlayWindow()
    private let label = NSTextField()
    private let sphereView = PulsatingSphereView(frame: NSRect(x: 0, y: 0, width: 60, height: 60))
    
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
        
        // Configure the label
        label.stringValue = "Recording in progress..."
        label.alignment = .center
        label.isBezeled = false
        label.isEditable = false
        label.isSelectable = false
        label.drawsBackground = false
        label.textColor = NSColor.white
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.frame = NSRect(x: 0, y: 50, width: 180, height: 30)
        
        // Configure the sphere view
        sphereView.frame = NSRect(x: 60, y: 0, width: 60, height: 50)
        
        // Add the views
        visualEffectView.addSubview(label)
        visualEffectView.addSubview(sphereView)
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
            
            // Start the sphere pulsation
            self.sphereView.startSimulation()
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async {
            // Stop the sphere simulation
            self.sphereView.stopSimulation()
            
            // Animate out
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
    }
    
    // Method to update the sphere with real audio levels
    func updateAudioLevel(_ level: Float) {
        // Convert audio level to amplitude (0-1 range)
        let normalizedLevel = max(0.0, min(1.0, CGFloat(level)))
        sphereView.updateWithAmplitude(normalizedLevel)
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
