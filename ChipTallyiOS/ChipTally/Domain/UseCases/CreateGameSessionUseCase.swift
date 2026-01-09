//
//  CreateGameSessionUseCase.swift
//  ChipTally
//

import Foundation

protocol CreateGameSessionUseCaseProtocol {
    func execute(playerNames: [String], initialChipCount: Int) -> GameSession
}

final class CreateGameSessionUseCase: CreateGameSessionUseCaseProtocol {
    func execute(playerNames: [String], initialChipCount: Int) -> GameSession {
        let players = playerNames.map { name in
            Player(name: name, chipCount: initialChipCount)
        }
        return GameSession(players: players, initialChipCount: initialChipCount)
    }
}
