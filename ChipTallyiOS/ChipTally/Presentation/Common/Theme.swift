//
//  Theme.swift
//  ChipTally
//

import UIKit

enum Theme {
    // MARK: - Colors
    enum Colors {
        static let primary = UIColor(red: 79/255, green: 70/255, blue: 229/255, alpha: 1) // Indigo
        static let primaryLight = UIColor(red: 129/255, green: 140/255, blue: 248/255, alpha: 1)
        static let secondary = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1) // Emerald
        static let background = UIColor.systemBackground
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let cardBackground = UIColor.tertiarySystemBackground
        static let text = UIColor.label
        static let secondaryText = UIColor.secondaryLabel
        static let destructive = UIColor.systemRed
        static let success = UIColor.systemGreen
        static let chipGold = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    // MARK: - Fonts
    enum Fonts {
        static let title = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let headline = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let caption = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let chipCount = UIFont.systemFont(ofSize: 32, weight: .bold)
    }
}

// MARK: - UIView Extensions

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
    }

    func roundCorners(_ radius: CGFloat = Theme.CornerRadius.medium) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
