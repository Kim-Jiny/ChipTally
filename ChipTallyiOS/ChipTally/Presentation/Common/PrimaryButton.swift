//
//  PrimaryButton.swift
//  ChipTally
//

import UIKit

final class PrimaryButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    private let ringLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = .clear
        setTitleColor(Theme.Colors.chipCream, for: .normal)
        titleLabel?.font = Theme.Fonts.bodyBold

        layer.insertSublayer(gradientLayer, at: 0)
        layer.addSublayer(ringLayer)

        addShadow(opacity: 0.3, radius: 12, offset: CGSize(width: 0, height: 6))

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.colors = [Theme.Colors.chipRed.cgColor, Theme.Colors.chipRed.darker(by: 0.2).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)

        layer.cornerRadius = bounds.height / 2
        gradientLayer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true

        let ringPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 6, dy: 6), cornerRadius: (bounds.height - 12) / 2)
        ringLayer.path = ringPath.cgPath
        ringLayer.lineWidth = 3
        ringLayer.strokeColor = Theme.Colors.chipCream.withAlphaComponent(0.85).cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
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
