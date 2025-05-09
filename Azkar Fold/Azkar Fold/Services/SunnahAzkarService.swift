import Foundation

class SunnahAzkarService {

    enum AzkarLoadingError: Error {
        case fileNotFound
        case dataCorrupted
        case parsingFailed(Error)
        case unknownError
    }

    func loadAzkar(for category: SunnahAzkarCategory) -> Result<[SunnahZekrItem], AzkarLoadingError> {
        guard let bundlePath = Bundle.main.path(forResource: category.fileName, ofType: nil, inDirectory: "Resources") else {
            // Fallback for cases where app is not running from main bundle (e.g. previews, tests)
            // This assumes the JSON files are in a 'Resources' subdirectory relative to this Swift file's directory during development.
            // Adjust the relative path as necessary if your project structure is different.
            let fileManager = FileManager.default
            let currentFilePath = #file // Path to this SunnahAzkarService.swift file
            // Navigate up to the project root or appropriate base directory to find Resources
            // This example assumes Resources is at 'Azkar Fold/Azkar Fold/Resources/' relative to project root
            // And 'Services' is at 'Azkar Fold/Azkar Fold/Services/'
            // So, from 'Services', go up one level to 'Azkar Fold/Azkar Fold/', then into 'Resources/'
            let projectRootPath = URL(fileURLWithPath: currentFilePath)
                .deletingLastPathComponent() // Remove 'SunnahAzkarService.swift'
                .deletingLastPathComponent() // Remove 'Services'
            let resourcePath = projectRootPath.appendingPathComponent("Resources").appendingPathComponent(category.fileName).path

            if !fileManager.fileExists(atPath: resourcePath) {
                 print("JSON Loading Debug - File check:\n• Bundle path: \(Bundle.main.bundlePath)\n• Resource path attempted: \(resourcePath)\n• File exists in bundle: \(Bundle.main.path(forResource: category.fileName, ofType: nil) != nil ? "Yes" : "No")\n• Development path exists: \(FileManager.default.fileExists(atPath: resourcePath) ? "Yes" : "No"))")
                return .failure(.fileNotFound)
            }
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
                let decoder = JSONDecoder()
                let azkar = try decoder.decode(SunnahAzkar.self, from: data)
                return .success(azkar.content)
            } catch let error as DecodingError {
                print("Decoding Error Details:\n\(String(describing: error))")
                return .failure(.parsingFailed(error))
            } catch {
                print("Data Loading Error:\n\(String(describing: error))\nPath: \(resourcePath)\nFile exists: \(FileManager.default.fileExists(atPath: resourcePath) ? "Yes" : "No"))")
                return .failure(.unknownError)
            }
        }

        do {
            let url = URL(fileURLWithPath: bundlePath)
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let azkar = try decoder.decode([SunnahZekrItem].self, from: data)
            return .success(azkar)
        } catch let error as DecodingError {
            print("Error decoding JSON from bundle: \(error)")
            return .failure(.parsingFailed(error))
        } catch {
            print("Error loading data from bundle: \(error)")
            return .failure(.unknownError)
        }
    }
}
