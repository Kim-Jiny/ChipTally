package com.chiptally.domain.model

import java.util.UUID

data class Player(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    var chipCount: Int = 0
)
