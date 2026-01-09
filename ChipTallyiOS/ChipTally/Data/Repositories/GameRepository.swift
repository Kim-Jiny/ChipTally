//
//  GameRepository.swift
//  ChipTally
//

import Foundation

final class GameRepository: GameRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let sessionKey = "currentGameSession"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSession(_ session: GameSession) {
        let data = GameSessionData(from: session)
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: sessionKey)
        }
    }

    func loadSession() -> GameSession? {
        guard let data = userDefaults.data(forKey: sessionKey),
              let sessionData = try? JSONDecoder().decode(GameSessionData.self, from: data) else {
            return nil
        }
        return sessionData.toGameSession()
    }

    func clearSession() {
        userDefaults.removeObject(forKey: sessionKey)
    }
}

// MARK: - Codable Data Models

private struct GameSessionData: Codable {
    let players: [PlayerData]
    let transactions: [TransactionData]
    let initialChipCount: Int
    let createdAt: Date

    init(from session: GameSession) {
        self.players = session.players.map { PlayerData(from: $0) }
        self.transactions = session.transactions.map { TransactionData(from: $0) }
        self.initialChipCount = session.initialChipCount
        self.createdAt = session.createdAt
    }

    func toGameSession() -> GameSession {
        var session = GameSession(
            players: players.map { $0.toPlayer() },
            initialChipCount: initialChipCount,
            createdAt: createdAt
        )
        session.transactions = transactions.map { $0.toTransaction() }
        return session
    }
}

private struct PlayerData: Codable {
    let id: UUID
    let name: String
    let chipCount: Int

    init(from player: Player) {
        self.id = player.id
        self.name = player.name
        self.chipCount = player.chipCount
    }

    func toPlayer() -> Player {
        Player(id: id, name: name, chipCount: chipCount)
    }
}

private struct TransactionData: Codable {
    let id: UUID
    let fromPlayerId: UUID
    let toPlayerId: UUID
    let amount: Int
    let timestamp: Date

    init(from transaction: Transaction) {
        self.id = transaction.id
        self.fromPlayerId = transaction.fromPlayerId
        self.toPlayerId = transaction.toPlayerId
        self.amount = transaction.amount
        self.timestamp = transaction.timestamp
    }

    func toTransaction() -> Transaction {
        Transaction(
            id: id,
            fromPlayerId: fromPlayerId,
            toPlayerId: toPlayerId,
            amount: amount,
            timestamp: timestamp
        )
    }
}
