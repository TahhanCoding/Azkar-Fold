import Foundation

class SunnahAzkarService {

    enum AzkarLoadingError: Error {
        case fileNotFound
        case dataCorrupted
        case parsingFailed(Error)
        case unknownError
    }

    func loadAzkar(for category: SunnahAzkarCategory) -> Result<[SunnahZekrItem], AzkarLoadingError> {
        // First, try to get the file from the main bundle using proper resource loading
        guard let url = Bundle.main.url(forResource: category.fileNameWithoutExtension,
                                       withExtension: category.fileExtension,
                                       subdirectory: "Resources") else {
            
            // Alternative approach: try without subdirectory
            guard let fallbackUrl = Bundle.main.url(forResource: category.fileNameWithoutExtension,
                                                   withExtension: category.fileExtension) else {
                
                // Debug information
                printBundleDebugInfo(for: category)
                return .failure(.fileNotFound)
            }
            
            return loadAzkarFromURL(fallbackUrl)
        }
        
        return loadAzkarFromURL(url)
    }
    
    private func loadAzkarFromURL(_ url: URL) -> Result<[SunnahZekrItem], AzkarLoadingError> {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Try decoding as array first (based on your success case)
            if let azkar = try? decoder.decode([SunnahZekrItem].self, from: data) {
                return .success(azkar)
            }
            
            // Fallback: try decoding as SunnahAzkar wrapper
            let azkarWrapper = try decoder.decode(SunnahAzkar.self, from: data)
            return .success(azkarWrapper.content)
            
        } catch let error as DecodingError {
            print("JSON Decoding Error: \(error)")
            return .failure(.parsingFailed(error))
        } catch {
            print("Data Loading Error: \(error)")
            return .failure(.unknownError)
        }
    }
    
    private func printBundleDebugInfo(for category: SunnahAzkarCategory) {
        print("=== Bundle Debug Info ===")
        print("Bundle path: \(Bundle.main.bundlePath)")
        print("Looking for file: \(category.fileName)")
        
        // List all files in the bundle
        if let bundleContents = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath) {
            print("Bundle root contents: \(bundleContents)")
        }
        
        // Check if Resources directory exists in bundle
        let resourcesPath = Bundle.main.bundlePath + "/Resources"
        if FileManager.default.fileExists(atPath: resourcesPath) {
            if let resourceContents = try? FileManager.default.contentsOfDirectory(atPath: resourcesPath) {
                print("Resources directory contents: \(resourceContents)")
            }
        } else {
            print("Resources directory does not exist in bundle")
        }
        
        // Try different resource loading approaches
        print("Resource loading attempts:")
        print("• With subdirectory: \(Bundle.main.url(forResource: category.fileNameWithoutExtension, withExtension: category.fileExtension, subdirectory: "Resources") != nil)")
        print("• Without subdirectory: \(Bundle.main.url(forResource: category.fileNameWithoutExtension, withExtension: category.fileExtension) != nil)")
        print("• Path-based lookup: \(Bundle.main.path(forResource: category.fileName, ofType: nil) != nil)")
    }
}

// Extension to help with file name handling
extension SunnahAzkarCategory {
    var fileNameWithoutExtension: String {
        return (fileName as NSString).deletingPathExtension
    }
    
    var fileExtension: String {
        return (fileName as NSString).pathExtension
    }
}
