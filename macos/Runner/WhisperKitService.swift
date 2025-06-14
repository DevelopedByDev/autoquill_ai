import Foundation
import FlutterMacOS
import WhisperKit

/// Service for managing WhisperKit operations
class WhisperKitService: NSObject {
    private var whisperKit: WhisperKit?
    private let modelStorage = "huggingface/models/argmaxinc/whisperkit-coreml"
    private let repoName = "argmaxinc/whisperkit-coreml"
    
    // Alternative public repository if the main one fails
    private let fallbackRepoName = "openai/whisper"
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
        print("Model variant will be: openai_whisper-\(modelName)")
        print("Repository: \(repoName)")
        
        // Check if Hugging Face token is available in environment
        if let hfToken = ProcessInfo.processInfo.environment["HUGGING_FACE_HUB_TOKEN"] {
            print("Found Hugging Face token in environment")
        } else {
            print("No Hugging Face token found - download might fail if repository requires authentication")
        }
        
        // Store progress callback
        downloadProgressStreams[modelName] = progressCallback
        
        // Send initial progress update
        progressCallback(0.0)
        
        do {
            let modelFolder = try await WhisperKit.download(
                variant: "openai_whisper-\(modelName)",
                from: repoName,
                progressCallback: { progress in
                    print("Download progress for \(modelName): \(progress.fractionCompleted)")
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
            print("Error type: \(type(of: error))")
            
            // Check if this is an authorization error
            if error.localizedDescription.contains("authorizationRequired") {
                print("Authorization required for model download. This might be due to:")
                print("1. The repository requiring authentication")
                print("2. Rate limiting from Hugging Face")
                print("3. Network connectivity issues")
                print("Please ensure you have a stable internet connection and try again later.")
                
                // Create a more user-friendly error message
                let authError = NSError(domain: "WhisperKitService", code: 403, userInfo: [
                    NSLocalizedDescriptionKey: "Model download requires authorization. The Hugging Face repository may require authentication or is experiencing rate limiting. Please try again later or check your internet connection."
                ])
                downloadProgressStreams.removeValue(forKey: modelName)
                throw authError
            } else {
                downloadProgressStreams.removeValue(forKey: modelName)
                throw error
            }
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
        
        // Check if the directory exists
        guard FileManager.default.fileExists(atPath: modelPath.path) else {
            return false
        }
        
        // Check if the model has essential files indicating a complete download
        // List the contents of the model directory to see what files are actually there
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: modelPath, includingPropertiesForKeys: [.fileSizeKey])
            print("Model \(modelName) directory contents: \(contents.map { $0.lastPathComponent })")
            
            // Look for .mlmodelc directories/files (the actual Core ML models)
            let mlModelFiles = contents.filter { $0.pathExtension == "mlmodelc" || $0.lastPathComponent.contains(".mlmodelc") }
            
            // Also look for essential config files
            let configFiles = contents.filter { 
                $0.lastPathComponent.contains("config") || 
                $0.lastPathComponent.contains("generation") ||
                $0.lastPathComponent.contains("tokenizer") ||
                $0.pathExtension == "json"
            }
            
            print("Model \(modelName) ML model files: \(mlModelFiles.map { $0.lastPathComponent })")
            print("Model \(modelName) config files: \(configFiles.map { $0.lastPathComponent })")
            
            // Check if we have at least some ML model files (indicating the download completed)
            if mlModelFiles.count >= 1 {  // At least one ML model file
                print("Model \(modelName) appears to be fully downloaded (\(mlModelFiles.count) ML model files)")
                return true
            } else if contents.count >= 2 {  // Fallback: if there are multiple files, assume it's downloaded
                print("Model \(modelName) has \(contents.count) files, assuming download is complete")
                return true
            } else {
                print("Model \(modelName) appears incomplete: only \(mlModelFiles.count) ML model files found, \(contents.count) total files")
                return false
            }
            
        } catch {
            print("Error checking model \(modelName) contents: \(error)")
            // Fallback to simple directory existence check
            return FileManager.default.fileExists(atPath: modelPath.path)
        }
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
            print("Model \(modelName) is not downloaded - checking folder...")
            throw NSError(domain: "WhisperKitService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Model \(modelName) is not downloaded"
            ])
        }
        
        // If this model is already loaded, no need to reload
        if loadedModelName == modelName && isInitialized {
            print("Model \(modelName) is already preloaded")
            return
        }
        
        // If a different model is currently loaded, it will be replaced
        if let currentModel = loadedModelName, currentModel != modelName {
            print("Unloading currently loaded model '\(currentModel)' to load '\(modelName)' (WhisperKit supports only one model at a time)")
        }
        
        do {
            // Initialize WhisperKit
            print("Creating WhisperKit instance...")
            let config = WhisperKitConfig(
                verbose: true,
                logLevel: .debug,
                prewarm: false,
                load: false,
                download: false
            )
            
            whisperKit = try await WhisperKit(config)
            print("WhisperKit instance created successfully")
            
            // Set the model folder to the specific downloaded model
            let modelVariant = "openai_whisper-\(modelName)"
            guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw NSError(domain: "WhisperKitService", code: 3, userInfo: [
                    NSLocalizedDescriptionKey: "Could not access documents directory"
                ])
            }
            
            let modelFolderPath = documentsPath.appendingPathComponent(modelStorage).appendingPathComponent(modelVariant)
            
            // Verify the model folder exists
            guard FileManager.default.fileExists(atPath: modelFolderPath.path) else {
                print("Model folder does not exist at: \(modelFolderPath.path)")
                throw NSError(domain: "WhisperKitService", code: 5, userInfo: [
                    NSLocalizedDescriptionKey: "Model folder not found at path: \(modelFolderPath.path)"
                ])
            }
            
            print("Setting model folder to: \(modelFolderPath.path)")
            whisperKit!.modelFolder = modelFolderPath
            
            // Load the models
            print("Prewarming models...")
            try await whisperKit!.prewarmModels()
            print("Models prewarmed successfully")
            
            print("Loading models...")
            try await whisperKit!.loadModels()
            print("Models loaded successfully")
            
            loadedModelName = modelName
            isInitialized = true
            
            print("WhisperKit model preloaded successfully: \(modelVariant) (this is now the only loaded model)")
            
        } catch {
            print("Error during model preloading: \(error)")
            print("Error type: \(type(of: error))")
            if let nsError = error as NSError? {
                print("Error domain: \(nsError.domain), code: \(nsError.code)")
                print("Error description: \(nsError.localizedDescription)")
                print("Error userInfo: \(nsError.userInfo)")
            }
            throw error
        }
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
    
    /// Initializes a model by running test inference on the sample audio file
    func initializeWithTestAudio(_ modelName: String) async throws -> Bool {
        print("Initializing model \(modelName) with test audio...")
        
        // First preload the model
        do {
            try await preloadModel(modelName)
            print("Model \(modelName) preloaded successfully")
        } catch {
            print("Failed to preload model \(modelName): \(error)")
            throw error
        }
        
        // Try multiple paths to find the test audio file
        let possiblePaths = [
            Bundle.main.path(forResource: "test", ofType: "wav", inDirectory: "Frameworks/App.framework/flutter_assets/assets/sample_recording"),
            Bundle.main.path(forResource: "test", ofType: "wav", inDirectory: "flutter_assets/assets/sample_recording"),
            Bundle.main.path(forResource: "test", ofType: "wav"),
            Bundle.main.path(forResource: "sample_recording/test", ofType: "wav")
        ]
        
        for possiblePath in possiblePaths {
            if let testAudioPath = possiblePath, FileManager.default.fileExists(atPath: testAudioPath) {
                print("Found test.wav at: \(testAudioPath)")
                return try await runTestInference(audioPath: testAudioPath, modelName: modelName)
            }
        }
        
        print("Could not find test.wav in any expected location")
        print("Available bundle resources: \(Bundle.main.paths(forResourcesOfType: "wav", inDirectory: nil))")
        
        // Skip test audio initialization if we can't find the file
        print("Skipping test audio initialization for \(modelName) - marking as initialized")
        return true
    }
    
    /// Runs test inference on the provided audio path
    private func runTestInference(audioPath: String, modelName: String) async throws -> Bool {
        do {
            let result = try await transcribeAudio(audioPath: audioPath, modelName: modelName)
            print("Test inference completed successfully for \(modelName): \(result)")
            
            // Mark this model as initialized if transcription succeeds
            if loadedModelName == modelName {
                isInitialized = true
            }
            
            return true
        } catch {
            print("Test inference failed for \(modelName): \(error)")
            return false
        }
    }
    
    /// Checks if a model is currently initialized and ready for use
    func isModelInitialized(_ modelName: String) -> Bool {
        return loadedModelName == modelName && isInitialized
    }
} 