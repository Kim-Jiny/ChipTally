package com.chiptally.presentation.setup

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.chiptally.data.repository.GameRepositoryImpl
import com.chiptally.domain.model.GameSession
import com.chiptally.domain.usecase.CreateGameSessionUseCase

class SetupViewModel(
    private val createGameSessionUseCase: CreateGameSessionUseCase = CreateGameSessionUseCase(),
    private var gameRepository: GameRepositoryImpl? = null
) : ViewModel() {

    private val _playerCount = MutableLiveData(2)
    val playerCount: LiveData<Int> = _playerCount

    private val _playerNames = MutableLiveData(mutableListOf("", ""))
    val playerNames: LiveData<MutableList<String>> = _playerNames

    private val _initialChipCount = MutableLiveData(100)
    val initialChipCount: LiveData<Int> = _initialChipCount

    private val _isFormValid = MutableLiveData(false)
    val isFormValid: LiveData<Boolean> = _isFormValid

    private val _gameSession = MutableLiveData<GameSession?>()
    val gameSession: LiveData<GameSession?> = _gameSession

    val minPlayerCount = 2
    val maxPlayerCount = 10

    fun setRepository(repository: GameRepositoryImpl) {
        gameRepository = repository
    }

    fun loadSavedSettings() {
        gameRepository?.let { repo ->
            val savedNames = repo.loadPlayerNames()
            if (!savedNames.isNullOrEmpty()) {
                _playerNames.value = savedNames.toMutableList()
                _playerCount.value = savedNames.size
            }

            val savedChipCount = repo.loadChipCount()
            if (savedChipCount > 0) {
                _initialChipCount.value = savedChipCount
            }
        }
        validateForm()
    }

    fun incrementPlayerCount() {
        val current = _playerCount.value ?: minPlayerCount
        if (current < maxPlayerCount) {
            _playerNames.value?.add("")
            _playerCount.value = current + 1
            validateForm()
        }
    }

    fun decrementPlayerCount() {
        val current = _playerCount.value ?: minPlayerCount
        if (current > minPlayerCount) {
            _playerNames.value?.removeAt(_playerNames.value!!.lastIndex)
            _playerCount.value = current - 1
            validateForm()
        }
    }

    fun updatePlayerName(index: Int, name: String) {
        _playerNames.value?.let { names ->
            if (index < names.size) {
                names[index] = name
                _playerNames.value = names
                validateForm()
            }
        }
    }

    fun updateInitialChipCount(count: Int) {
        _initialChipCount.value = maxOf(1, count)
        validateForm()
    }

    fun createGameSession() {
        val names = _playerNames.value ?: return
        val chipCount = _initialChipCount.value ?: 100

        gameRepository?.savePlayerNames(names)
        gameRepository?.saveChipCount(chipCount)

        val session = createGameSessionUseCase.execute(names, chipCount)
        gameRepository?.saveSession(session)
        _gameSession.value = session
    }

    fun resetToDefaults() {
        gameRepository?.clearSettings()
        _playerNames.value = mutableListOf("", "")
        _initialChipCount.value = 100
        _playerCount.value = 2
        validateForm()
    }

    private fun validateForm() {
        val names = _playerNames.value ?: return
        val chipCount = _initialChipCount.value ?: 0

        val allNamesValid = names.all { it.trim().isNotEmpty() }
        val chipCountValid = chipCount > 0

        _isFormValid.value = allNamesValid && chipCountValid
    }
}
