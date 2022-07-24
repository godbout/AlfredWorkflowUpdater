import XCTest
@testable import AlfredWorkflowUpdaterCore


class UpdateInfoFromCacheTests: AlfredWorkflowUpdaterTestCase {

    func test_that_if_there_is_no_updateInfoCacheFile_then_it_returns_nil() {
        XCTAssertNil(
            Updater.updateInfoFromCache()
        )
    }
    
    func test_that_if_there_is_an_updateInfoCacheFile_then_it_returns_the_correct_info() {
        Self.mockAlreadyCreatedUpdateInfoFile(with: UpdateInfo(
            version: "1.3.37",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        ))
        
        let updateInfo = Updater.updateInfoFromCache()
        
        XCTAssertEqual(updateInfo?.version, "1.3.37")
        XCTAssertEqual(updateInfo?.file, "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow")
        XCTAssertEqual(updateInfo?.page, "https://github.com/godbout/AlfredDummy/releases/latest")
    }
    
}
