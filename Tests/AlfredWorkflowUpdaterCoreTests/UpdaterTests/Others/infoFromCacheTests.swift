import XCTest
@testable import AlfredWorkflowUpdaterCore


class infoFromCacheTests: AlfredWorkflowUpdaterTestCase {

    func test_that_if_there_is_no_updateAvailable_plist_file_then_it_returns_nil() {
        XCTAssertNil(
            Updater.infoFromCache()
        )
    }
    
    func test_that_if_there_is_an_updateAvailable_plist_file_then_it_returns_the_correct_info() {
        Self.mockAlreadyCreatedUpdateInfoFile(with: ReleaseInfo(
            version: "1.3.28",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.28/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        ))
        
        let releaseInfo = Updater.infoFromCache()
        
        XCTAssertEqual(releaseInfo?.version, "1.3.28")
        XCTAssertEqual(releaseInfo?.file, "https://github.com/godbout/AlfredDummy/releases/download/1.3.28/AlfredDummy.alfredworkflow")
        XCTAssertEqual(releaseInfo?.page, "https://github.com/godbout/AlfredDummy/releases/latest")
    }
    
}
