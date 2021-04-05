//
//  AlfredWorkflowUpdaterTestCase.swift
//  AlfredWorkflowUpdaterTests
//
//  Created by Guillaume Leclerc on 05/04/2021.
//

import XCTest

class AlfredWorkflowUpdaterTestCase: XCTestCase {
    override class func setUp() {
        super.setUp()

        mockAlfredPreferencesFolder()
        mockDummyWorkflowUID()

        print("setup")
    }

    static func mockAlfredPreferencesFolder() {
        var folder = URL(string: #file)!
        folder.deleteLastPathComponent()

        Self.setEnvironmentVariable(name: "alfred_preferences", value: folder.path + "/Resources")
    }

    static func mockDummyWorkflowUID() {
        Self.setEnvironmentVariable(name: "alfred_workflow_uid", value: "AlfredDummy")
    }

    private static func setEnvironmentVariable(name: String, value: String) {
        setenv(name, value, 1)
    }

    static func setLocalWorkflowVersion(to version: String) {
        let alfredPreferencesFolder = ProcessInfo.processInfo.environment["alfred_preferences"] ?? ""
        let alfredWorkflowUID = ProcessInfo.processInfo.environment["alfred_workflow_uid"] ?? ""

        let url = URL(fileURLWithPath: "\(alfredPreferencesFolder)/workflows/\(alfredWorkflowUID)/info.plist")

        let workflowData = try! Data(contentsOf: url)
        var info = try! PropertyListSerialization.propertyList(from: workflowData, options: [], format: nil) as! [String: Any]

        info["version"] = version

        if let writeInfo = try? PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0) {
            try? writeInfo.write(to: url)
        }
    }
}
