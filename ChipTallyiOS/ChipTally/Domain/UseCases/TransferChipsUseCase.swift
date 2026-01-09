//
//  TransferChipsUseCase.swift
//  ChipTally
//

import Foundation

protocol TransferChipsUseCaseProtocol {
    func execute(session: inout GameSession, fromPlayerId: UUID, toPlayerId: UUID, amount: Int) -> Result<Transaction, TransferError>
}

enum TransferError: Error, LocalizedError {
    case insufficientChips
    case invalidPlayer
    case samePlayer
    case invalidAmount

    var errorDescription: String? {
        switch self {
        case .insufficientChips:
            return "error.insufficientChips".localized
        case .invalidPlayer:
            return "error.invalidPlayer".localized
        case .samePlayer:
            return "error.samePlayer".localized
        case .invalidAmount:
            return "error.invalidAmount".localized
        }
    }
}

final class TransferChipsUseCase: TransferChipsUseCaseProtocol {
    func execute(session: inout GameSession, fromPlayerId: UUID, toPlayerId: UUID, amount: Int) -> Result<Transaction, TransferError> {
        guard amount > 0 else {
            return .failure(.invalidAmount)
        }

        guard fromPlayerId != toPlayerId else {
            return .failure(.samePlayer)
        }

        guard let fromIndex = session.players.firstIndex(where: { $0.id == fromPlayerId }),
              let toIndex = session.players.firstIndex(where: { $0.id == toPlayerId }) else {
            return .failure(.invalidPlayer)
        }

        guard session.players[fromIndex].chipCount >= amount else {
            return .failure(.insufficientChips)
        }

        session.players[fromIndex].chipCount -= amount
        session.players[toIndex].chipCount += amount

        let transaction = Transaction(
            fromPlayerId: fromPlayerId,
            toPlayerId: toPlayerId,
            amount: amount
        )
        session.transactions.append(transaction)

        return .success(transaction)
    }
}
