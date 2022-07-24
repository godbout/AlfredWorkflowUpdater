import XCTest
@testable import AlfredWorkflowUpdaterCore


class createInfoCacheFileTests: AlfredWorkflowUpdaterTestCase {
    
    func test_that_it_can_create_the_update_available_plist_file() {
        let releaseInfo = ReleaseInfo(
            version: "1.3.37",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        )
        
        XCTAssertNil(Updater.infoFromCache())
        
        Updater.createInfoCacheFile(for: releaseInfo)
                
        let infoFromCache = Updater.infoFromCache()
        
        XCTAssertEqual(infoFromCache?.version, "1.3.37")
        XCTAssertEqual(infoFromCache?.file, "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow")
        XCTAssertEqual(infoFromCache?.page, "https://github.com/godbout/AlfredDummy/releases/latest")
    }
    
}
