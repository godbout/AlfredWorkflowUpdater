import XCTest
import AlfredWorkflowUpdaterCore


class UpdaterTests: XCTestCase {
    
    func test_that_it_can_open_the_release_page() {
        XCTAssertTrue(
            Updater.open(page: "https://github.com/godbout/AlfredKat/releases/latest")
        )
    }
    
}
