//
//  GameViewModel.swift
//  ChipTally
//

import Foundation

protocol GameViewModelDelegate: AnyObject {
    func didUpdateSession()
    func didTransferChips(transaction: Transaction)
    func didPlaceBet(playerName: String, amount: Int)
    func didWinPot(playerName: String, amount: Int)
    func didFailTransfer(error: TransferError)
}

final class GameViewModel {
    weak var delegate: GameViewModelDelegate?

    private let transferChipsUseCase: TransferChipsUseCaseProtocol
    private let potUseCase: PotUseCaseProtocol
    private let gameRepository: GameRepositoryProtocol

    private(set) var session: GameSession

    var players: [Player] {
        session.players
    }

    var transactions: [Transaction] {
        session.transactions
    }

    var pot: Int {
        session.pot
    }

    init(
        session: GameSession,
        transferChipsUseCase: TransferChipsUseCaseProtocol = TransferChipsUseCase(),
        potUseCase: PotUseCaseProtocol = PotUseCase(),
        gameRepository: GameRepositoryProtocol = GameRepository()
    ) {
        self.session = session
        self.transferChipsUseCase = transferChipsUseCase
        self.potUseCase = potUseCase
        self.gameRepository = gameRepository
    }

    func transferChips(fromIndex: Int, toIndex: Int, amount: Int) {
        guard players.indices.contains(fromIndex), players.indices.contains(toIndex) else { return }

        let fromPlayer = players[fromIndex]
        let toPlayer = players[toIndex]

        let result = transferChipsUseCase.execute(
            session: &session,
            fromPlayerId: fromPlayer.id,
            toPlayerId: toPlayer.id,
            amount: amount
        )

        switch result {
        case .success(let transaction):
            gameRepository.saveSession(session)
            delegate?.didTransferChips(transaction: transaction)
            delegate?.didUpdateSession()
        case .failure(let error):
            delegate?.didFailTransfer(error: error)
        }
    }

    /// `playerIndex` 가 팟에 `amount` 만큼 건다.
    func bet(playerIndex: Int, amount: Int) {
        guard players.indices.contains(playerIndex) else { return }
        let player = players[playerIndex]

        switch potUseCase.bet(session: &session, playerId: player.id, amount: amount) {
        case .success(let transaction):
            gameRepository.saveSession(session)
            delegate?.didPlaceBet(playerName: player.name, amount: transaction.amount)
            delegate?.didUpdateSession()
        case .failure(let error):
            delegate?.didFailTransfer(error: error)
        }
    }

    /// `winnerIndex` 가 팟 전액을 가져간다.
    func collectPot(winnerIndex: Int) {
        guard players.indices.contains(winnerIndex) else { return }
        let winner = players[winnerIndex]

        switch potUseCase.collectPot(session: &session, winnerId: winner.id) {
        case .success(let transaction):
            gameRepository.saveSession(session)
            delegate?.didWinPot(playerName: winner.name, amount: transaction.amount)
            delegate?.didUpdateSession()
        case .failure(let error):
            delegate?.didFailTransfer(error: error)
        }
    }

    /// 이번 판에 `playerIndex` 가 이미 건 금액.
    func currentRoundBet(playerIndex: Int) -> Int {
        guard players.indices.contains(playerIndex) else { return 0 }
        return potUseCase.currentRoundBet(session: session, playerId: players[playerIndex].id)
    }

    func getPlayerName(for id: UUID) -> String {
        players.first { $0.id == id }?.name ?? "Unknown"
    }

    func resetGame() {
        gameRepository.clearSession()
    }
}
