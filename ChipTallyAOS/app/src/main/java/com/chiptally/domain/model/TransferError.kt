package com.chiptally.domain.model

sealed class TransferError {
    object InsufficientChips : TransferError()
    object InvalidPlayer : TransferError()
    object SamePlayer : TransferError()
    object InvalidAmount : TransferError()
}
