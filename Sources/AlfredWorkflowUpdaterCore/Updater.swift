import Foundation
import SwiftSoup


public struct ReleaseInfo: Codable {
    
    public let version: String
    public let file: String
    public let page: String
    
}


public struct Updater {
    
    public static func main() -> Int32 {
        let gitHubRepository = CommandLine.arguments[1]
        let checkFrequency = CommandLine.arguments[2]
        
        switch ProcessInfo.processInfo.environment["AlfredWorkflowUpdater_action"] {
        case "open":
            guard let info = infoFromCache() else { return 2 }
            
            open(page: info.page)
        case "update":
            guard let info = infoFromCache() else { return 2 }
            
            update(with: info.file)
            deleteInfoCacheFile()
        default:
            if enoughTimeHasElapsed(frequencyBeing: Int(checkFrequency) ?? 1440) {
                if let release = checkOnline(for: gitHubRepository) {
                    createInfoCacheFile(for: release)
                }
                
                updateLastCheckedCacheFile()
            }
        }
        
        return 0
    }
       
}


extension Updater {
    
    static func infoFromCache() -> ReleaseInfo? {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return nil }
        
        let updateFile = URL(fileURLWithPath: "\(alfredWorkflowCache)/update_available.plist")
        guard let updateData = try? Data(contentsOf: updateFile) else { return nil }
        
        let decoder = PropertyListDecoder()
        guard let info = try? decoder.decode(ReleaseInfo.self, from: updateData) else { return nil }
        
        return info
    }
    
    @discardableResult
    static func open(page: String) -> Bool {
        open(item: page)
    }
        
    @discardableResult
    static func update(with fileURL: String) -> Bool {
        guard let url = URL(string: fileURL) else { return false }

        var updateResult = false
        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.downloadTask(with: url) { location, _, _ in
            if let tmpLocation = location {
                if let finalLocation = moveWorkflowFile(from: tmpLocation, filename: url.lastPathComponent) {
                    updateResult = openWorkflowFile(at: finalLocation.path)
                }
            }

            semaphore.signal()
        }
        .resume()

        semaphore.wait()

        return true && updateResult
    }
        
    static func deleteInfoCacheFile() {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return }
        
        let releaseFile = "\(alfredWorkflowCache)/update_available.plist"
        
        if FileManager.default.fileExists(atPath: releaseFile) {
            guard let _ = try? FileManager.default.removeItem(atPath: releaseFile) else { return }
        }
    }
        
    static func enoughTimeHasElapsed(frequencyBeing minutes: Int) -> Bool {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return true }
        let lastCheckedFile = "\(alfredWorkflowCache)/last_checked.plist"
        
        let lastCheckedFileURL = URL(fileURLWithPath: lastCheckedFile)
        guard let data = try? Data(contentsOf: lastCheckedFileURL) else { return true }
        let decoder = PropertyListDecoder()
        guard let date = try? decoder.decode([Date].self, from: data) else { return true }
        
        guard let thresholdDate = Calendar.current.date(byAdding: .minute, value: minutes, to: date.first ?? Date()) else { return true }
        let now = Date()
        
        return now > thresholdDate ? true : false
    }
    
    static func checkOnline(for gitHubRepository: String) -> ReleaseInfo? {
        let releasePage = "https://github.com/\(gitHubRepository)/releases/latest"
        
        guard let url = URL(string: releasePage) else { return nil }
        guard let html = try? String(contentsOf: url) else { return nil }
        guard let document = try? SwiftSoup.parse(html) else { return nil }
        
        guard let releaseVersion = try? document.select(".octicon-tag + span").first()?.text() else { return nil }
        guard currentVersion().compare(releaseVersion, options: .numeric) == .orderedAscending else { return nil }
        
        guard let alfredWorkflowUpdaterAssetName = ProcessInfo.processInfo.environment["alfred_workflow_updater_asset_name"] else { return nil }

        return ReleaseInfo(
            version: releaseVersion,
            file: "https://github.com/\(gitHubRepository)/releases/download/\(releaseVersion)/\(alfredWorkflowUpdaterAssetName)",
            page: releasePage
        )
    }
    
    static func createInfoCacheFile(for release: ReleaseInfo) {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return }
        let updateAvailableFile = "\(alfredWorkflowCache)/update_available.plist"
        
        let encoder = PropertyListEncoder()
        guard let encoded = try? encoder.encode(release) else { return }
        
        FileManager.default.createFile(atPath: updateAvailableFile, contents: encoded)
    }
    
    static func updateLastCheckedCacheFile() {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return }
        let lastCheckedFile = "\(alfredWorkflowCache)/last_checked.plist"
        
        let now = Date()
        let encoder = PropertyListEncoder()
        guard let encoded = try? encoder.encode([now]) else { return }
        
        try? FileManager.default.removeItem(atPath: lastCheckedFile)
        FileManager.default.createFile(atPath: lastCheckedFile, contents: encoded)
    }

}


extension Updater {
        
    private static func currentVersion() -> String {
        let alfredPreferencesFolder = ProcessInfo.processInfo.environment["alfred_preferences"] ?? ""
        let alfredWorkflowUID = ProcessInfo.processInfo.environment["alfred_workflow_uid"] ?? ""

        let url = URL(fileURLWithPath: "\(alfredPreferencesFolder)/workflows/\(alfredWorkflowUID)/info.plist")

        do {
            let workflowData = try Data(contentsOf: url)
            if let info = try PropertyListSerialization.propertyList(from: workflowData, options: [], format: nil) as? [String: Any] {
                if let version = info["version"] as? String {
                    return version
                }
            }

            throw NSError()
        } catch {
            return "6969696969696969"
        }
    }
    
    private static func openWorkflowFile(at path: String) -> Bool {
        open(item: path)
    }
    
    private static func open(item: String) -> Bool {
        let task = Process()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = [item]

        do {
            try task.run()
        } catch {
            return false
        }

        return true
    }

    private static func moveWorkflowFile(from location: URL, filename: String) -> URL? {
        do {
            let documentsURL = try FileManager.default.url(
                for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false
            )
            let savedURL = documentsURL.appendingPathComponent(filename)

            if FileManager.default.fileExists(atPath: savedURL.path) {
                try FileManager.default.removeItem(at: savedURL)
            }

            try FileManager.default.moveItem(at: location, to: savedURL)

            return savedURL
        } catch {
            return nil
        }
    }
    
}
