import Cocoa
import AVFoundation
import ScreenCaptureKit

@available(macOS 11.0, *)
public class PermissionService {
    
    // MARK: - Test Mode (for debugging permission flows)
    private static let testMode = false // Set to true to test different permission states
    private static let testPermissions: [String: PermissionStatus] = [
        "microphone": .authorized,
        "accessibility": .notDetermined,
        "screenRecording": .notDetermined
    ]
    
    public enum PermissionType: String, CaseIterable {
        case microphone
        case screenRecording
        case accessibility
    }
    
    public enum PermissionStatus: String {
        case notDetermined
        case authorized
        case denied
        case restricted
    }
    
    // MARK: - Permission Checking
    
    public static func checkPermission(for type: PermissionType) -> PermissionStatus {
        // Test mode override for debugging
        if testMode {
            let status = testPermissions[type.rawValue] ?? .notDetermined
            #if DEBUG
            print("PermissionService: TEST MODE - \(type.rawValue) permission: \(status)")
            #endif
            return status
        }
        
        switch type {
        case .microphone:
            return checkMicrophonePermission()
        case .screenRecording:
            return checkScreenRecordingPermission()
        case .accessibility:
            return checkAccessibilityPermission()
        }
    }
    
    // MARK: - Permission Requesting
    
    public static func requestPermission(for type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        switch type {
        case .microphone:
            requestMicrophonePermission(completion: completion)
        case .screenRecording:
            requestScreenRecordingPermission(completion: completion)
        case .accessibility:
            requestAccessibilityPermission(completion: completion)
        }
    }
    
    // MARK: - Open System Preferences
    
    public static func openSystemPreferences(for type: PermissionType) {
        switch type {
        case .microphone:
            openMicrophonePreferences()
        case .screenRecording:
            openScreenRecordingPreferences()
        case .accessibility:
            openAccessibilityPreferences()
        }
    }
    
    // MARK: - Microphone Permission
    
    private static func checkMicrophonePermission() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    private static func requestMicrophonePermission(completion: @escaping (PermissionStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                completion(granted ? .authorized : .denied)
            }
        }
    }
    
    private static func openMicrophonePreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Screen Recording Permission
    
    private static func checkScreenRecordingPermission() -> PermissionStatus {
        if #available(macOS 11.0, *) {
            // Primary check using preflight
            let canAccess = CGPreflightScreenCaptureAccess()
            
            #if DEBUG
            print("PermissionService: Screen recording preflight check result: \(canAccess)")
            #endif
            
            if canAccess {
                return .authorized
            }
            
            // Secondary check: try to get display information
            // This is a more thorough test that should catch permission issues
            let displayID = CGMainDisplayID()
            let displayBounds = CGDisplayBounds(displayID)
            
            #if DEBUG
            print("PermissionService: Display bounds check - width: \(displayBounds.width), height: \(displayBounds.height)")
            #endif
            
            // If we can get meaningful display bounds, we likely have permission
            if displayBounds.width > 0 && displayBounds.height > 0 {
                // Final preflight check to be sure
                let finalCheck = CGPreflightScreenCaptureAccess()
                #if DEBUG
                print("PermissionService: Final preflight check: \(finalCheck)")
                #endif
                return finalCheck ? .authorized : .notDetermined
            }
            
            return .notDetermined
        } else {
            // For older macOS versions, assume permission is granted
            return .authorized
        }
    }
    
    private static func requestScreenRecordingPermission(completion: @escaping (PermissionStatus) -> Void) {
        if #available(macOS 11.0, *) {
            // Check if we already have permission
            if CGPreflightScreenCaptureAccess() {
                completion(.authorized)
                return
            }
            
            // Request permission
            let granted = CGRequestScreenCaptureAccess()
            
            // Give the system time to process the permission
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let hasPermission = CGPreflightScreenCaptureAccess()
                completion(hasPermission ? .authorized : .denied)
            }
        } else {
            completion(.authorized)
        }
    }
    
    private static func openScreenRecordingPreferences() {
        if #available(macOS 13.0, *) {
            // Use the new System Settings URL for macOS 13+
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
            NSWorkspace.shared.open(url)
        } else {
            // Use the old System Preferences URL for older macOS versions
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - Accessibility Permission
    
    private static func checkAccessibilityPermission() -> PermissionStatus {
        // More robust accessibility permission checking
        let trusted = AXIsProcessTrusted()
        
        #if DEBUG
        print("PermissionService: Accessibility permission check - AXIsProcessTrusted: \(trusted)")
        #endif
        
        if trusted {
            return .authorized
        }
        
        // Double-check with a different method
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false] as CFDictionary
        let trustedWithOptions = AXIsProcessTrustedWithOptions(options)
        
        #if DEBUG
        print("PermissionService: Accessibility permission check - AXIsProcessTrustedWithOptions: \(trustedWithOptions)")
        #endif
        
        return trustedWithOptions ? .authorized : .notDetermined
    }
    
    private static func requestAccessibilityPermission(completion: @escaping (PermissionStatus) -> Void) {
        // Check if we already have permission
        if AXIsProcessTrusted() {
            completion(.authorized)
            return
        }
        
        // For accessibility permissions, directly open System Preferences
        // instead of showing the system prompt which can be confusing
        openAccessibilityPreferences()
        
        // Return current status (not determined) since user needs to manually grant in System Preferences
        completion(.notDetermined)
    }
    
    private static func openAccessibilityPreferences() {
        if #available(macOS 13.0, *) {
            // Use the new System Settings URL for macOS 13+
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        } else {
            // Use the old System Preferences URL for older macOS versions
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }
} 