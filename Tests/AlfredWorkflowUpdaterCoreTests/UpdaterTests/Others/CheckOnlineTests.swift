import XCTest
@testable import AlfredWorkflowUpdaterCore


class CheckOnlineTests: AlfredWorkflowUpdaterTestCase {
    
    func test_that_there_is_no_release_if_the_latest_online_is_equal_to_the_current_user_s_one() {
        Self.setLocalWorkflowVersion(to: "1.3.37")

        let release = Updater.checkOnline(for: "godbout/AlfredDummy")

        XCTAssertNil(release)
    }

    func test_that_there_is_no_release_if_the_latest_online_is_lower_than_the_current_user_s_one() {
        Self.setLocalWorkflowVersion(to: "1.3.38")

        let release = Updater.checkOnline(for: "godbout/AlfredDummy")

        XCTAssertNil(release)
    }

    func test_that_there_is_a_release_if_the_latest_online_is_higher_than_the_current_user() {
        Self.setLocalWorkflowVersion(to: "1.3.36")

        let release = Updater.checkOnline(for: "godbout/AlfredDummy")

        XCTAssertNotNil(release)
    }

    func test_that_the_release_info_is_correct_if_well_there_is_a_release() {
        Self.setLocalWorkflowVersion(to: "1.3.36")

        let release = Updater.checkOnline(for: "godbout/AlfredDummy")

        XCTAssertEqual(release?.version, "1.3.37")
        XCTAssertEqual(release?.page, "https://github.com/godbout/AlfredDummy/releases/latest")
        XCTAssertEqual(
            release?.file,
            "https://github.com/godbout/AlfredDummy/releases/download/1.3.37/AlfredDummy.alfredworkflow"
        )
    }

    func test_that_the_comparison_of_release_version_numbers_work_properly() {
        Self.setLocalWorkflowVersion(to: "1.3")
        let release = Updater.checkOnline(for: "godbout/AlfredDummy")
        XCTAssertNotNil(release)

        Self.setLocalWorkflowVersion(to: "1.3.4")
        let anotherRelease = Updater.checkOnline(for: "godbout/AlfredDummy")
        XCTAssertNotNil(anotherRelease)

        Self.setLocalWorkflowVersion(to: "1.3.40")
        let anotherOtherRelease = Updater.checkOnline(for: "godbout/AlfredDummy")
        XCTAssertNil(anotherOtherRelease)
    }

}
