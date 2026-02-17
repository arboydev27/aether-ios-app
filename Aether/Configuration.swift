//
//  Configuration.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

struct Configuration {
    static let apiKey: String = {
        // Try to find .env in the bundle
        if let url = Bundle.main.url(forResource: ".env", withExtension: nil) {
            if let string = try? String(contentsOf: url, encoding: .utf8) {
                return parseEnv(string)
            }
        }
        
        // Fallback: Try to find .env relative to the source file (useful for Simulator/Preview)
        // Configuration.swift is at <ProjectRoot>/Aether/Configuration.swift
        // deletingLastPathComponent() -> <ProjectRoot>/Aether/
        // deletingLastPathComponent() -> <ProjectRoot>/
        let sourceURL = URL(fileURLWithPath: #file)
        let rootURL = sourceURL.deletingLastPathComponent().deletingLastPathComponent()
        let envPath = rootURL.appendingPathComponent(".env").path
        
        if let string = try? String(contentsOfFile: envPath, encoding: .utf8) {
            return parseEnv(string)
        }
        
        print("DEBUG: .env file not found at \(envPath)")
        return ""
    }()
    
    private static func parseEnv(_ content: String) -> String {
        let lines = content.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                if key == "API_NINJAS_KEY" {
                    return value
                }
            }
        }
        return ""
    }
}
