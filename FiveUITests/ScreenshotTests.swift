import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()
    var screenshotDir: String {
        let subdir: String
        if let content = try? String(contentsOfFile: "/tmp/screenshot_subdir.txt", encoding: .utf8),
           !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            subdir = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            subdir = "Screenshots"
        }
        return "/Users/sadygsadygov/Desktop/new_dom/Five/\(subdir)"
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: "\(screenshotDir)/\(name).png")
        try? data.write(to: url)
    }

    @MainActor
    func testCaptureAllScreenshots() throws {
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)

        app.launchArguments = ["-hasCompletedOnboarding", "NO"]
        app.launch()
        sleep(3)
        saveScreenshot("01-onboarding-welcome")

        let beginBtn = app.buttons["Begin Your Quest"]
        if beginBtn.waitForExistence(timeout: 3) {
            beginBtn.tap()
            sleep(2)
            saveScreenshot("02-onboarding-name")

            let nextBtn = app.buttons["Next"]
            if nextBtn.waitForExistence(timeout: 3) {
                nextBtn.tap()
                sleep(2)
                saveScreenshot("03-onboarding-skills")
            }
        }

        app.terminate()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        sleep(3)
        saveScreenshot("04-home-xp-bar")

        let window = app.windows.firstMatch
        window.swipeUp()
        sleep(1)
        saveScreenshot("05-home-achievements")

        window.swipeDown()
        sleep(1)
        let addBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'plus'")).firstMatch
        if addBtn.waitForExistence(timeout: 3) {
            addBtn.tap()
            sleep(2)
            saveScreenshot("06-add-skill-sheet")

            let sheetWindow = app.windows.firstMatch
            sheetWindow.swipeUp()
            sleep(1)
            saveScreenshot("07-add-skill-categories")

            let cancelBtn = app.buttons["Cancel"]
            if cancelBtn.waitForExistence(timeout: 2) {
                cancelBtn.tap()
                sleep(1)
            } else {
                app.swipeDown()
                sleep(1)
            }
        }

        let statsBtn = app.buttons["Stats"]
        if statsBtn.waitForExistence(timeout: 3) {
            statsBtn.tap()
            sleep(2)
            saveScreenshot("08-stats-charts")
        }

        let profileBtn = app.buttons["Profile"]
        if profileBtn.waitForExistence(timeout: 3) {
            profileBtn.tap()
            sleep(2)
            saveScreenshot("09-profile")

            window.swipeUp()
            sleep(1)
            saveScreenshot("10-profile-achievements")
        }

        let homeBtn = app.buttons["Home"]
        if homeBtn.waitForExistence(timeout: 3) {
            homeBtn.tap()
            sleep(1)
        }
        let practiceBtn = app.buttons["Start Practice"]
        if practiceBtn.waitForExistence(timeout: 3) {
            practiceBtn.tap()
            sleep(2)
            saveScreenshot("11-practice-timer")
        } else {
            let playBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'play' OR label CONTAINS[c] 'practice'")).firstMatch
            if playBtn.waitForExistence(timeout: 3) {
                playBtn.tap()
                sleep(2)
                saveScreenshot("11-practice-timer")
            }
        }
    }
}
