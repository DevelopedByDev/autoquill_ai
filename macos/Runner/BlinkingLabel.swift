import Cocoa

// Protocol for BlinkingLabel to communicate with its parent
protocol BlinkingLabelDelegate: AnyObject {
    func blinkingLabel(_ label: BlinkingLabel, didUpdateColors colors: (background: NSColor, accent: NSColor, text: NSColor))
    func blinkingLabel(_ label: BlinkingLabel, didSetModeText mode: String)
}

// Blinking label for recording indicator
class BlinkingLabel: NSTextField {
    private var blinkTimer: Timer?
    private var isVisible = true
    weak var parentDelegate: BlinkingLabelDelegate?
    
    // Store the last known hotkeys to preserve them across state updates
    private var lastKnownFinishHotkey: String?
    private var lastKnownCancelHotkey: String?
    
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
                
                // Add finish hotkey instruction based on mode
                var instructions = ""
                let finishKey = finishHotkey ?? "?"
                if mode.lowercased().contains("push") {
                    instructions += "release \(finishKey) to stop"
                } else {
                    instructions += "\(finishKey) to stop"
                }
                
                // Add cancel hotkey instruction
                let cancelKey = cancelHotkey ?? "Esc"
                instructions += "\n\(cancelKey) to cancel"
                
                // Combine main parts
                baseText += "\n" + instructions
                
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
        
        var mode: String {
            switch self {
            case .recording(let mode, _, _):
                return mode
            default:
                return ""
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
        // If this is a recording state, preserve the hotkeys
        if case .recording(let mode, let finishHotkey, let cancelHotkey) = state {
            // Store hotkeys if they are provided
            if let finish = finishHotkey {
                lastKnownFinishHotkey = finish
            }
            if let cancel = cancelHotkey {
                lastKnownCancelHotkey = cancel
            }
            
            // Use stored hotkeys if current ones are nil
            let effectiveFinishHotkey = finishHotkey ?? lastKnownFinishHotkey
            let effectiveCancelHotkey = cancelHotkey ?? lastKnownCancelHotkey
            
            // Create a new state with the effective hotkeys
            let effectiveState = TextState.recording(mode: mode, finishHotkey: effectiveFinishHotkey, cancelHotkey: effectiveCancelHotkey)
            self.currentState = effectiveState
        } else {
            self.currentState = state
        }
        
        // Create attributed string with proper spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .left
        
        // Update text color based on state
        let colors = currentState.colors
        self.textColor = colors.text
        
        // Get the text content
        let textContent = currentState.text
        
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
        
        // Notify delegate about color and mode changes
        parentDelegate?.blinkingLabel(self, didUpdateColors: colors)
        
        // Set mode text via delegate
        let mode = currentState.mode
        if !mode.isEmpty {
            parentDelegate?.blinkingLabel(self, didSetModeText: mode)
        }
        
        if currentState.shouldBlink {
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