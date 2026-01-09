//
//  SetupViewModel.swift
//  ChipTally
//

import Foundation

protocol SetupViewModelDelegate: AnyObject {
    func didUpdatePlayerCount(_ count: Int)
    func didValidateForm(_ isValid: Bool)
    func didLoadSavedSettings()
}

final class SetupViewModel {
    weak var delegate: SetupViewModelDelegate?

    private let createGameSessionUseCase: CreateGameSessionUseCaseProtocol
    private let gameRepository: GameRepositoryProtocol
    private let userDefaults: UserDefaults

    private static let playerNamesKey = "lastPlayerNames"
    private static let chipCountKey = "lastChipCount"

    private(set) var playerCount: Int = 2 {
        didSet {
            delegate?.didUpdatePlayerCount(playerCount)
            validateForm()
        }
    }

    private(set) var playerNames: [String] = ["", ""]
    private(set) var initialChipCount: Int = 100

    var minPlayerCount: Int { 2 }
    var maxPlayerCount: Int { 10 }

    init(
        createGameSessionUseCase: CreateGameSessionUseCaseProtocol = CreateGameSessionUseCase(),
        gameRepository: GameRepositoryProtocol = GameRepository(),
        userDefaults: UserDefaults = .standard
    ) {
        self.createGameSessionUseCase = createGameSessionUseCase
        self.gameRepository = gameRepository
        self.userDefaults = userDefaults
    }

    func loadSavedSettings() {
        if let savedNames = userDefaults.stringArray(forKey: Self.playerNamesKey),
           !savedNames.isEmpty {
            playerNames = savedNames
            playerCount = savedNames.count
        }

        let savedChipCount = userDefaults.integer(forKey: Self.chipCountKey)
        if savedChipCount > 0 {
            initialChipCount = savedChipCount
        }

        delegate?.didLoadSavedSettings()
        validateForm()
    }

    private func saveSettings() {
        userDefaults.set(playerNames, forKey: Self.playerNamesKey)
        userDefaults.set(initialChipCount, forKey: Self.chipCountKey)
    }

    func resetToDefaults() {
        userDefaults.removeObject(forKey: Self.playerNamesKey)
        userDefaults.removeObject(forKey: Self.chipCountKey)

        playerNames = ["", ""]
        initialChipCount = 100
        playerCount = 2

        delegate?.didLoadSavedSettings()
        validateForm()
    }

    func incrementPlayerCount() {
        guard playerCount < maxPlayerCount else { return }
        playerNames.append("")
        playerCount += 1
    }

    func decrementPlayerCount() {
        guard playerCount > minPlayerCount else { return }
        playerNames.removeLast()
        playerCount -= 1
    }

    func updatePlayerName(at index: Int, name: String) {
        guard index < playerNames.count else { return }
        playerNames[index] = name
        validateForm()
    }

    func updateInitialChipCount(_ count: Int) {
        initialChipCount = max(1, count)
        validateForm()
    }

    func createGameSession() -> GameSession {
        saveSettings()
        let session = createGameSessionUseCase.execute(
            playerNames: playerNames,
            initialChipCount: initialChipCount
        )
        gameRepository.saveSession(session)
        return session
    }

    private func validateForm() {
        let allNamesValid = playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let chipCountValid = initialChipCount > 0
        delegate?.didValidateForm(allNamesValid && chipCountValid)
    }
}
