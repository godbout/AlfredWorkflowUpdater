import XCTest
@testable import AlfredWorkflowUpdaterCore


// only testing the main should be enough. all the other funcs could actually be private,
// but i let some internal, to extra test them individually. it's not needed but that'll make
// the testing more solid. usually i wouldn't do this because it pollutes the test suite, but that
// Swift Package should almost never change. so the rest is testing in Others.
class mainTests: AlfredWorkflowUpdaterTestCase {
    
    private func lastChecked() -> Date? {
        guard let alfredWorkflowCache = ProcessInfo.processInfo.environment["alfred_workflow_cache"] else { return nil }
        
        let url = URL(fileURLWithPath: "\(alfredWorkflowCache)/last_checked.plist")
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let decoder = PropertyListDecoder()
        guard let date = try? decoder.decode([Date].self, from: data) else { return nil }
               
        return date.first
    }

}


// update
extension mainTests {
    
    func test_that_when_the_action_is_update_the_latest_version_of_the_Workflow_is_downloaded() {
        Self.mockAlreadyCreatedUpdateInfoFile()
        Self.mockWorkflowActionVariable(with: "update")
        
        _ = Updater.main()
               
        guard let downloadsFolderURL = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return XCTFail() }
        let downloadedWorkflowFile = downloadsFolderURL.appendingPathComponent("AlfredDummy.alfredworkflow").path
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: downloadedWorkflowFile))
    }
        
    func test_that_when_the_action_is_update_the_updateAvailable_cache_file_gets_deleted() {
        Self.mockAlreadyCreatedUpdateInfoFile()
        Self.mockWorkflowActionVariable(with: "update")
        
        XCTAssertNotNil(Updater.infoFromCache())
        _ = Updater.main()
        XCTAssertNil(Updater.infoFromCache())
    }
        
} 


// open
extension mainTests {
    
    func test_that_when_the_action_is_open_it_supposedly_opens_the_release_page_and_returns_0() {
        Self.mockAlreadyCreatedUpdateInfoFile()
        Self.mockWorkflowActionVariable(with: "open")
        
        XCTAssertEqual(0, Updater.main())
    }
    
}


// check
extension mainTests {
    
    func test_that_when_there_is_no_specific_action_called_and_the_frequency_threshold_has_not_passed_then_there_is_no_online_check_and_no_creation_of_updateAvailable_plist() throws {
        Self.mockLastChecked(toMinutesAgo: 5)
        Self.mockWorkflowActionVariable(with: "")
        Self.setLocalWorkflowVersion(to: "1.3.30" )
        CommandLine.arguments[2] = "60"
        
        _ = Updater.main()
        
        let updateAvailablePlistFilePath = try XCTUnwrap(updateAvailablePlistFilePath)
        XCTAssertFalse(FileManager.default.fileExists(atPath: updateAvailablePlistFilePath))
    }
    
    func test_that_when_there_is_no_specific_action_called_and_the_frequency_threshold_has_not_passed_then_the_lastCheckedCacheFile_is_not_updated() {
        Self.mockLastChecked(toMinutesAgo: 5)
        Self.mockWorkflowActionVariable(with: "")
        CommandLine.arguments[2] = "60"
        
        let lastCheckedBefore = lastChecked()
        _ = Updater.main()
        let lastCheckedAfter = lastChecked()
        
        XCTAssertEqual(lastCheckedBefore, lastCheckedAfter)
    }
        
    func test_that_when_there_is_no_specific_action_called_and_the_frequency_threshold_has_passed_but_there_is_no_available_update_then_no_updateAvailable_plist_files_get_created() throws {
        Self.mockLastChecked(toMinutesAgo: 60)
        Self.mockWorkflowActionVariable(with: "")
        Self.setLocalWorkflowVersion(to: "1.3.100" )
        CommandLine.arguments[2] = "30"
        
        _ = Updater.main()
        
        let updateAvailablePlistFilePath = try XCTUnwrap(updateAvailablePlistFilePath)
        XCTAssertFalse(FileManager.default.fileExists(atPath: updateAvailablePlistFilePath))
    }
    
    func test_that_when_there_is_no_specific_action_called_and_the_frequency_threshold_has_passed_and_there_is_an_available_update_then_the_updateAvailable_plist_files_get_created() throws {
        Self.mockLastChecked(toMinutesAgo: 60)
        Self.mockWorkflowActionVariable(with: "")
        Self.setLocalWorkflowVersion(to: "1.3.30" )
        CommandLine.arguments[2] = "30"
        
        _ = Updater.main()
        
        let updateAvailablePlistFilePath = try XCTUnwrap(updateAvailablePlistFilePath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: updateAvailablePlistFilePath))
    }

    func test_that_when_there_is_no_specific_action_called_and_the_frequency_threshold_has_passed_then_the_lastCheckedCacheFile_is_updated() {
        Self.mockLastChecked(toMinutesAgo: 15)
        Self.mockWorkflowActionVariable(with: "")
        CommandLine.arguments[2] = "4"
        
        let lastCheckedBefore = lastChecked()
        _ = Updater.main()
        let lastCheckedAfter = lastChecked()
        
        XCTAssertNotEqual(lastCheckedBefore, lastCheckedAfter)
    }
    
}
