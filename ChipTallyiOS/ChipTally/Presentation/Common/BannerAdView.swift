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
        let bannerView = BannerView(adSize: AdSizeBanner)
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
