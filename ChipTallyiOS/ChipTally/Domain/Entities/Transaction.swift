//
//  Transaction.swift
//  ChipTally
//

import Foundation

enum TransactionType: String, Codable {
    /// 플레이어끼리 1:1 로 주고받음.
    case transfer
    /// 플레이어가 팟에 걸었음. `toPlayerId` 는 팟 자리표시자다.
    case bet
    /// 플레이어가 팟을 전부 가져감. `fromPlayerId` 는 팟 자리표시자다.
    case potWin
}

struct Transaction: Identifiable {
    let id: UUID
    let fromPlayerId: UUID
    let toPlayerId: UUID
    let amount: Int
    let timestamp: Date
    let type: TransactionType

    init(
        id: UUID = UUID(),
        fromPlayerId: UUID,
        toPlayerId: UUID,
        amount: Int,
        timestamp: Date = Date(),
        type: TransactionType = .transfer
    ) {
        self.id = id
        self.fromPlayerId = fromPlayerId
        self.toPlayerId = toPlayerId
        self.amount = amount
        self.timestamp = timestamp
        self.type = type
    }

    static func transfer(fromPlayerId: UUID, toPlayerId: UUID, amount: Int) -> Transaction {
        Transaction(fromPlayerId: fromPlayerId, toPlayerId: toPlayerId, amount: amount, type: .transfer)
    }

    static func bet(playerId: UUID, amount: Int) -> Transaction {
        Transaction(fromPlayerId: playerId, toPlayerId: Transaction.potId, amount: amount, type: .bet)
    }

    static func potWin(playerId: UUID, amount: Int) -> Transaction {
        Transaction(fromPlayerId: Transaction.potId, toPlayerId: playerId, amount: amount, type: .potWin)
    }

    /// 사람이 아닌 '팟' 을 가리키는 자리표시자. 어떤 플레이어 id 와도 겹치지 않는다.
    static let potId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}
