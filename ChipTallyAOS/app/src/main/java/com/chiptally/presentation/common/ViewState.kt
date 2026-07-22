package com.chiptally.presentation.common

import android.view.View

/**
 * 버튼을 활성/비활성으로 바꾸면서 눌리지 않는다는 걸 눈으로도 보이게 한다.
 *
 * MaterialButton 은 보통 backgroundTint 의 ColorStateList 로 비활성을 표현하는데,
 * 이 앱은 배경을 drawable 로 직접 지정하고 `app:backgroundTint="@null"` 로 틴트를
 * 꺼두었다(안 그러면 colorPrimary 빨강이 테두리 drawable 을 덮어버린다).
 * 그래서 흐리게 만드는 일은 여기서 직접 한다.
 */
fun View.setEnabledAppearance(enabled: Boolean) {
    isEnabled = enabled
    alpha = if (enabled) 1f else DISABLED_ALPHA
}

private const val DISABLED_ALPHA = 0.4f
