import Foundation
import SwiftSoup

public final class Updater {
    static let shared = Updater()

    private init() {}

    public static func checkUpdate(for gitHubRepository: String) -> (version: String, file: String, page: String)? {
        let releasePage = "https://github.com/\(gitHubRepository)/releases/latest"

        guard let url = URL(string: releasePage) else { return nil }
        guard let html = try? String(contentsOf: url) else { return nil }
        guard let document = try? SwiftSoup.parse(html) else { return nil }

        guard let releaseVersion = try? document.select(".release-header a").first()?.text() else { return nil }
        guard currentVersion().compare(releaseVersion, options: .numeric) == .orderedAscending else { return nil }

        guard let releaseFile = try? document.select(".Box-body").first()?.child(0).attr("href") else { return nil }

        return (version: releaseVersion, file: "https://github.com\(releaseFile)", page: releasePage)
    }

    private static func currentVersion() -> String {
        let alfredPreferencesFolder = ProcessInfo.processInfo.environment["alfred_preferences"] ?? ""
        let alfredWorkflowUID = ProcessInfo.processInfo.environment["alfred_workflow_uid"] ?? ""

        let url = URL(fileURLWithPath: "\(alfredPreferencesFolder)/workflows/\(alfredWorkflowUID)/info.plist")

        let workflowData = try! Data(contentsOf: url)
        let info = try! PropertyListSerialization.propertyList(from: workflowData, options: [], format: nil) as! [String: Any]

        return info["version"] as! String
    }

    public static func update(with fileURL: String) -> Bool {
        guard let url = URL(string: fileURL) else { return false }

        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.downloadTask(with: url) { location, _, _ in
            if let location = location {
                _ = openWorkflowFile(location: location)
            }

            semaphore.signal()
        }.resume()

        semaphore.wait()

        return true
    }

    private static func openWorkflowFile(location: URL) -> Bool {
        let documentsURL = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let savedURL = documentsURL?.appendingPathComponent("KAT.alfredworkflow")
        try? FileManager.default.moveItem(at: location, to: savedURL!)

        let task = Process()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = [savedURL!.path]

        do {
            try task.run()
        } catch {
            return false
        }

        return true
    }
}
