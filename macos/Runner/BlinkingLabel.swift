import Cocoa

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
                // Format with left padding for the red dot
                var baseText = "REC AUDIO"
                
                // Add hotkey instructions below
                var instructions = ""
                if let finish = finishHotkey {
                    instructions += "\(finish) to stop"
                } else {
                    instructions += "W to stop"
                }
                if let cancel = cancelHotkey {
                    if !instructions.isEmpty {
                        instructions += " • "
                    }
                    instructions += "\(cancel) to cancel"
                }
                
                // Combine main parts
                baseText += "\n" + instructions
                
                // Add mode at the bottom right with explicit positioning
                if !mode.isEmpty {
                    // Create a separate label for the mode
                    DispatchQueue.main.async {
                        RecordingOverlayWindow.shared.setModeText(mode)
                    }
                }
                
                return baseText
            case .stopped: return "REC STOPPED"
            case .processing: return "PROCESSING"
            case .completed: return "COMPLETE"
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
                        background: NSColor.black.withAlphaComponent(0.8),
                        accent: NSColor.systemPurple,
                        text: NSColor.white
                    )
                } else if mode.lowercased().contains("push") {
                    // Blue theme for Push-to-Talk
                    return (
                        background: NSColor.black.withAlphaComponent(0.8),
                        accent: NSColor.systemBlue,
                        text: NSColor.white
                    )
                } else {
                    // Red/Pink theme for Transcription (default)
                    return (
                        background: NSColor.black.withAlphaComponent(0.8),
                        accent: NSColor.systemRed,
                        text: NSColor.white
                    )
                }
            case .stopped:
                return (
                    background: NSColor.black.withAlphaComponent(0.8),
                    accent: NSColor.systemOrange,
                    text: NSColor.white
                )
            case .processing:
                return (
                    background: NSColor.black.withAlphaComponent(0.8),
                    accent: NSColor.systemYellow,
                    text: NSColor.white
                )
            case .completed:
                return (
                    background: NSColor.black.withAlphaComponent(0.8),
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
        self.alignment = .left
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        self.drawsBackground = false
        self.textColor = NSColor.white
        self.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
        self.wantsLayer = true
        
        // Add line spacing for better readability
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        self.attributedStringValue = NSAttributedString(
            string: self.stringValue,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: NSColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        // Add text shadow for better readability
        self.shadow = NSShadow()
        self.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.5)
        self.shadow?.shadowOffset = NSSize(width: 0, height: -1)
        self.shadow?.shadowBlurRadius = 2
    }
    
    func setState(_ state: TextState) {
        self.currentState = state
        
        // Create attributed string with proper spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .left
        
        // Update text color based on state
        let colors = state.colors
        self.textColor = colors.text
        
        // Get the text content
        let textContent = state.text
        
        // Create an attributed string with the base styling
        let attributedText = NSMutableAttributedString(
            string: textContent,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: colors.text,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        // Apply the attributed string with proper styling
        self.attributedStringValue = attributedText
        
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