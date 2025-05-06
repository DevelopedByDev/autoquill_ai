import Cocoa

class RecordingOverlayWindow: NSPanel {
    static let shared = RecordingOverlayWindow()
    private let label = NSTextField()
    
    private init() {
        // Create a borderless panel that stays on top of all other windows
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 40),
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
            let xPos = screenFrame.width - 220
            let yPos = screenFrame.height - 60
            self.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        // Create a visual effect view for the background (semi-transparent)
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
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
        label.frame = NSRect(x: 0, y: 0, width: 200, height: 40)
        
        // Add the views
        visualEffectView.addSubview(label)
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
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async {
            // Animate out
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                self.animator().alphaValue = 0
            }, completionHandler: {
                self.orderOut(nil)
            })
        }
    }
}
