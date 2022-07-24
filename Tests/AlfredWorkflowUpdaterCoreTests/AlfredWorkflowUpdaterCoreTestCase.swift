import XCTest
@testable import AlfredWorkflowUpdaterCore


class AlfredWorkflowUpdaterTestCase: XCTestCase {
    
    override class func setUp() {
        super.setUp()

        mockAlfredPreferencesFolder()
        mockDummyWorkflowUID()
        mockAlfredWorkflowCacheFolder()
        spoofArguments() 
    }
    
    override func setUp() {
        Self.removeAlreadyCreatedUpdateInfoFile()
    }

    private static func mockAlfredPreferencesFolder() {
        var folder = URL(string: #file)!
        folder.deleteLastPathComponent()

        Self.setEnvironmentVariable(name: "alfred_preferences", value: folder.path + "/Resources/AlfredPreferences")
    }
    
    private static func mockDummyWorkflowUID() {
        Self.setEnvironmentVariable(name: "alfred_workflow_uid", value: "AlfredDummy")
    }
    
    private static func mockAlfredWorkflowCacheFolder() {
        var folder = URL(string: #file)!
        folder.deleteLastPathComponent()
        
        guard let alfredWorkflowUID = ProcessInfo.processInfo.environment["alfred_workflow_uid"] else { return XCTFail() }

        Self.setEnvironmentVariable(name: "alfred_workflow_cache", value: folder.path + "/Resources/Caches/\(alfredWorkflowUID)")
    }
        
    private static func spoofArguments() {
        CommandLine.arguments[1] = "godbout/AlfredDummy"
        CommandLine.arguments[2] = "5"
    }

    private static func setEnvironmentVariable(name: String, value: String) {
        setenv(name, value, 1)
    }
    
    private static func removeAlreadyCreatedUpdateInfoFile() {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return XCTFail() }
        
        let updateAvailableFile = "\(alfredWorkflowCache)/update_available.plist"
        
        if FileManager.default.fileExists(atPath: updateAvailableFile) {
            guard let _ = try? FileManager.default.removeItem(atPath: updateAvailableFile) else { return XCTFail() }
        }
    }

    static func setLocalWorkflowVersion(to version: String) {
        let alfredPreferencesFolder = ProcessInfo.processInfo.environment["alfred_preferences"] ?? ""
        let alfredWorkflowUID = ProcessInfo.processInfo.environment["alfred_workflow_uid"] ?? ""

        let url = URL(fileURLWithPath: "\(alfredPreferencesFolder)/workflows/\(alfredWorkflowUID)/info.plist")

        do {
            let workflowData = try Data(contentsOf: url)

            if var info = try PropertyListSerialization.propertyList(from: workflowData, options: [], format: nil) as? [String: Any] {
                info["version"] = version

                let writeInfo = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
                try writeInfo.write(to: url)

                return
            }

            throw NSError()
        } catch {
            XCTFail("couldn't mock local Dummy workflow version")
        }
    }

    static func mockAlreadyDownloadedAlfredDummyWorkflowToUserDownloadsFolder() {
        do {
            let downloadsFolderURL = try FileManager.default.url(
                for: .downloadsDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let oldWorkflowFile = downloadsFolderURL.appendingPathComponent("AlfredDummy.alfredworkflow")

            FileManager.default.createFile(atPath: oldWorkflowFile.path, contents: nil, attributes: nil)
        } catch {
            XCTFail("can't create fake AlfredDummy.alfredworkflow in ~/Downloads folder")
        }
    }
    
    static func mockAlreadyCreatedUpdateInfoFile(with releaseInfo: ReleaseInfo) {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return XCTFail() }
        
        let encoder = PropertyListEncoder()
        guard let encoded = try? encoder.encode(releaseInfo) else { return XCTFail() }
        
        FileManager.default.createFile(atPath: "\(alfredWorkflowCache)/update_available.plist", contents: encoded)
    }
    
    static func mockWorkflowActionVariable(with action: String) {
        setEnvironmentVariable(name: "AlfredWorkflowUpdater_action", value: action)
    }
    
}
