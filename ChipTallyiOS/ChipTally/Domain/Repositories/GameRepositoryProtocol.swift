//
//  GameRepositoryProtocol.swift
//  ChipTally
//

import Foundation

protocol GameRepositoryProtocol {
    func saveSession(_ session: GameSession)
    func loadSession() -> GameSession?
    func clearSession()
}
