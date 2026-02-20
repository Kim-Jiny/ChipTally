//
//  RoundedTextField.swift
//  ChipTally
//

import UIKit

final class RoundedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = Theme.Colors.inset
        font = Theme.Fonts.body
        textColor = Theme.Colors.text
        roundCorners(Theme.CornerRadius.medium)
        borderStyle = .none
        layer.borderWidth = 1
        layer.borderColor = Theme.Colors.railHighlight.withAlphaComponent(0.5).cgColor

        updatePlaceholder()

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updatePlaceholder() {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: Theme.Colors.secondaryText]
        )
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
