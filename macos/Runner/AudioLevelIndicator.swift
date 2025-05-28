import Cocoa

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