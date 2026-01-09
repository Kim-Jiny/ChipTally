package com.chiptally.domain.model

import java.util.Date

data class GameSession(
    val players: MutableList<Player>,
    val transactions: MutableList<Transaction> = mutableListOf(),
    val initialChipCount: Int,
    val createdAt: Date = Date()
)
