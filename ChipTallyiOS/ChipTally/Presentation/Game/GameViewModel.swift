//
//  GameViewModel.swift
//  ChipTally
//

import Foundation

protocol GameViewModelDelegate: AnyObject {
    func didUpdateSession()
    func didTransferChips(transaction: Transaction)
    func didFailTransfer(error: TransferError)
}

final class GameViewModel {
    weak var delegate: GameViewModelDelegate?

    private let transferChipsUseCase: TransferChipsUseCaseProtocol
    private let gameRepository: GameRepositoryProtocol

    private(set) var session: GameSession

    var players: [Player] {
        session.players
    }

    var transactions: [Transaction] {
        session.transactions
    }

    init(
        session: GameSession,
        transferChipsUseCase: TransferChipsUseCaseProtocol = TransferChipsUseCase(),
        gameRepository: GameRepositoryProtocol = GameRepository()
    ) {
        self.session = session
        self.transferChipsUseCase = transferChipsUseCase
        self.gameRepository = gameRepository
    }

    func transferChips(fromIndex: Int, toIndex: Int, amount: Int) {
        guard fromIndex < players.count, toIndex < players.count else { return }

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

    func getPlayerName(for id: UUID) -> String {
        players.first { $0.id == id }?.name ?? "Unknown"
    }

    func resetGame() {
        gameRepository.clearSession()
    }
}
