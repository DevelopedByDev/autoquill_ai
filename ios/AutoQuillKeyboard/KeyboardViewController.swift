//
//  KeyboardViewController.swift
//  AutoQuillKeyboard
//
//  Created by Divyansh Lalwani on 6/3/25.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    // MARK: - UI State
    enum UIState {
        case modeSelection
        case recording
    }
    
    private var currentState: UIState = .modeSelection
    private var selectedMode: RecordingMode?
    
    enum RecordingMode {
        case handsFree
        case pushToTalk
        case assistant
        
        var title: String {
            switch self {
            case .handsFree: return "Hands-Free"
            case .pushToTalk: return "Push to Talk"
            case .assistant: return "Assistant"
            }
        }
        
        var icon: String {
            switch self {
            case .handsFree: return "mic.fill"
            case .pushToTalk: return "hand.tap.fill"
            case .assistant: return "sparkles"
            }
        }
        
        var color: UIColor {
            switch self {
            case .handsFree: return UIColor.systemRed
            case .pushToTalk: return UIColor.systemBlue
            case .assistant: return UIColor.systemPurple
            }
        }
    }
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let titleLabel = UILabel()
    
    // Mode Selection Buttons
    private let handsFreeModeButton = UIButton(type: .system)
    private let pushToTalkModeButton = UIButton(type: .system)
    private let assistantModeButton = UIButton(type: .system)
    private var modeButtons: [UIButton] = []
    
    // Recording Control Buttons
    private let pauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let restartButton = UIButton(type: .system)
    private var controlButtons: [UIButton] = []
    
    // Stack Views for layout
    private let modeStackView = UIStackView()
    private let controlStackView = UIStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎹 DEBUG: KeyboardViewController viewDidLoad() called")
        
        do {
            setupUI()
            print("✅ DEBUG: setupUI() completed")
            
            setupConstraints()
            print("✅ DEBUG: setupConstraints() completed")
            
            showModeSelection()
            print("✅ DEBUG: showModeSelection() completed")
            
            print("🎉 DEBUG: AutoQuill Keyboard loaded successfully!")
        } catch {
            print("❌ DEBUG: Error in viewDidLoad: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("👀 DEBUG: KeyboardViewController viewWillAppear() called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🌟 DEBUG: KeyboardViewController viewDidAppear() called")
        print("📐 DEBUG: View bounds: \(view.bounds)")
        print("📐 DEBUG: View frame: \(view.frame)")
        print("📐 DEBUG: Container bounds: \(containerView.bounds)")
        print("📐 DEBUG: Container frame: \(containerView.frame)")
        print("📐 DEBUG: ModeStackView bounds: \(modeStackView.bounds)")
        print("📐 DEBUG: ModeStackView frame: \(modeStackView.frame)")
        print("📐 DEBUG: ModeStackView alpha: \(modeStackView.alpha)")
        print("📐 DEBUG: ModeStackView isHidden: \(modeStackView.isHidden)")
        print("📐 DEBUG: View backgroundColor: \(String(describing: view.backgroundColor))")
        print("📐 DEBUG: Container backgroundColor: \(String(describing: containerView.backgroundColor))")
        
        // Force layout if needed
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Check if buttons are properly added
        print("📐 DEBUG: ModeStackView subviews count: \(modeStackView.arrangedSubviews.count)")
        for (index, button) in modeStackView.arrangedSubviews.enumerated() {
            print("📐 DEBUG: Button \(index) - frame: \(button.frame), alpha: \(button.alpha), hidden: \(button.isHidden)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("👋 DEBUG: KeyboardViewController viewWillDisappear() called")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        print("🏗️ DEBUG: setupUI() starting...")
        
        view.backgroundColor = UIColor.systemBackground
        print("✅ DEBUG: Background color set")
        
        // Setup container view properly
        containerView.backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        print("✅ DEBUG: Container view configured and added")
        
        // Add stack views to container
        modeStackView.translatesAutoresizingMaskIntoConstraints = false
        controlStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(modeStackView)
        containerView.addSubview(controlStackView)
        print("✅ DEBUG: Stack views added to container")
        
        // Setup title
        titleLabel.text = "AutoQuill Keyboard"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = isDarkMode() ? .white : .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        print("✅ DEBUG: Title label configured")
        
        // Setup mode buttons
        setupModeButtons()
        print("✅ DEBUG: Mode buttons setup completed")
        
        setupControlButtons()
        print("✅ DEBUG: Control buttons setup completed")
        
        // Setup stack views
        setupStackViews()
        print("✅ DEBUG: Stack views setup completed")
        
        print("🎯 DEBUG: setupUI() completed successfully")
    }
    
    private func setupModeButtons() {
        print("🔘 DEBUG: setupModeButtons() starting...")
        
        modeButtons = [handsFreeModeButton, pushToTalkModeButton, assistantModeButton]
        let modes: [RecordingMode] = [.handsFree, .pushToTalk, .assistant]
        print("✅ DEBUG: Mode buttons array and modes array created")
        
        for (index, button) in modeButtons.enumerated() {
            let mode = modes[index]
            print("🔧 DEBUG: Configuring button \(index) for mode: \(mode.title)")
            
            configureButton(button, 
                          title: mode.title, 
                          icon: mode.icon, 
                          color: mode.color)
            
            button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            print("✅ DEBUG: Button \(index) configured successfully")
        }
        
        // Add long press gesture to push-to-talk button
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pushToTalkLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.1
        pushToTalkModeButton.addGestureRecognizer(longPressGesture)
        print("✅ DEBUG: Long press gesture added to push-to-talk button")
        
        print("🎯 DEBUG: setupModeButtons() completed successfully")
    }
    
    private func setupControlButtons() {
        controlButtons = [pauseButton, stopButton, cancelButton, restartButton]
        
        let controlConfig = [
            ("Pause", "pause.fill", UIColor.systemOrange),
            ("Stop", "stop.fill", UIColor.systemRed),
            ("Cancel", "xmark.circle.fill", UIColor.systemGray),
            ("Restart", "arrow.clockwise.circle.fill", UIColor.systemBlue)
        ]
        
        for (index, button) in controlButtons.enumerated() {
            let (title, icon, color) = controlConfig[index]
            configureButton(button, title: title, icon: icon, color: color)
            button.addTarget(self, action: #selector(controlButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
        }
    }
    
    private func configureButton(_ button: UIButton, title: String, icon: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        // Set icon
        if let iconImage = UIImage(systemName: icon) {
            button.setImage(iconImage, for: .normal)
            button.tintColor = .white
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        }
        
        // Style button
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add animation on touch
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupStackViews() {
        // Mode selection stack
        modeStackView.axis = .horizontal
        modeStackView.distribution = .fillEqually
        modeStackView.spacing = 12
        modeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for button in modeButtons {
            modeStackView.addArrangedSubview(button)
        }
        
        // Control buttons stack (2x2 grid)
        controlStackView.axis = .vertical
        controlStackView.distribution = .fillEqually
        controlStackView.spacing = 8
        controlStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = 8
        topRow.addArrangedSubview(pauseButton)
        topRow.addArrangedSubview(stopButton)
        
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fillEqually
        bottomRow.spacing = 8
        bottomRow.addArrangedSubview(cancelButton)
        bottomRow.addArrangedSubview(restartButton)
        
        controlStackView.addArrangedSubview(topRow)
        controlStackView.addArrangedSubview(bottomRow)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // Mode stack
            modeStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            modeStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            modeStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            modeStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            // Control stack
            controlStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controlStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controlStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            controlStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - UI State Management
    private func showModeSelection() {
        print("🎭 DEBUG: showModeSelection() called")
        print("📊 DEBUG: Current state before: \(currentState)")
        
        currentState = .modeSelection
        titleLabel.text = "Choose Recording Mode"
        print("✅ DEBUG: State set to modeSelection, title updated")
        
        print("📐 DEBUG: Before animation - modeStackView.alpha: \(modeStackView.alpha), controlStackView.alpha: \(controlStackView.alpha)")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.modeStackView.alpha = 1.0
            self.modeStackView.transform = .identity
            self.controlStackView.alpha = 0.0
            self.controlStackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            print("🎬 DEBUG: Animation block executing")
        }) { _ in
            self.controlStackView.isHidden = true
            self.modeStackView.isHidden = false
            print("✅ DEBUG: Animation completed - modeStackView visible, controlStackView hidden")
            print("📐 DEBUG: Final state - modeStackView.alpha: \(self.modeStackView.alpha), modeStackView.isHidden: \(self.modeStackView.isHidden)")
        }
    }
    
    private func showRecordingControls(for mode: RecordingMode) {
        print("🎮 DEBUG: showRecordingControls() called for mode: \(mode.title)")
        print("📊 DEBUG: Current state before: \(currentState)")
        
        currentState = .recording
        selectedMode = mode
        titleLabel.text = "\(mode.title) Mode"
        print("✅ DEBUG: State set to recording, mode selected: \(mode.title)")
        
        modeStackView.isHidden = true
        controlStackView.isHidden = false
        print("✅ DEBUG: Stack view visibility toggled")
        
        UIView.animate(withDuration: 0.3, animations: {
            self.controlStackView.alpha = 1.0
            self.controlStackView.transform = .identity
            self.modeStackView.alpha = 0.0
            self.modeStackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            print("🎬 DEBUG: Recording controls animation block executing")
        })
    }
    
    // MARK: - Actions
    @objc private func modeButtonTapped(_ sender: UIButton) {
        let modes: [RecordingMode] = [.handsFree, .pushToTalk, .assistant]
        let selectedMode = modes[sender.tag]
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        showRecordingControls(for: selectedMode)
    }
    
    @objc private func controlButtonTapped(_ sender: UIButton) {
        let buttonNames = ["Pause", "Stop", "Cancel", "Restart"]
        let buttonName = buttonNames[sender.tag]
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // For now, just print the action (we'll implement backend logic later)
        print("🎯 \(buttonName) button tapped!")
        
        // If cancel or stop, go back to mode selection
        if sender.tag == 1 || sender.tag == 2 { // Stop or Cancel
            showModeSelection()
        }
    }
    
    // MARK: - Button Animations
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    // MARK: - Utilities
    private func isDarkMode() -> Bool {
        if let proxy = textDocumentProxy as? UITextDocumentProxy {
            return proxy.keyboardAppearance == .dark
        }
        return false
    }
    
    // MARK: - Required Overrides
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents
        // Update theme based on keyboard appearance
        let isDark = isDarkMode()
        view.backgroundColor = isDark ? UIColor.black : UIColor.white
        titleLabel.textColor = isDark ? .white : .black
    }
    
    @objc private func pushToTalkLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Hide other buttons and change color to red
            UIView.animate(withDuration: 0.2) {
                self.handsFreeModeButton.alpha = 0.0
                self.assistantModeButton.alpha = 0.0
                self.pushToTalkModeButton.backgroundColor = UIColor.systemRed
            }
            
            // Provide haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            print("🎙️ Push-to-talk recording started")
            
        case .ended, .cancelled:
            // Show other buttons and restore original color
            UIView.animate(withDuration: 0.2) {
                self.handsFreeModeButton.alpha = 1.0
                self.assistantModeButton.alpha = 1.0
                self.pushToTalkModeButton.backgroundColor = UIColor.systemBlue
            }
            
            print("🎙️ Push-to-talk recording ended")
            
        default:
            break
        }
    }
}
