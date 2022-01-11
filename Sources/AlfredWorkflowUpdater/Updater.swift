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

        guard let releaseVersion = try? document.select("#repo-content-pjax-container h1").first()?.text() else { return nil }
        guard currentVersion().compare(releaseVersion, options: .numeric) == .orderedAscending else { return nil }

        guard let releaseFile = try? document.select("#repo-content-pjax-container div.Box-footer li:nth-child(1) > a").first()?.attr("href") else { return nil }

        return (version: releaseVersion, file: "https://github.com\(releaseFile)", page: releasePage)
    }

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

    public static func open(page: String) -> Bool {
        open(item: page)
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

    private static func openWorkflowFile(at path: String) -> Bool {
        open(item: path)
    }

    public static func notify(title: String, message: String) -> Bool {
        let task = Process()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = [
            "-e",
            """
                display notification "\(message)" with title "\(title)"
            """,
        ]

        do {
            try task.run()
        } catch {
            return false
        }

        return true
    }
}
