//
//  ChipTokenView.swift
//  ChipTally
//

import UIKit

final class ChipTokenView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let ringLayer = CAShapeLayer()
    private let innerRingLayer = CAShapeLayer()
    private let stripeLayer = CAShapeLayer()
    private let shineLayer = CAShapeLayer()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.chipCount
        label.textAlignment = .center
        label.textColor = Theme.Colors.chipCream
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var baseColor: UIColor = Theme.Colors.chipRed {
        didSet { updateColors() }
    }

    var accentColor: UIColor = Theme.Colors.chipCream {
        didSet { updateColors() }
    }

    var textColor: UIColor = Theme.Colors.chipCream {
        didSet { countLabel.textColor = textColor }
    }

    var text: String? {
        didSet { countLabel.text = text }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        layer.addSublayer(ringLayer)
        layer.addSublayer(innerRingLayer)
        layer.addSublayer(stripeLayer)
        layer.addSublayer(shineLayer)

        addSubview(countLabel)

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        countLabel.layer.shadowColor = UIColor.black.cgColor
        countLabel.layer.shadowOpacity = 0.25
        countLabel.layer.shadowRadius = 2
        countLabel.layer.shadowOffset = CGSize(width: 0, height: 1)

        addShadow(opacity: 0.35, radius: 12, offset: CGSize(width: 0, height: 8))
        updateColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        let radius = min(bounds.width, bounds.height) / 2
        layer.cornerRadius = radius
        layer.masksToBounds = true
        gradientLayer.cornerRadius = radius

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let ringPath = UIBezierPath(arcCenter: center, radius: radius - 3, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        ringLayer.path = ringPath.cgPath
        ringLayer.lineWidth = 6
        ringLayer.fillColor = UIColor.clear.cgColor

        let innerRingPath = UIBezierPath(arcCenter: center, radius: radius * 0.55, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        innerRingLayer.path = innerRingPath.cgPath
        innerRingLayer.lineWidth = 4
        innerRingLayer.fillColor = UIColor.clear.cgColor

        let stripePath = UIBezierPath()
        let stripeRadius = radius - 8
        let segmentCount = 6
        let segmentAngle = (CGFloat.pi * 2) / CGFloat(segmentCount)
        let gap = segmentAngle * 0.35
        for i in 0..<segmentCount {
            let start = (CGFloat(i) * segmentAngle) + gap
            let end = (CGFloat(i + 1) * segmentAngle) - gap
            stripePath.addArc(withCenter: center, radius: stripeRadius, startAngle: start, endAngle: end, clockwise: true)
        }
        stripeLayer.path = stripePath.cgPath
        stripeLayer.lineWidth = 6
        stripeLayer.fillColor = UIColor.clear.cgColor
        stripeLayer.lineCap = .round

        let shinePath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX - radius * 0.25, y: bounds.midY - radius * 0.25), radius: radius * 0.65, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        shineLayer.path = shinePath.cgPath
        shineLayer.fillColor = UIColor.white.withAlphaComponent(0.08).cgColor
    }

    private func updateColors() {
        gradientLayer.colors = [baseColor.withAlphaComponent(0.95).cgColor, baseColor.darker(by: 0.2).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)

        ringLayer.strokeColor = accentColor.cgColor
        innerRingLayer.strokeColor = accentColor.withAlphaComponent(0.8).cgColor
        stripeLayer.strokeColor = accentColor.cgColor

        countLabel.textColor = textColor
    }
}

private extension UIColor {
    func darker(by value: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        return UIColor(red: max(r - value, 0), green: max(g - value, 0), blue: max(b - value, 0), alpha: a)
    }
}
