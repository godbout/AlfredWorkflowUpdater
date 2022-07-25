import XCTest
@testable import AlfredWorkflowUpdaterCore


class DeleteInfoCacheFileTests: AlfredWorkflowUpdaterTestCase {
    
    func test_that_well_it_deletes_the_updateAvailable_plist_file() {
        Self.mockAlreadyCreatedUpdateInfoFile()
        
        XCTAssertNotNil(Updater.infoFromCache())
        Updater.deleteInfoCacheFile()
        XCTAssertNil(Updater.infoFromCache())
    }
    
}
