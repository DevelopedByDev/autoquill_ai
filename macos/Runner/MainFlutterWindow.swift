import Cocoa
import FlutterMacOS
import AVFoundation
import CoreGraphics

// Extension to convert NSBezierPath to CGPath
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            case .quadraticCurveTo:
                path.addQuadCurve(to: points[1], control: points[0])
            @unknown default:
                break
            }
        }
        
        return path
    }
}

// BlinkingLabel and RecordingOverlayWindow classes are retained for recording functionality

// Blinking label for recording indicator
class BlinkingLabel: NSTextField {
    private var blinkTimer: Timer?
    private var isVisible = true
    
    // Text states for different recording and transcription states
    enum TextState {
        case recording(mode: String, finishHotkey: String?, cancelHotkey: String?)
        case stopped
        case processing
        case completed
        
        var text: String {
            switch self {
            case .recording(let mode, let finishHotkey, let cancelHotkey):
                var baseText = ""
                if mode.isEmpty {
                    baseText = "🎙️ Recording..."
                } else {
                    baseText = "🎙️ \(mode)\nRecording..."
                }
                
                // Add hotkey instructions
                var instructions = ""
                if let finish = finishHotkey {
                    instructions += "Finish \(finish)"
                }
                if let cancel = cancelHotkey {
                    if !instructions.isEmpty {
                        instructions += "  •  "
                    }
                    instructions += "Cancel \(cancel)"
                }
                
                if !instructions.isEmpty {
                    baseText += "\n\n\(instructions)"
                }
                
                return baseText
            case .stopped: return "⏹️ Recording Stopped"
            case .processing: return "⚡ Processing..."
            case .completed: return "✅ Complete!"
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
        
        var colors: (background: NSColor, accent: NSColor, text: NSColor) {
            switch self {
            case .recording(let mode, _, _):
                if mode.lowercased().contains("assistant") {
                    // Purple theme for Assistant
                    return (
                        background: NSColor.systemPurple.withAlphaComponent(0.15),
                        accent: NSColor.systemPurple,
                        text: NSColor.white
                    )
                } else if mode.lowercased().contains("push") {
                    // Blue theme for Push-to-Talk
                    return (
                        background: NSColor.systemBlue.withAlphaComponent(0.15),
                        accent: NSColor.systemBlue,
                        text: NSColor.white
                    )
                } else {
                    // Red/Pink theme for Transcription (default)
                    return (
                        background: NSColor.systemPink.withAlphaComponent(0.15),
                        accent: NSColor.systemPink,
                        text: NSColor.white
                    )
                }
            case .stopped:
                return (
                    background: NSColor.systemOrange.withAlphaComponent(0.15),
                    accent: NSColor.systemOrange,
                    text: NSColor.white
                )
            case .processing:
                return (
                    background: NSColor.systemYellow.withAlphaComponent(0.15),
                    accent: NSColor.systemYellow,
                    text: NSColor.black
                )
            case .completed:
                return (
                    background: NSColor.systemGreen.withAlphaComponent(0.15),
                    accent: NSColor.systemGreen,
                    text: NSColor.white
                )
            }
        }
    }
    
    private var currentState: TextState = .recording(mode: "", finishHotkey: nil, cancelHotkey: nil)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.stringValue = TextState.recording(mode: "", finishHotkey: nil, cancelHotkey: nil).text
        self.alignment = .center
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        self.drawsBackground = false
        self.textColor = NSColor.white
        self.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        self.wantsLayer = true
        
        // Add text shadow for better readability
        self.shadow = NSShadow()
        self.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.5)
        self.shadow?.shadowOffset = NSSize(width: 0, height: -1)
        self.shadow?.shadowBlurRadius = 2
    }
    
    func setState(_ state: TextState) {
        self.currentState = state
        self.stringValue = state.text
        
        // Update text color based on state
        let colors = state.colors
        self.textColor = colors.text
        
        // Notify parent to update background
        if let overlayWindow = self.superview?.window as? RecordingOverlayWindow {
            overlayWindow.updateColors(colors)
        }
        
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

// Audio Level Indicator with animated bars
class AudioLevelIndicator: NSView {
    private var audioLevel: Float = 0.0
    private var bars: [CAShapeLayer] = []
    private let numberOfBars = 5
    private var animationTimer: Timer?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.wantsLayer = true
    }
    
    override func layout() {
        super.layout()
        setupBars()
    }
    
    private func setupBars() {
        // Clear existing bars
        bars.forEach { $0.removeFromSuperlayer() }
        bars.removeAll()
        
        let barWidth: CGFloat = 3
        let barSpacing: CGFloat = 2
        let totalWidth = CGFloat(numberOfBars) * barWidth + CGFloat(numberOfBars - 1) * barSpacing
        let startX = (bounds.width - totalWidth) / 2
        
        for i in 0..<numberOfBars {
            let bar = CAShapeLayer()
            let x = startX + CGFloat(i) * (barWidth + barSpacing)
            let maxHeight: CGFloat = 20
            let height: CGFloat = 2 + (maxHeight - 2) * CGFloat(i + 1) / CGFloat(numberOfBars)
            
            bar.frame = CGRect(x: x, y: (bounds.height - height) / 2, width: barWidth, height: height)
            bar.backgroundColor = NSColor.white.withAlphaComponent(0.3).cgColor
            bar.cornerRadius = barWidth / 2
            
            layer?.addSublayer(bar)
            bars.append(bar)
        }
    }
    
    func setAudioLevel(_ level: Float) {
        audioLevel = max(0.0, min(1.0, level))
        updateBars()
    }
    
    private func updateBars() {
        for (index, bar) in bars.enumerated() {
            let barThreshold = Float(index) / Float(numberOfBars)
            let isActive = audioLevel > barThreshold
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            bar.backgroundColor = isActive ? 
                NSColor.white.cgColor : 
                NSColor.white.withAlphaComponent(0.2).cgColor
            CATransaction.commit()
        }
    }
    
    func startAnimating() {
        stopAnimating()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Add subtle random movement when no audio
            if self?.audioLevel ?? 0 < 0.1 {
                let randomLevel = Float.random(in: 0.05...0.15)
                self?.setAudioLevel(randomLevel)
            }
        }
    }
    
    func stopAnimating() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// Enhanced RecordingOverlayWindow with beautiful animated effects
class RecordingOverlayWindow: NSPanel {
    static let shared = RecordingOverlayWindow()
    private let blinkingLabel = BlinkingLabel()
    private let audioLevelIndicator = AudioLevelIndicator()
    private var visualEffectView: NSVisualEffectView!
    private var backgroundLayer: CAGradientLayer!
    private var pulseLayer: CAShapeLayer!
    
    // Dragging support
    private var isDragging = false
    private var dragStartLocation: NSPoint = .zero

    // Define window dimensions as class properties
    private let windowWidth: CGFloat = 280
    private let windowHeight: CGFloat = 120
    
    // UserDefaults keys for position persistence
    private let positionXKey = "RecordingOverlayPositionX"
    private let positionYKey = "RecordingOverlayPositionY"
    
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
        self.ignoresMouseEvents = false  // Enable mouse events for dragging
        self.isMovableByWindowBackground = false

        // Restore saved position or use default
        restoreSavedPosition()

        setupUI()
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
    
    private func restoreSavedPosition() {
        let defaults = UserDefaults.standard
        
        // Check if we have saved position
        if defaults.object(forKey: positionXKey) != nil && defaults.object(forKey: positionYKey) != nil {
            let savedX = defaults.double(forKey: positionXKey)
            let savedY = defaults.double(forKey: positionYKey)
            let savedPosition = NSPoint(x: savedX, y: savedY)
            
            // Validate that the saved position is still on screen
            if let screenFrame = NSScreen.main?.visibleFrame {
                let windowFrame = NSRect(origin: savedPosition, size: NSSize(width: windowWidth, height: windowHeight))
                
                // Check if the window would be completely off-screen
                if screenFrame.intersects(windowFrame) {
                    self.setFrameOrigin(savedPosition)
                    return
                }
            }
        }
        
        // Use default position if no saved position or saved position is off-screen
        if let screenFrame = NSScreen.main?.visibleFrame {
            let xPos = screenFrame.maxX - windowWidth - 25
            let yPos = screenFrame.maxY - windowHeight - 25
            self.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
    }
    
    private func saveCurrentPosition() {
        let defaults = UserDefaults.standard
        let currentOrigin = self.frame.origin
        defaults.set(currentOrigin.x, forKey: positionXKey)
        defaults.set(currentOrigin.y, forKey: positionYKey)
        defaults.synchronize()
    }
    
    // Override mouse events for dragging
    override func mouseDown(with event: NSEvent) {
        isDragging = true
        // Store the mouse position relative to the window's origin
        dragStartLocation = event.locationInWindow
        
        // Change cursor to closed hand during drag
        NSCursor.closedHand.push()
        
        // Add visual feedback when dragging starts
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            self.animator().alphaValue = 0.8
        })
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        
        // Get the current mouse position in screen coordinates
        let mouseLocationInScreen = NSEvent.mouseLocation
        
        // Calculate the new window origin by offsetting the mouse position
        // by the initial click offset within the window
        let newOrigin = NSPoint(
            x: mouseLocationInScreen.x - dragStartLocation.x,
            y: mouseLocationInScreen.y - dragStartLocation.y
        )
        
        // Constrain to screen bounds
        if let screenFrame = NSScreen.main?.visibleFrame {
            let constrainedX = max(screenFrame.minX, min(newOrigin.x, screenFrame.maxX - windowWidth))
            let constrainedY = max(screenFrame.minY, min(newOrigin.y, screenFrame.maxY - windowHeight))
            
            self.setFrameOrigin(NSPoint(x: constrainedX, y: constrainedY))
        } else {
            self.setFrameOrigin(newOrigin)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if isDragging {
            isDragging = false
            
            // Restore cursor
            NSCursor.pop()
            
            // Save the new position
            saveCurrentPosition()
            
            // Restore full opacity
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                self.animator().alphaValue = 1.0
            })
        }
    }
    
    // Add cursor tracking for better UX
    override func mouseEntered(with event: NSEvent) {
        if !isDragging {
            NSCursor.openHand.set()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if !isDragging {
            NSCursor.arrow.set()
        }
    }
    
    private func setupUI() {
        // Create the main visual effect view
        visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        if #available(macOS 10.14, *) {
            visualEffectView.material = .hudWindow
            visualEffectView.appearance = NSAppearance(named: .darkAqua)
        } else {
            visualEffectView.material = .ultraDark
        }
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 25
        
        // Create gradient background layer
        backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = visualEffectView.bounds
        backgroundLayer.cornerRadius = 25
        backgroundLayer.colors = [
            NSColor.systemPink.withAlphaComponent(0.3).cgColor,
            NSColor.systemPink.withAlphaComponent(0.1).cgColor
        ]
        backgroundLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundLayer.endPoint = CGPoint(x: 1, y: 1)
        visualEffectView.layer?.insertSublayer(backgroundLayer, at: 0)
        
        // Create pulse layer for breathing effect
        pulseLayer = CAShapeLayer()
        let pulsePath = NSBezierPath(roundedRect: visualEffectView.bounds, xRadius: 25, yRadius: 25)
        pulseLayer.path = pulsePath.cgPath
        pulseLayer.fillColor = NSColor.clear.cgColor
        pulseLayer.strokeColor = NSColor.white.withAlphaComponent(0.4).cgColor
        pulseLayer.lineWidth = 2
        visualEffectView.layer?.addSublayer(pulseLayer)
        
        // Setup label
        blinkingLabel.frame = NSRect(x: 15, y: 35, width: windowWidth - 30, height: 70)
        blinkingLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        visualEffectView.addSubview(blinkingLabel)
        
        // Setup audio level indicator
        audioLevelIndicator.frame = NSRect(x: 20, y: 10, width: windowWidth - 40, height: 20)
        visualEffectView.addSubview(audioLevelIndicator)
        
        // Add border and shadow
        visualEffectView.layer?.borderColor = NSColor.white.withAlphaComponent(0.3).cgColor
        visualEffectView.layer?.borderWidth = 1
        visualEffectView.layer?.shadowColor = NSColor.black.cgColor
        visualEffectView.layer?.shadowOpacity = 0.3
        visualEffectView.layer?.shadowOffset = CGSize(width: 0, height: 4)
        visualEffectView.layer?.shadowRadius = 12
        
        self.contentView = visualEffectView
        
        // Add tracking area for cursor changes
        let trackingArea = NSTrackingArea(
            rect: visualEffectView.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        visualEffectView.addTrackingArea(trackingArea)
    }

    func updateColors(_ colors: (background: NSColor, accent: NSColor, text: NSColor)) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        
        // Update gradient background
        backgroundLayer.colors = [
            colors.accent.withAlphaComponent(0.4).cgColor,
            colors.accent.withAlphaComponent(0.1).cgColor
        ]
        
        // Update pulse layer
        pulseLayer.strokeColor = colors.accent.withAlphaComponent(0.6).cgColor
        
        // Update shadow color
        visualEffectView.layer?.shadowColor = colors.accent.cgColor
        
        CATransaction.commit()
        
        // Start pulse animation
        startPulseAnimation(color: colors.accent)
    }
    
    private func startPulseAnimation(color: NSColor) {
        // Remove existing animations
        pulseLayer.removeAllAnimations()
        
        // Create breathing pulse animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.05
        scaleAnimation.duration = 1.2
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 1.2
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        pulseLayer.add(scaleAnimation, forKey: "pulseScale")
        pulseLayer.add(opacityAnimation, forKey: "pulseOpacity")
    }

    func showOverlay() {
        showOverlayWithMode("")
    }
    
    func showOverlayWithMode(_ mode: String) {
        showOverlayWithModeAndHotkeys(mode, finishHotkey: nil, cancelHotkey: "Esc")
    }
    
    func showOverlayWithModeAndHotkeys(_ mode: String, finishHotkey: String?, cancelHotkey: String?) {
        DispatchQueue.main.async {
            // Ensure window is properly positioned and visible
            self.level = .floating
            self.orderFront(nil)
            self.alphaValue = 0
            self.setIsVisible(true)
            
            // Scale in animation
            self.contentView?.layer?.transform = CATransform3DMakeScale(0.8, 0.8, 1.0)
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.4
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.animator().alphaValue = 1.0
            })
            
            // Transform animation
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            self.contentView?.layer?.transform = CATransform3DIdentity
            CATransaction.commit()
            
            // Set initial state to recording with the specified mode and hotkeys
            self.setOverlayState(.recording(mode: mode, finishHotkey: finishHotkey, cancelHotkey: cancelHotkey))
            self.audioLevelIndicator.startAnimating()
        }
    }

    func hideOverlay() {
        DispatchQueue.main.async {
            self.blinkingLabel.stopBlinking()
            self.audioLevelIndicator.stopAnimating()
            self.pulseLayer.removeAllAnimations()
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
            
            // Scale out animation
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
            self.contentView?.layer?.transform = CATransform3DMakeScale(0.9, 0.9, 1.0)
            CATransaction.commit()
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
        DispatchQueue.main.async {
            self.audioLevelIndicator.setAudioLevel(level)
        }
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
