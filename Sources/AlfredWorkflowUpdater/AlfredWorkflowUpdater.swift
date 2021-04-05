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
}
