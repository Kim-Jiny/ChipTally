package com.chiptally.presentation.common

import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

private data class Insets(val left: Int, val top: Int, val right: Int, val bottom: Int)

/**
 * targetSdk 36 부터 edge-to-edge 가 강제되므로 시스템 바 영역만큼 직접 패딩을 준다.
 *
 * 키보드(IME)도 같이 본다. edge-to-edge 에서 IME 는 systemBars 인셋에 포함되지 않아
 * 이걸 빼먹으면 키보드가 화면 하단 버튼을 덮는다.
 */
fun applySystemBarInsets(root: View) {
    val initial = Insets(root.paddingLeft, root.paddingTop, root.paddingRight, root.paddingBottom)
    ViewCompat.setOnApplyWindowInsetsListener(root) { view, insets ->
        val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
        val ime = insets.getInsets(WindowInsetsCompat.Type.ime())
        view.setPadding(
            initial.left + bars.left,
            initial.top + bars.top,
            initial.right + bars.right,
            initial.bottom + maxOf(bars.bottom, ime.bottom)
        )
        insets
    }
    ViewCompat.requestApplyInsets(root)
}
