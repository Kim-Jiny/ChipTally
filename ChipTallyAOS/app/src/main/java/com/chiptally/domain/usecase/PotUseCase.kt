package com.chiptally.domain.usecase

import com.chiptally.domain.model.GameSession
import com.chiptally.domain.model.Transaction
import com.chiptally.domain.model.TransactionType
import com.chiptally.domain.model.TransferError

/**
 * 보드 가운데 팟에 칩을 걸고, 승자가 전액을 가져가는 흐름.
 *
 * '이번 판'은 마지막 [TransactionType.POT_WIN] 이후를 뜻한다. 별도 상태를 두지 않고
 * 거래 내역에서 계산하므로 저장/복원과 자동으로 맞아떨어진다.
 */
class PotUseCase {

    fun bet(session: GameSession, playerId: String, amount: Int): Result<Transaction> {
        if (amount <= 0) {
            return Result.failure(TransferException(TransferError.InvalidAmount))
        }

        val player = session.players.find { it.id == playerId }
            ?: return Result.failure(TransferException(TransferError.InvalidPlayer))

        if (player.chipCount < amount) {
            return Result.failure(TransferException(TransferError.InsufficientChips))
        }

        player.chipCount -= amount
        session.pot += amount

        val transaction = Transaction.bet(playerId = playerId, amount = amount)
        session.transactions.add(transaction)
        return Result.success(transaction)
    }

    fun collectPot(session: GameSession, winnerId: String): Result<Transaction> {
        val pot = session.pot
        if (pot <= 0) {
            return Result.failure(TransferException(TransferError.EmptyPot))
        }

        val winner = session.players.find { it.id == winnerId }
            ?: return Result.failure(TransferException(TransferError.InvalidPlayer))

        winner.chipCount += pot
        session.pot = 0

        val transaction = Transaction.potWin(playerId = winnerId, amount = pot)
        session.transactions.add(transaction)
        return Result.success(transaction)
    }

    /** 이번 판에 [playerId] 가 팟에 넣은 총액. '묻고 더블로 가!' 의 기준이 된다. */
    fun currentRoundBet(session: GameSession, playerId: String): Int =
        session.transactions
            .takeLastWhile { it.type != TransactionType.POT_WIN }
            .filter { it.type == TransactionType.BET && it.fromPlayerId == playerId }
            .sumOf { it.amount }
}
