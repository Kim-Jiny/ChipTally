//
//  PotUseCase.swift
//  ChipTally
//

import Foundation

protocol PotUseCaseProtocol {
    func bet(session: inout GameSession, playerId: UUID, amount: Int) -> Result<Transaction, TransferError>
    func collectPot(session: inout GameSession, winnerId: UUID) -> Result<Transaction, TransferError>
    func currentRoundBet(session: GameSession, playerId: UUID) -> Int
}

/// 보드 가운데 팟에 칩을 걸고, 승자가 전액을 가져가는 흐름.
///
/// '이번 판' 은 마지막 `.potWin` 이후를 뜻한다. 별도 상태를 두지 않고 거래 내역에서
/// 계산하므로 저장/복원과 자동으로 맞아떨어진다.
final class PotUseCase: PotUseCaseProtocol {

    func bet(session: inout GameSession, playerId: UUID, amount: Int) -> Result<Transaction, TransferError> {
        guard amount > 0 else {
            return .failure(.invalidAmount)
        }
        guard let index = session.players.firstIndex(where: { $0.id == playerId }) else {
            return .failure(.invalidPlayer)
        }
        guard session.players[index].chipCount >= amount else {
            return .failure(.insufficientChips)
        }

        session.players[index].chipCount -= amount
        session.pot += amount

        let transaction = Transaction.bet(playerId: playerId, amount: amount)
        session.transactions.append(transaction)
        return .success(transaction)
    }

    func collectPot(session: inout GameSession, winnerId: UUID) -> Result<Transaction, TransferError> {
        let pot = session.pot
        guard pot > 0 else {
            return .failure(.emptyPot)
        }
        guard let index = session.players.firstIndex(where: { $0.id == winnerId }) else {
            return .failure(.invalidPlayer)
        }

        session.players[index].chipCount += pot
        session.pot = 0

        let transaction = Transaction.potWin(playerId: winnerId, amount: pot)
        session.transactions.append(transaction)
        return .success(transaction)
    }

    func currentRoundBet(session: GameSession, playerId: UUID) -> Int {
        session.transactions
            .reversed()
            .prefix { $0.type != .potWin }
            .filter { $0.type == .bet && $0.fromPlayerId == playerId }
            .reduce(0) { $0 + $1.amount }
    }
}
