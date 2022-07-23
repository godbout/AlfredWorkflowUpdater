import Foundation
import SwiftSoup


public struct UpdateInfo: Codable {
    
    public let version: String
    public let file: String
    public let page: String
    
}


public struct Updater {

    public static func localUpdateInfo() -> UpdateInfo? {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return nil }
        
        let updateFile = URL(fileURLWithPath: "\(alfredWorkflowCache)/update_available.plist")
        guard let updateData = try? Data(contentsOf: updateFile) else { return nil }
        
        let decoder = PropertyListDecoder()
        guard let updateInfo = try? decoder.decode(UpdateInfo.self, from: updateData) else { return nil }
        
        return updateInfo
    }
    
    public static func checkUpdateOnline(for gitHubRepository: String) -> UpdateInfo? {
        let releasePage = "https://github.com/\(gitHubRepository)/releases/latest"
        
        guard let url = URL(string: releasePage) else { return nil }
        guard let html = try? String(contentsOf: url) else { return nil }
        guard let document = try? SwiftSoup.parse(html) else { return nil }
        
        guard let releaseVersion = try? document.select(".octicon-tag + span").first()?.text() else { return nil }
        guard currentVersion().compare(releaseVersion, options: .numeric) == .orderedAscending else { return nil }
        
        guard let releaseFile = try? document.select(".octicon-package + a").first()?.attr("href") else { return nil }
        
        return UpdateInfo(
            version: releaseVersion,
            file: "https://github.com\(releaseFile)",
            page: releasePage
        )
    }
    
    public static func open(page: String) -> Bool {
        open(item: page)
    }
    
    public static func update(with fileURL: String) -> Bool {
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
