package com.chiptally.presentation.common

import android.app.Activity
import android.view.ViewGroup
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView

/**
 * 컨테이너 폭에 맞춘 adaptive 배너를 붙인다.
 *
 * 고정 [AdSize.BANNER] 는 320dp 라서 요즘 기기 폭에서는 좌우가 남아 광고가 떠 보인다.
 * adSize 는 AdView 당 한 번만 지정할 수 있으므로 XML 이 아니라 여기서 생성한다.
 */
fun Activity.loadAdaptiveBanner(container: ViewGroup, adUnitId: String) {
    container.post {
        // post 가 여러 번 돌더라도 배너는 하나만 유지한다.
        if (container.childCount > 0) return@post

        val density = resources.displayMetrics.density
        val widthPx = container.width.takeIf { it > 0 } ?: resources.displayMetrics.widthPixels
        val widthDp = (widthPx / density).toInt()

        val adView = AdView(this).apply {
            this.adUnitId = adUnitId
            setAdSize(
                AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
                    this@loadAdaptiveBanner,
                    widthDp
                )
            )
        }
        container.addView(adView)
        adView.loadAd(AdRequest.Builder().build())
    }
}
