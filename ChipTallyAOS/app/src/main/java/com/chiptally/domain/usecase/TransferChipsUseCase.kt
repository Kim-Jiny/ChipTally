package com.chiptally.domain.usecase

import com.chiptally.domain.model.GameSession
import com.chiptally.domain.model.Transaction
import com.chiptally.domain.model.TransferError

class TransferChipsUseCase {
    fun execute(
        session: GameSession,
        fromPlayerId: String,
        toPlayerId: String,
        amount: Int
    ): Result<Transaction> {
        if (amount <= 0) {
            return Result.failure(TransferException(TransferError.InvalidAmount))
        }

        if (fromPlayerId == toPlayerId) {
            return Result.failure(TransferException(TransferError.SamePlayer))
        }

        val fromPlayer = session.players.find { it.id == fromPlayerId }
        val toPlayer = session.players.find { it.id == toPlayerId }

        if (fromPlayer == null || toPlayer == null) {
            return Result.failure(TransferException(TransferError.InvalidPlayer))
        }

        if (fromPlayer.chipCount < amount) {
            return Result.failure(TransferException(TransferError.InsufficientChips))
        }

        fromPlayer.chipCount -= amount
        toPlayer.chipCount += amount

        val transaction = Transaction(
            fromPlayerId = fromPlayerId,
            toPlayerId = toPlayerId,
            amount = amount
        )
        session.transactions.add(transaction)

        return Result.success(transaction)
    }
}

class TransferException(val error: TransferError) : Exception()
