import XCTest
@testable import AlfredWorkflowUpdaterCore


class AlfredWorkflowUpdaterTestCase: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        mockAlfredPreferencesFolder()
        mockDummyWorkflowUID()
        mockAlfredWorkflowCacheFolder()
        mockAlfredWorkflowUpdaterAssetName()
        spoofArguments()
    }
    
    override func setUp() {
        super.setUp()
        
        try? Self.removeAlreadyCreatedUpdateInfoFile()
        Self.removeAlreadyDownloadedAlfredDummyWorkflowFromUserDownloadsFolder()
    }
    
}


extension AlfredWorkflowUpdaterTestCase {
        
    static var updateAvailableFile: String? {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return nil }
        
        return "\(alfredWorkflowCache)/update_available.plist"
    }
    
    static var lastCheckedFile: String? {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return nil }
        
        return "\(alfredWorkflowCache)/last_checked.plist"
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
    
    static func mockAlreadyCreatedUpdateInfoFile(with releaseInfo: ReleaseInfo) throws {
        let updateAvailableFile = try XCTUnwrap(Self.updateAvailableFile)
        
        let encoder = PropertyListEncoder()
        guard let encoded = try? encoder.encode(releaseInfo) else { return XCTFail() }
        
        FileManager.default.createFile(atPath: updateAvailableFile, contents: encoded)
    }
    
    static func mockAlreadyCreatedUpdateInfoFile() {
        let releaseInfo = ReleaseInfo(
            version: "1.3.37",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        )
                
        try? mockAlreadyCreatedUpdateInfoFile(with: releaseInfo)
    }
    
    static func mockWorkflowActionVariable(with action: String) {
        setEnvironmentVariable(name: "AlfredWorkflowUpdater_action", value: action)
    }
    
    static func mockLastChecked(toMinutesAgo minutes: Int) throws {
        let lastCheckedFile = try XCTUnwrap(Self.lastCheckedFile)
        
        let mockedDate = Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())
        
        let encoder = PropertyListEncoder()
        guard let encoded = try? encoder.encode([mockedDate]) else { return }
        
        guard let _ = try? FileManager.default.removeItem(atPath: lastCheckedFile) else { return }
        FileManager.default.createFile(atPath: lastCheckedFile, contents: encoded)
    }
    
    static func lastChecked() throws -> Date? {
        let lastCheckedFile = try XCTUnwrap(Self.lastCheckedFile)
        
        let url = URL(fileURLWithPath: lastCheckedFile)
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let decoder = PropertyListDecoder()
        guard let date = try? decoder.decode([Date].self, from: data) else { return nil }
               
        return date.first
    }
    
}


extension AlfredWorkflowUpdaterTestCase {

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
    
    private static func mockAlfredWorkflowUpdaterAssetName() {
        Self.setEnvironmentVariable(name: "alfred_workflow_updater_asset_name", value: "AlfredDummy.alfredworkflow")
    }
        
    private static func spoofArguments() {
        let argumentsCount = CommandLine.arguments.count
        
        // currently there's still no way to pass arguments to swift test... which means filling arguments (without appending)
        // will crash if the index doesn't exist. but if it exists, we need to keep that indice. so here you go.
        argumentsCount >= 2 ? CommandLine.arguments[1] = "godbout/AlfredDummy" : CommandLine.arguments.append("godbout/AlfredDummy") 
        argumentsCount >= 3 ? CommandLine.arguments[2] = "5" : CommandLine.arguments.append("5")
    }

    private static func setEnvironmentVariable(name: String, value: String) {
        setenv(name, value, 1)
    }
    
    private static func removeAlreadyCreatedUpdateInfoFile() throws {
        let updateAvailableFile = try XCTUnwrap(Self.updateAvailableFile)
        
        if FileManager.default.fileExists(atPath: updateAvailableFile) {
            guard let _ = try? FileManager.default.removeItem(atPath: updateAvailableFile) else { return XCTFail() }
        }
    }
    
    private static func removeAlreadyDownloadedAlfredDummyWorkflowFromUserDownloadsFolder() {
        do {
            let downloadsFolderURL = try FileManager.default.url(
                for: .downloadsDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let downloadedWorkflowFile = downloadsFolderURL.appendingPathComponent("AlfredDummy.alfredworkflow").path
            
            if FileManager.default.fileExists(atPath: downloadedWorkflowFile) {
                guard let _ = try? FileManager.default.removeItem(atPath: downloadedWorkflowFile) else { return XCTFail() }
            }
        } catch {
            XCTFail("can't remove fake AlfredDummy.alfredworkflow from ~/Downloads folder")
        }
    }
    
}
