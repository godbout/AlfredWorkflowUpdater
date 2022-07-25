import XCTest
@testable import AlfredWorkflowUpdaterCore


class CreateInfoCacheFileTests: AlfredWorkflowUpdaterTestCase {
    
    func test_that_it_can_create_the_updateAvailable_plist_file() {
        let releaseInfo = ReleaseInfo(
            version: "1.3.88",
            file: "https://github.com/godbout/AlfredDummy/releases/download/1.3.88/AlfredDummy.alfredworkflow",
            page: "https://github.com/godbout/AlfredDummy/releases/latest"
        )
        
        XCTAssertNil(Updater.infoFromCache())
        
        Updater.createInfoCacheFile(for: releaseInfo)
                
        let infoFromCache = Updater.infoFromCache()
        
        XCTAssertEqual(infoFromCache?.version, "1.3.88")
        XCTAssertEqual(infoFromCache?.file, "https://github.com/godbout/AlfredDummy/releases/download/1.3.88/AlfredDummy.alfredworkflow")
        XCTAssertEqual(infoFromCache?.page, "https://github.com/godbout/AlfredDummy/releases/latest")
    }
    
}
