import XCTest
@testable import AlfredWorkflowUpdaterCore


// only testing the main should be enough. all the other funcs could actually be private,
// but i let some internal, to extra test them individually. it's not needed but that'll make
// the testing more solid. usually i wouldn't do this because it pollutes the test suite, but that
// Swift Package should almost never change. so the rest is testing in Others.
class mainTests: AlfredWorkflowUpdaterTestCase {}


// update
extension mainTests {
    
    func test_that_when_the_action_is_update_the_latest_version_of_the_Workflow_is_downloaded() {
        
    }
        
    func test_that_when_the_action_is_update_the_file_the_updateAvailable_cache_file_gets_deleted() {
        Self.mockAlreadyCreatedUpdateInfoFile(with: ReleaseInfo(
            version: "1.3.37",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        ))
        
        Self.mockWorkflowActionVariable(with: "update")
        
        XCTAssertNotNil(Updater.infoFromCache())
        _ = Updater.main()
        XCTAssertNil(Updater.infoFromCache())
    }
        
} 


// open
extension mainTests {
    
    func test_that_when_the_action_is_open_it_supposedly_opens_the_release_page_and_returns_0() {
        Self.mockAlreadyCreatedUpdateInfoFile(with: ReleaseInfo(
            version: "1.3.37",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        ))
                
        Self.mockWorkflowActionVariable(with: "open")
        
        XCTAssertEqual(0, Updater.main())
    }
    
}
