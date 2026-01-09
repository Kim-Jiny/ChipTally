//
//  AppCoordinator.swift
//  ChipTally
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showSetup()
    }

    private func showSetup() {
        let setupVC = SetupViewController()
        setupVC.delegate = self
        window.rootViewController = setupVC
        window.makeKeyAndVisible()
    }

    private func showGame(with session: GameSession) {
        let gameVC = GameViewController(session: session)
        gameVC.delegate = self

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            self.window.rootViewController = gameVC
        }
    }
}

// MARK: - SetupViewControllerDelegate

extension AppCoordinator: SetupViewControllerDelegate {
    func setupViewController(_ controller: SetupViewController, didStartGameWith session: GameSession) {
        showGame(with: session)
    }
}

// MARK: - GameViewControllerDelegate

extension AppCoordinator: GameViewControllerDelegate {
    func gameViewControllerDidEndGame(_ controller: GameViewController) {
        showSetup()
    }
}
