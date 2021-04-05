@testable import AlfredWorkflowUpdater
import XCTest

final class UpdateTests: AlfredWorkflowUpdaterTestCase {
    func test_that_the_user_can_download_and_open_the_latest_release() {
        XCTAssertTrue(
            Updater.update(with: "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow")
        )
    }
}

