import Cocoa
import AVFoundation

class WaveformView: NSView {
    private var amplitudes: [CGFloat] = Array(repeating: 0.05, count: 10)
    private let barWidth: CGFloat = 4
    private let barSpacing: CGFloat = 4
    private let maxBarHeight: CGFloat = 20
    private let minBarHeight: CGFloat = 3
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Clear the background
        context.clear(dirtyRect)
        
        // Set color for the bars
        context.setFillColor(NSColor.white.cgColor)
        
        // Calculate total width needed for all bars
        let totalWidth = CGFloat(amplitudes.count) * (barWidth + barSpacing) - barSpacing
        
        // Center the bars horizontally
        let startX = (bounds.width - totalWidth) / 2
        
        // Draw each bar
        for (index, amplitude) in amplitudes.enumerated() {
            let barHeight = minBarHeight + (maxBarHeight - minBarHeight) * amplitude
            let x = startX + CGFloat(index) * (barWidth + barSpacing)
            let y = (bounds.height - barHeight) / 2
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            context.fillEllipse(in: barRect)
        }
    }
    
    func updateWithAmplitude(_ amplitude: CGFloat) {
        // Shift amplitudes to the left (not actually moving visually)
        amplitudes.removeFirst()
        
        // Add new amplitude (clamped between 0 and 1)
        let clampedAmplitude = min(max(amplitude, 0), 1)
        amplitudes.append(clampedAmplitude)
        
        // Redraw the view
        self.needsDisplay = true
    }
    
    // Simulate animation when no actual audio data is available
    func startSimulation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Generate random amplitude
            let randomAmplitude = CGFloat.random(in: 0.05...0.8)
            self.updateWithAmplitude(randomAmplitude)
        }
    }
}

class RecordingOverlayWindow: NSPanel {
    static let shared = RecordingOverlayWindow()
    private let label = NSTextField()
    private let waveformView = WaveformView(frame: NSRect(x: 0, y: 0, width: 120, height: 30))
    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    
    private init() {
        // Create a borderless panel that stays on top of all other windows
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 60),
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
            let xPos = screenFrame.width - 240
            let yPos = screenFrame.height - 80
            self.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        // Create a visual effect view for the background (semi-transparent)
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 220, height: 60))
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 10
        
        // Configure the label
        label.stringValue = "Recording in progress..."
        label.alignment = .center
        label.isBezeled = false
        label.isEditable = false
        label.isSelectable = false
        label.drawsBackground = false
        label.textColor = NSColor.white
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.frame = NSRect(x: 0, y: 30, width: 220, height: 30)
        
        // Configure the waveform view
        waveformView.frame = NSRect(x: 50, y: 5, width: 120, height: 30)
        
        // Add the views
        visualEffectView.addSubview(label)
        visualEffectView.addSubview(waveformView)
        self.contentView = visualEffectView
        
        // Make the window level high enough to appear above full-screen apps
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Setup audio monitoring
        setupAudioMonitoring()
    }
    
    private func setupAudioMonitoring() {
        // We'll use a simulated waveform for now
        // In a real implementation, we would connect to the actual audio recording
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
            
            // Start the waveform simulation
            self.waveformView.startSimulation()
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async {
            // Stop the level timer if it's running
            self.levelTimer?.invalidate()
            self.levelTimer = nil
            
            // Animate out
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
    }
    
    // Method to update the waveform with real audio levels
    func updateAudioLevel(_ level: Float) {
        // Convert audio level to amplitude (0-1 range)
        // Audio levels are typically in decibels, so we need to convert
        // Typical values range from -160 (silence) to 0 (max volume)
        let normalizedLevel = max(0.0, min(1.0, (level + 50) / 50))
        waveformView.updateWithAmplitude(CGFloat(normalizedLevel))
    }
}
