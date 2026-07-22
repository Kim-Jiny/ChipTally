//
//  BannerAdView.swift
//  ChipTally
//

import UIKit
import GoogleMobileAds

final class BannerAdView: UIView {

    private var bannerView: BannerView?
    private let adUnitID: String

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(in viewController: UIViewController) {
        // 이미 붙였으면 다시 만들지 않는다.
        guard bannerView == nil else { return }

        // 고정 AdSizeBanner(320pt)는 요즘 기기 폭에서 좌우가 남아 광고가 떠 보인다.
        // 실제 폭에 맞춘 adaptive 배너를 쓴다.
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)

        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self

        addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        self.bannerView = bannerView
        bannerView.load(Request())
    }

    /// adaptive 배너의 실제 높이. 레이아웃에서 자리를 미리 잡는 데 쓴다.
    static func adaptiveHeight(for width: CGFloat) -> CGFloat {
        currentOrientationAnchoredAdaptiveBanner(width: width).size.height
    }
}

// MARK: - BannerViewDelegate

extension BannerAdView: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        if bannerView.alpha == 0 {
            UIView.animate(withDuration: 0.3) {
                bannerView.alpha = 1
            }
        }
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[AdMob] Banner ad failed to load: \(error.localizedDescription)")
    }
}
