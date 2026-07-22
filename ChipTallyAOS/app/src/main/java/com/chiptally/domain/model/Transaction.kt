package com.chiptally.domain.model

import java.util.Date
import java.util.UUID

enum class TransactionType {
    /** 플레이어끼리 1:1 로 주고받음. */
    TRANSFER,

    /** 플레이어가 팟에 걸었음. [Transaction.toPlayerId] 는 비어 있다. */
    BET,

    /** 플레이어가 팟을 전부 가져감. [Transaction.fromPlayerId] 는 비어 있다. */
    POT_WIN
}

data class Transaction(
    val id: String = UUID.randomUUID().toString(),
    val fromPlayerId: String,
    val toPlayerId: String,
    val amount: Int,
    val timestamp: Date = Date(),
    // Gson 은 Unsafe 로 객체를 만들어 생성자 기본값을 무시한다. 이 필드가 없던 시절에
    // 저장된 세션을 읽으면 null 이 들어오므로 nullable 로 두고 [type] 으로 읽는다.
    private val transactionType: TransactionType? = null
) {
    val type: TransactionType
        get() = transactionType ?: TransactionType.TRANSFER

    companion object {
        fun transfer(fromPlayerId: String, toPlayerId: String, amount: Int) = Transaction(
            fromPlayerId = fromPlayerId,
            toPlayerId = toPlayerId,
            amount = amount,
            transactionType = TransactionType.TRANSFER
        )

        fun bet(playerId: String, amount: Int) = Transaction(
            fromPlayerId = playerId,
            toPlayerId = "",
            amount = amount,
            transactionType = TransactionType.BET
        )

        fun potWin(playerId: String, amount: Int) = Transaction(
            fromPlayerId = "",
            toPlayerId = playerId,
            amount = amount,
            transactionType = TransactionType.POT_WIN
        )
    }
}
