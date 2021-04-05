@testable import AlfredWorkflowUpdater
import XCTest

final class OpenReleasePageTests: AlfredWorkflowUpdaterTestCase {
    func test_that_the_user_can_open_the_latest_release_page() {
        XCTAssertTrue(
            Updater.open(page: "https://github.com/godbout/AlfredKat/releases/latest")
        )
    }
}
