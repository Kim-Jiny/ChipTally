//
//  GameSession.swift
//  ChipTally
//

import Foundation

struct GameSession {
    var players: [Player]
    var transactions: [Transaction]
    let initialChipCount: Int
    let createdAt: Date

    init(players: [Player], initialChipCount: Int, createdAt: Date = Date()) {
        self.players = players
        self.transactions = []
        self.initialChipCount = initialChipCount
        self.createdAt = createdAt
    }
}
