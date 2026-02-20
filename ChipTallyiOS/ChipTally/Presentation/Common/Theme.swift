//
//  Theme.swift
//  ChipTally
//

import UIKit

enum Theme {
    // MARK: - Colors
    enum Colors {
        // Table + rail
        static let tableFelt = UIColor(red: 12/255, green: 64/255, blue: 46/255, alpha: 1)
        static let tableFeltDark = UIColor(red: 8/255, green: 46/255, blue: 34/255, alpha: 1)
        static let rail = UIColor(red: 63/255, green: 40/255, blue: 28/255, alpha: 1)
        static let railHighlight = UIColor(red: 92/255, green: 62/255, blue: 44/255, alpha: 1)

        // Chips
        static let chipRed = UIColor(red: 196/255, green: 45/255, blue: 52/255, alpha: 1)
        static let chipBlue = UIColor(red: 38/255, green: 102/255, blue: 170/255, alpha: 1)
        static let chipBlack = UIColor(red: 26/255, green: 26/255, blue: 28/255, alpha: 1)
        static let chipWhite = UIColor(red: 236/255, green: 231/255, blue: 220/255, alpha: 1)
        static let chipGold = UIColor(red: 216/255, green: 170/255, blue: 74/255, alpha: 1)
        static let chipCream = UIColor(red: 244/255, green: 237/255, blue: 222/255, alpha: 1)

        // Surface
        static let panel = UIColor(red: 19/255, green: 79/255, blue: 57/255, alpha: 1)
        static let inset = UIColor(red: 11/255, green: 54/255, blue: 39/255, alpha: 1)
        static let cardBackground = UIColor(red: 16/255, green: 70/255, blue: 51/255, alpha: 1)

        // Text
        static let text = UIColor(red: 248/255, green: 246/255, blue: 241/255, alpha: 1)
        static let secondaryText = UIColor(red: 197/255, green: 196/255, blue: 192/255, alpha: 1)
        static let textDark = UIColor(red: 24/255, green: 20/255, blue: 18/255, alpha: 1)

        static let destructive = UIColor(red: 214/255, green: 59/255, blue: 57/255, alpha: 1)
        static let success = UIColor(red: 52/255, green: 168/255, blue: 97/255, alpha: 1)

        // Legacy map
        static let primary = chipRed
        static let primaryLight = UIColor(red: 230/255, green: 94/255, blue: 98/255, alpha: 1)
        static let secondary = chipBlue
        static let background = tableFelt
        static let secondaryBackground = panel

        static let chipPalette: [UIColor] = [chipRed, chipBlue, chipBlack, chipWhite, chipGold]
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
        private static func preferredFont(named name: String, size: CGFloat, weight: UIFont.Weight) -> UIFont {
            if let font = UIFont(name: name, size: size) {
                return font
            }
            return UIFont.systemFont(ofSize: size, weight: weight)
        }

        static let title = preferredFont(named: "AvenirNext-Heavy", size: 30, weight: .heavy)
        static let headline = preferredFont(named: "AvenirNext-DemiBold", size: 20, weight: .semibold)
        static let body = preferredFont(named: "AvenirNext-Regular", size: 16, weight: .regular)
        static let bodyBold = preferredFont(named: "AvenirNext-DemiBold", size: 16, weight: .semibold)
        static let caption = preferredFont(named: "AvenirNext-Regular", size: 14, weight: .regular)
        static let chipCount = preferredFont(named: "AvenirNext-Heavy", size: 32, weight: .bold)
    }
}

// MARK: - UIView Extensions

extension UIView {
    func addShadow(color: UIColor = UIColor.black, opacity: Float = 0.25, radius: CGFloat = 10, offset: CGSize = CGSize(width: 0, height: 6)) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }

    func roundCorners(_ radius: CGFloat = Theme.CornerRadius.medium) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}

extension Theme.Colors {
    static func chipColor(for index: Int) -> UIColor {
        let palette = chipPalette
        guard !palette.isEmpty else { return chipRed }
        let safeIndex = abs(index)
        return palette[safeIndex % palette.count]
    }
}
