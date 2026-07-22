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
    /// 보드 가운데 모여 있는 칩. 누군가 가져가면 0 으로 돌아간다.
    var pot: Int

    init(players: [Player], initialChipCount: Int, createdAt: Date = Date(), pot: Int = 0) {
        self.players = players
        self.transactions = []
        self.initialChipCount = initialChipCount
        self.createdAt = createdAt
        self.pot = pot
    }
}
