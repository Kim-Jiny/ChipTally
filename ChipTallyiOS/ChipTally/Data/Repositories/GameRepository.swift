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
    let pot: Int?

    init(from session: GameSession) {
        self.players = session.players.map { PlayerData(from: $0) }
        self.transactions = session.transactions.map { TransactionData(from: $0) }
        self.initialChipCount = session.initialChipCount
        self.createdAt = session.createdAt
        self.pot = session.pot
    }

    func toGameSession() -> GameSession {
        // pot 이 없던 시절에 저장된 세션도 읽을 수 있어야 한다.
        var session = GameSession(
            players: players.map { $0.toPlayer() },
            initialChipCount: initialChipCount,
            createdAt: createdAt,
            pot: pot ?? 0
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
    let type: TransactionType?

    init(from transaction: Transaction) {
        self.id = transaction.id
        self.fromPlayerId = transaction.fromPlayerId
        self.toPlayerId = transaction.toPlayerId
        self.amount = transaction.amount
        self.timestamp = transaction.timestamp
        self.type = transaction.type
    }

    func toTransaction() -> Transaction {
        // type 이 없던 시절 기록은 전부 1:1 전송이었다.
        Transaction(
            id: id,
            fromPlayerId: fromPlayerId,
            toPlayerId: toPlayerId,
            amount: amount,
            timestamp: timestamp,
            type: type ?? .transfer
        )
    }
}
