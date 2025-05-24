import Cocoa
import AVFoundation
import ScreenCaptureKit

@available(macOS 11.0, *)
public class PermissionService {
    
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
            let hasPermission = CGPreflightScreenCaptureAccess()
            return hasPermission ? .authorized : .notDetermined
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
            
            // Request permission by attempting to capture
            CGRequestScreenCaptureAccess()
            
            // Check the result after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let hasPermission = CGPreflightScreenCaptureAccess()
                completion(hasPermission ? .authorized : .denied)
            }
        } else {
            completion(.authorized)
        }
    }
    
    private static func openScreenRecordingPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Accessibility Permission
    
    private static func checkAccessibilityPermission() -> PermissionStatus {
        let trusted = AXIsProcessTrusted()
        return trusted ? .authorized : .notDetermined
    }
    
    private static func requestAccessibilityPermission(completion: @escaping (PermissionStatus) -> Void) {
        // Check if we already have permission
        if AXIsProcessTrusted() {
            completion(.authorized)
            return
        }
        
        // Request permission
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        // The system will show a dialog, so we'll check again after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let newTrusted = AXIsProcessTrusted()
            completion(newTrusted ? .authorized : .denied)
        }
    }
    
    private static func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
} 