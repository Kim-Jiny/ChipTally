//
//  Transaction.swift
//  ChipTally
//

import Foundation

struct Transaction: Identifiable {
    let id: UUID
    let fromPlayerId: UUID
    let toPlayerId: UUID
    let amount: Int
    let timestamp: Date

    init(id: UUID = UUID(), fromPlayerId: UUID, toPlayerId: UUID, amount: Int, timestamp: Date = Date()) {
        self.id = id
        self.fromPlayerId = fromPlayerId
        self.toPlayerId = toPlayerId
        self.amount = amount
        self.timestamp = timestamp
    }
}
