import Foundation
import AVFoundation

/// Manages audio recording for the AutoQuill keyboard extension.
/// This class encapsulates the `AVAudioRecorder` setup and control logic
/// so that the `KeyboardViewController` remains focused on UI concerns.
final class RecordingManager: NSObject {
    /// Shared audio session for recording.
    private let audioSession = AVAudioSession.sharedInstance()

    /// Underlying audio recorder instance.
    private var recorder: AVAudioRecorder?

    /// URL of the current recording file.
    private var recordingURL: URL?

    /// App group identifier used for storing recordings.
    private let appGroupID = "group.com.divyansh-lalwani.autoquill-ai.shared"

    /// Directory where recordings are stored (``AutoQuill`` folder).
    private lazy var recordingsDirectory: URL? = {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        let dir = container.appendingPathComponent("AutoQuill")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
        return dir
    }()

    /// Starts a new recording session.
    func startRecording() throws {
        try configureSession()

        guard let recordingsDirectory, let fileURL = generateRecordingURL(in: recordingsDirectory) else {
            throw RecordingError.unableToCreateFile
        }
        recordingURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        guard recorder?.record() == true else {
            throw RecordingError.unableToStart
        }
    }

    /// Pauses the current recording if possible.
    func pauseRecording() {
        recorder?.pause()
    }

    /// Stops recording and finalises the audio file.
    func stopRecording() {
        recorder?.stop()
    }

    /// Cancels the recording and discards the audio file.
    func cancelRecording() {
        recorder?.stop()
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    /// Restarts the recording by cancelling the current session and starting a new one.
    func restartRecording() throws {
        cancelRecording()
        try startRecording()
    }

    /// Configures the AVAudioSession for recording.
    private func configureSession() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    /// Generates a unique file URL for the recording.
    private func generateRecordingURL(in directory: URL) -> URL? {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: Date())
        return directory.appendingPathComponent("Recording_\(dateString).m4a")
    }

    enum RecordingError: Error {
        case unableToCreateFile
        case unableToStart
    }
}

extension RecordingManager: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Recording error: \(error?.localizedDescription ?? "unknown")")
    }
}

