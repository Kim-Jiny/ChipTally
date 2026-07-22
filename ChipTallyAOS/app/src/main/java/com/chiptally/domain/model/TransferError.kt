package com.chiptally.domain.model

sealed class TransferError {
    object InsufficientChips : TransferError()
    object InvalidPlayer : TransferError()
    object SamePlayer : TransferError()
    object InvalidAmount : TransferError()

    /** 팟이 비어 있어 가져갈 것이 없음. */
    object EmptyPot : TransferError()
}
