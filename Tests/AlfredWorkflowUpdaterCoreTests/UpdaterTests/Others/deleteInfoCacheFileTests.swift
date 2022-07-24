import XCTest
@testable import AlfredWorkflowUpdaterCore


class deleteInfoCacheFileTests: AlfredWorkflowUpdaterTestCase {
    
    func test_that_well_it_deletes_the_update_available_plist_file() {
        Self.mockAlreadyCreatedUpdateInfoFile(with: ReleaseInfo(
            version: "1.3.37",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        ))
        
        XCTAssertNotNil(Updater.infoFromCache())
        Updater.deleteInfoCacheFile()
        XCTAssertNil(Updater.infoFromCache())
    }
    
}
