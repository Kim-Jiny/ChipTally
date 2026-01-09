//
//  PrimaryButton.swift
//  ChipTally
//

import UIKit

final class PrimaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = Theme.Colors.primary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Theme.Fonts.bodyBold
        roundCorners(Theme.CornerRadius.medium)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52)
        ])
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
