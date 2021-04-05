@testable import AlfredWorkflowUpdater
import XCTest

final class NotifyTests: AlfredWorkflowUpdaterTestCase {
    func test_that_the_user_can_be_notified_of_the_download_of_the_update() {
        XCTAssertTrue(
            Updater.notify(title: "Alfred Dummy", message: "downloading the update!")
        )
    }
}
