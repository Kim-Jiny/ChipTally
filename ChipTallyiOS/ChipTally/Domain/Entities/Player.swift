//
//  Player.swift
//  ChipTally
//

import Foundation

struct Player: Identifiable, Equatable {
    let id: UUID
    var name: String
    var chipCount: Int

    init(id: UUID = UUID(), name: String, chipCount: Int = 0) {
        self.id = id
        self.name = name
        self.chipCount = chipCount
    }
}
