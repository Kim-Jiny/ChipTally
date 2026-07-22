//
//  PotFlowUITests.swift
//  ChipTallyUITests
//
//  베팅/팟 흐름과 화면 배치를 실제로 눌러보며 확인한다.
//

import XCTest

final class PotFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        dismissTrackingPromptIfNeeded()
    }

    /// ATT 동의 알럿은 스프링보드가 띄우므로 앱 밖에서 처리한다.
    private func dismissTrackingPromptIfNeeded() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons["앱에 추적 금지 요청"]
        if allow.waitForExistence(timeout: 5) {
            allow.tap()
        }
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testBetAndTakePot() throws {
        // 설정: 이름 두 개를 넣고 게임 시작
        let fields = app.textFields
        XCTAssertTrue(fields.element(boundBy: 1).waitForExistence(timeout: 5), "이름 입력칸이 없다")

        let first = fields.element(boundBy: 1)
        first.tap()
        first.typeText("Jiny")

        let second = fields.element(boundBy: 2)
        second.tap()
        second.typeText("Minsu")

        capture("01-설정")

        // 키보드를 내려야 시작 버튼이 가려지지 않는다.
        app.staticTexts["플레이어 이름"].tap()
        app.buttons["게임 시작"].tap()
        sleep(2)
        capture("02-게임화면")

        // 팟 바 열기 — 헤더 바로 아래 가운데
        let potBar = app.staticTexts["팟"].firstMatch
        XCTAssertTrue(potBar.waitForExistence(timeout: 5), "팟 바가 없다")
        potBar.tap()
        sleep(1)
        capture("03-팟화면")

        // +50 으로 베팅
        app.buttons["+50"].tap()
        app.buttons["베팅하기"].tap()
        sleep(2)
        capture("04-베팅후")

        // 다시 열어서 팟 가져가기
        app.staticTexts["팟"].firstMatch.tap()
        sleep(1)
        app.buttons["팟 가져가기"].tap()
        sleep(1)
        capture("05-회수확인")

        // 알럿의 확인 버튼
        app.alerts.buttons["팟 가져가기"].tap()
        sleep(2)
        capture("06-회수후")
    }
}
