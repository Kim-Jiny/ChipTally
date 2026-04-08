package com.chiptally.presentation.game

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.chiptally.data.repository.GameRepositoryImpl
import com.chiptally.domain.model.GameSession
import com.chiptally.domain.model.Player
import com.chiptally.domain.model.Transaction
import com.chiptally.domain.model.TransferError
import com.chiptally.domain.usecase.TransferChipsUseCase
import com.chiptally.domain.usecase.TransferException

class GameViewModel(
    private val transferChipsUseCase: TransferChipsUseCase = TransferChipsUseCase(),
    private var gameRepository: GameRepositoryImpl? = null
) : ViewModel() {

    private var _session: GameSession? = null

    private val _players = MutableLiveData<List<Player>>()
    val players: LiveData<List<Player>> = _players

    private val _transactions = MutableLiveData<List<Transaction>>()
    val transactions: LiveData<List<Transaction>> = _transactions

    private val _transferResult = MutableLiveData<TransferResult?>()
    val transferResult: LiveData<TransferResult?> = _transferResult

    fun setRepository(repository: GameRepositoryImpl) {
        gameRepository = repository
    }

    fun setSession(session: GameSession) {
        _session = session
        updateLiveData()
    }

    fun loadSession() {
        gameRepository?.loadSession()?.let { session ->
            _session = session
            updateLiveData()
        }
    }

    fun transferChips(fromIndex: Int, toIndex: Int, amount: Int) {
        val session = _session ?: return
        val players = session.players

        if (fromIndex !in players.indices || toIndex !in players.indices) return

        val fromPlayer = players[fromIndex]
        val toPlayer = players[toIndex]

        val result = transferChipsUseCase.execute(
            session = session,
            fromPlayerId = fromPlayer.id,
            toPlayerId = toPlayer.id,
            amount = amount
        )

        result.fold(
            onSuccess = { transaction ->
                gameRepository?.saveSession(session)
                updateLiveData()
                _transferResult.value = TransferResult.Success(transaction)
            },
            onFailure = { exception ->
                val error = (exception as? TransferException)?.error
                _transferResult.value = TransferResult.Error(error ?: TransferError.InvalidAmount)
            }
        )
    }

    fun getPlayerName(id: String): String {
        return _session?.players?.find { it.id == id }?.name ?: "Unknown"
    }

    fun resetGame() {
        gameRepository?.clearSession()
        _session = null
        _players.value = emptyList()
        _transactions.value = emptyList()
    }

    fun clearTransferResult() {
        _transferResult.value = null
    }

    private fun updateLiveData() {
        _session?.let { session ->
            _players.value = session.players.toList()
            _transactions.value = session.transactions.toList()
        }
    }
}

sealed class TransferResult {
    data class Success(val transaction: Transaction) : TransferResult()
    data class Error(val error: TransferError) : TransferResult()
}
