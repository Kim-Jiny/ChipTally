package com.chiptally.presentation.common

import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

private data class Insets(val left: Int, val top: Int, val right: Int, val bottom: Int)

fun applySystemBarInsets(root: View) {
    val initial = Insets(root.paddingLeft, root.paddingTop, root.paddingRight, root.paddingBottom)
    ViewCompat.setOnApplyWindowInsetsListener(root) { view, insets ->
        val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
        view.setPadding(
            initial.left + bars.left,
            initial.top + bars.top,
            initial.right + bars.right,
            initial.bottom + bars.bottom
        )
        insets
    }
    ViewCompat.requestApplyInsets(root)
}
