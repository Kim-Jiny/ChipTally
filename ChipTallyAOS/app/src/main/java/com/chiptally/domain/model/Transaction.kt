package com.chiptally.domain.model

import java.util.Date
import java.util.UUID

data class Transaction(
    val id: String = UUID.randomUUID().toString(),
    val fromPlayerId: String,
    val toPlayerId: String,
    val amount: Int,
    val timestamp: Date = Date()
)
