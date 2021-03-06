import XCTest
@testable import AlfredWorkflowUpdaterCore


class UpdateTests: AlfredWorkflowUpdaterTestCase {
    
    func test_that_the_user_can_download_and_open_the_latest_release() {
        let onlineFile = "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow"

        XCTAssertTrue(
            Updater.update(with: onlineFile)
        )
    }

    func test_that_an_update_works_even_if_an_old_version_of_the_workflow_is_in_the_downloads_folder() {
        let onlineFile = "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow"

        Self.mockAlreadyDownloadedAlfredDummyWorkflowToUserDownloadsFolder()

        XCTAssertTrue(
            Updater.update(with: onlineFile)
        )
    }
    
}
