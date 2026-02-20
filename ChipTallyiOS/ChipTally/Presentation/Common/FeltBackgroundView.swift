//
//  FeltBackgroundView.swift
//  ChipTally
//

import UIKit

final class FeltBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let speckleLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        gradientLayer.colors = [Theme.Colors.tableFelt.cgColor, Theme.Colors.tableFeltDark.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        layer.addSublayer(gradientLayer)

        speckleLayer.opacity = 0.25
        layer.addSublayer(speckleLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        speckleLayer.frame = bounds
        speckleLayer.contents = makeSpeckleImage()?.cgImage
        speckleLayer.contentsScale = UIScreen.main.scale
    }

    private func makeSpeckleImage() -> UIImage? {
        let size = CGSize(width: 120, height: 120)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))

            for _ in 0..<140 {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let radius = CGFloat.random(in: 0.5...1.6)
                let alpha = CGFloat.random(in: 0.05...0.18)
                let color = UIColor.white.withAlphaComponent(alpha)
                ctx.setFillColor(color.cgColor)
                ctx.fillEllipse(in: CGRect(x: x, y: y, width: radius, height: radius))
            }
        }
    }
}
