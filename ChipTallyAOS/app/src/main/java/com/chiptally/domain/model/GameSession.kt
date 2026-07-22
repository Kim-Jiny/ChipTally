package com.chiptally.domain.model

import java.util.Date

data class GameSession(
    val players: MutableList<Player>,
    val transactions: MutableList<Transaction> = mutableListOf(),
    val initialChipCount: Int,
    val createdAt: Date = Date(),
    /** 보드 가운데 모여 있는 칩. 누군가 가져가면 0 으로 돌아간다. */
    var pot: Int = 0
)
