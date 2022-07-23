import XCTest


class AlfredWorkflowUpdaterTestCase: XCTestCase {
    
    override class func setUp() {
        super.setUp()

        mockAlfredPreferencesFolder()
        mockDummyWorkflowUID()
    }

    private static func mockAlfredPreferencesFolder() {
        var folder = URL(string: #file)!
        folder.deleteLastPathComponent()

        Self.setEnvironmentVariable(name: "alfred_preferences", value: folder.path + "/Resources")
    }

    private static func mockDummyWorkflowUID() {
        Self.setEnvironmentVariable(name: "alfred_workflow_uid", value: "AlfredDummy")
    }

    private static func setEnvironmentVariable(name: String, value: String) {
        setenv(name, value, 1)
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
    
}
