//
//  RoundedTextField.swift
//  ChipTally
//

import UIKit

final class RoundedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = Theme.Colors.secondaryBackground
        font = Theme.Fonts.body
        textColor = Theme.Colors.text
        roundCorners(Theme.CornerRadius.medium)
        borderStyle = .none

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
