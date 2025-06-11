import Foundation
import FlutterMacOS
import WhisperKit

/// Service for managing WhisperKit operations
class WhisperKitService: NSObject {
    private var whisperKit: WhisperKit?
    private let modelStorage = "huggingface/models/argmaxinc/whisperkit-coreml"
    private let repoName = "argmaxinc/whisperkit-coreml"
    private var downloadProgressStreams: [String: (Double) -> Void] = [:]
    private var loadedModelName: String?
    private var isInitialized = false
    
    override init() {
        super.init()
        setupModelDirectory()
    }
    
    // MARK: - Model Directory Setup
    
    private func setupModelDirectory() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return
        }
        
        let modelPath = documentsPath.appendingPathComponent(modelStorage)
        
        if !FileManager.default.fileExists(atPath: modelPath.path) {
            do {
                try FileManager.default.createDirectory(at: modelPath, withIntermediateDirectories: true)
                print("Created model directory at: \(modelPath.path)")
            } catch {
                print("Error creating model directory: \(error)")
            }
        }
    }
    
    // MARK: - Model Management
    
    /// Downloads a WhisperKit model
    func downloadModel(_ modelName: String, progressCallback: @escaping (Double) -> Void) async throws {
        print("Starting download for model: \(modelName)")
        
        // Store progress callback
        downloadProgressStreams[modelName] = progressCallback
        
        do {
            let modelFolder = try await WhisperKit.download(
                variant: "openai_whisper-\(modelName)",
                from: repoName,
                progressCallback: { progress in
                    DispatchQueue.main.async {
                        progressCallback(progress.fractionCompleted)
                    }
                }
            )
            
            print("Model \(modelName) downloaded to: \(modelFolder.path)")
            
            // Final progress update
            progressCallback(1.0)
            
            // Remove progress callback
            downloadProgressStreams.removeValue(forKey: modelName)
            
        } catch {
            print("Error downloading model \(modelName): \(error)")
            downloadProgressStreams.removeValue(forKey: modelName)
            throw error
        }
    }
    
    /// Gets the list of downloaded models
    func getDownloadedModels() -> [String] {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        let modelPath = documentsPath.appendingPathComponent(modelStorage)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: modelPath, includingPropertiesForKeys: nil)
            
            // Filter and format model names
            let modelNames = contents.compactMap { url -> String? in
                let folderName = url.lastPathComponent
                if folderName.hasPrefix("openai_whisper-") {
                    return String(folderName.dropFirst("openai_whisper-".count))
                }
                return nil
            }
            
            print("Found downloaded models: \(modelNames)")
            return modelNames
            
        } catch {
            print("Error getting downloaded models: \(error)")
            return []
        }
    }
    
    /// Checks if a specific model is downloaded
    func isModelDownloaded(_ modelName: String) -> Bool {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let modelPath = documentsPath.appendingPathComponent(modelStorage).appendingPathComponent("openai_whisper-\(modelName)")
        return FileManager.default.fileExists(atPath: modelPath.path)
    }
    
    /// Deletes a downloaded model
    func deleteModel(_ modelName: String) -> Bool {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let modelPath = documentsPath.appendingPathComponent(modelStorage).appendingPathComponent("openai_whisper-\(modelName)")
        
        do {
            if FileManager.default.fileExists(atPath: modelPath.path) {
                try FileManager.default.removeItem(at: modelPath)
                print("Successfully deleted model: \(modelName)")
                return true
            }
            return false
        } catch {
            print("Error deleting model \(modelName): \(error)")
            return false
        }
    }
    
    /// Gets the storage size of a downloaded model
    func getModelSize(_ modelName: String) -> String {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "Unknown"
        }
        
        let modelPath = documentsPath.appendingPathComponent(modelStorage).appendingPathComponent("openai_whisper-\(modelName)")
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: modelPath.path)
            if let size = attributes[.size] as? Int64 {
                return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            }
        } catch {
            print("Error getting model size for \(modelName): \(error)")
        }
        
        return "Unknown"
    }
    
    /// Gets the path to the models directory
    func getModelsDirectory() -> String? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return documentsPath.appendingPathComponent(modelStorage).path
    }
    
    /// Opens the models directory in Finder
    func openModelsDirectory() -> Bool {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let modelPath = documentsPath.appendingPathComponent(modelStorage)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: modelPath.path) {
            do {
                try FileManager.default.createDirectory(at: modelPath, withIntermediateDirectories: true)
            } catch {
                print("Error creating models directory: \(error)")
                return false
            }
        }
        
        // Open the directory in Finder
        NSWorkspace.shared.open(modelPath)
        return true
    }
    
    /// Preloads a WhisperKit model for faster subsequent transcriptions
    func preloadModel(_ modelName: String) async throws {
        print("Preloading WhisperKit model: \(modelName)")
        
        // Check if the model exists
        if !isModelDownloaded(modelName) {
            throw NSError(domain: "WhisperKitService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Model \(modelName) is not downloaded"
            ])
        }
        
        // If this model is already loaded, no need to reload
        if loadedModelName == modelName && isInitialized {
            print("Model \(modelName) is already preloaded")
            return
        }
        
        // Initialize WhisperKit
        let config = WhisperKitConfig(
            verbose: true,
            logLevel: .debug,
            prewarm: false,
            load: false,
            download: false
        )
        
        whisperKit = try await WhisperKit(config)
        
        // Set the model folder to the specific downloaded model
        let modelVariant = "openai_whisper-\(modelName)"
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "WhisperKitService", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Could not access documents directory"
            ])
        }
        
        let modelFolderPath = documentsPath.appendingPathComponent(modelStorage).appendingPathComponent(modelVariant)
        whisperKit!.modelFolder = modelFolderPath
        
        // Load the models
        try await whisperKit!.prewarmModels()
        try await whisperKit!.loadModels()
        
        loadedModelName = modelName
        isInitialized = true
        
        print("WhisperKit model preloaded successfully: \(modelVariant)")
    }
    
    /// Transcribes audio using a local WhisperKit model
    func transcribeAudio(audioPath: String, modelName: String) async throws -> String {
        print("Starting local transcription with model: \(modelName)")
        
        // Check if the model exists
        if !isModelDownloaded(modelName) {
            throw NSError(domain: "WhisperKitService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Model \(modelName) is not downloaded"
            ])
        }
        
        // Check if we need to load a different model
        if loadedModelName != modelName || !isInitialized {
            print("Loading model \(modelName) (currently loaded: \(loadedModelName ?? "none"))")
            try await preloadModel(modelName)
        }
        
        // Transcribe the audio file
        guard FileManager.default.fileExists(atPath: audioPath) else {
            throw NSError(domain: "WhisperKitService", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Audio file not found at path: \(audioPath)"
            ])
        }
        
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitService", code: 4, userInfo: [
                NSLocalizedDescriptionKey: "WhisperKit not initialized"
            ])
        }
        
        let results = try await whisperKit.transcribe(audioPath: audioPath)
        
        // Extract the transcribed text from the results array
        let transcribedText = results.map { $0.text }.joined(separator: " ")
        
        print("Local transcription completed: \(transcribedText)")
        
        return transcribedText
    }
    
    /// Initializes WhisperKit
    func initialize() async throws {
        print("Initializing WhisperKit service...")
        
        // Initialize WhisperKit without loading any models
        let config = WhisperKitConfig(
            verbose: true,
            logLevel: .debug,
            prewarm: false,
            load: false,
            download: false
        )
        
        whisperKit = try await WhisperKit(config)
        print("WhisperKit service initialized successfully")
    }
} 