package com.chiptally.domain.repository

import com.chiptally.domain.model.GameSession

interface GameRepository {
    fun saveSession(session: GameSession)
    fun loadSession(): GameSession?
    fun clearSession()
}
