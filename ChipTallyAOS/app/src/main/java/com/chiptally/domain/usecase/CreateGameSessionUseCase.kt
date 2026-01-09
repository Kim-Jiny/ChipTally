package com.chiptally.domain.usecase

import com.chiptally.domain.model.GameSession
import com.chiptally.domain.model.Player

class CreateGameSessionUseCase {
    fun execute(playerNames: List<String>, initialChipCount: Int): GameSession {
        val players = playerNames.map { name ->
            Player(name = name, chipCount = initialChipCount)
        }.toMutableList()
        return GameSession(players = players, initialChipCount = initialChipCount)
    }
}
