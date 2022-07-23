import Foundation


guard CommandLine.arguments.count == 3 else { exit(1) }

let gitHubRepository = CommandLine.arguments[1]
let checkFrequenceInMinutes = CommandLine.arguments[2]

let action = ProcessInfo.processInfo.environment["AlfredWorkflowUpdater_action"] 

switch action {
case "update":
    guard let localUpdateInfo = Updater.localUpdateInfo() else { exit(2) }
    
    _ = Updater.update(with: localUpdateInfo.file)
case "open":
    guard let localUpdateInfo = Updater.localUpdateInfo() else { exit(2) }
    
    _ = Updater.open(page: localUpdateInfo.page)
default:
    if let release = Updater.checkUpdateOnline(for: gitHubRepository) {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { exit(3) }
        
        let encoder = PropertyListEncoder()
        guard let encoded = try? encoder.encode(release) else { exit(4) }
        
        FileManager.default.createFile(atPath: "\(alfredWorkflowCache)/update_available.plist", contents: encoded)
    }
}

exit(0)
