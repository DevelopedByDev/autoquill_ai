import Cocoa

// Enhanced RecordingOverlayWindow with beautiful animated effects
class RecordingOverlayWindow: NSPanel, BlinkingLabelDelegate {
    static let shared = RecordingOverlayWindow()
    private let blinkingLabel = BlinkingLabel()
    private let modeLabel = NSTextField()
    private let audioLevelIndicator = AudioLevelIndicator()
    private var visualEffectView: NSVisualEffectView!
    private var backgroundLayer: CAGradientLayer!
    private var pulseLayer: CAShapeLayer!
    
    // Dragging support
    private var isDragging = false
    private var dragStartLocation: NSPoint = .zero

    // Define window dimensions as class properties
    private let windowWidth: CGFloat = 380
    private let windowHeight: CGFloat = 120  // Increased from 100 to accommodate more text
    
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
        visualEffectView.layer?.cornerRadius = 12
        
        // Create gradient background layer
        backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = visualEffectView.bounds
        backgroundLayer.cornerRadius = 12
        // Use a more subtle dark background
        backgroundLayer.colors = [
            NSColor.black.withAlphaComponent(0.8).cgColor,
            NSColor.black.withAlphaComponent(0.7).cgColor
        ]
        backgroundLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundLayer.endPoint = CGPoint(x: 1, y: 1)
        visualEffectView.layer?.insertSublayer(backgroundLayer, at: 0)
        
        // Create pulse layer for breathing effect
        pulseLayer = CAShapeLayer()
        let pulsePath = NSBezierPath(roundedRect: visualEffectView.bounds, xRadius: 12, yRadius: 12)
        pulseLayer.path = pulsePath.cgPath
        pulseLayer.fillColor = NSColor.clear.cgColor
        pulseLayer.strokeColor = NSColor.white.withAlphaComponent(0.2).cgColor
        pulseLayer.lineWidth = 1
        visualEffectView.layer?.addSublayer(pulseLayer)
        
        // Setup label
        blinkingLabel.frame = NSRect(x: 25, y: 25, width: windowWidth - 40, height: 70)  // Moved down from y: 30 to y: 40 for more top spacing
        blinkingLabel.parentDelegate = self
        visualEffectView.addSubview(blinkingLabel)
        
        // No red dot, as requested
        
        // Setup mode label in the bottom right
        modeLabel.frame = NSRect(x: 0, y: 10, width: windowWidth - 20, height: 20)
        modeLabel.alignment = .right
        modeLabel.isBezeled = false
        modeLabel.isEditable = false
        modeLabel.isSelectable = false
        modeLabel.drawsBackground = false
        modeLabel.textColor = NSColor.white.withAlphaComponent(0.8)
        modeLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        modeLabel.stringValue = ""
        visualEffectView.addSubview(modeLabel)
        
        // Setup audio level indicator - hidden in this minimalist design
        audioLevelIndicator.isHidden = true
        
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
        CATransaction.setDisableActions(true)
        backgroundLayer.colors = [
            colors.background.cgColor,
            colors.background.cgColor
        ]
        pulseLayer.strokeColor = colors.accent.withAlphaComponent(0.4).cgColor
        CATransaction.commit()
        
        // Update mode label color
        modeLabel.textColor = colors.accent.withAlphaComponent(0.9)
        
        // Start pulse animation with the accent color
        startPulseAnimation(color: colors.accent)
    }
    
    func setModeText(_ mode: String) {
        // Set the mode text in the bottom right corner
        DispatchQueue.main.async {
            self.modeLabel.stringValue = mode
        }
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
    
    // MARK: - BlinkingLabelDelegate
    func blinkingLabel(_ label: BlinkingLabel, didUpdateColors colors: (background: NSColor, accent: NSColor, text: NSColor)) {
        updateColors(colors)
    }
    
    func blinkingLabel(_ label: BlinkingLabel, didSetModeText mode: String) {
        setModeText(mode)
    }
} 