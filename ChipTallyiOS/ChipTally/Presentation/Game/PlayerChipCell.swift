//
//  PlayerChipCell.swift
//  ChipTally
//

import UIKit

final class PlayerChipCell: UICollectionViewCell {
    static let identifier = "PlayerChipCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.cardBackground
        view.roundCorners(Theme.CornerRadius.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chipShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.tableFeltDark
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 36
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()

    private let chipTokenView: ChipTokenView = {
        let view = ChipTokenView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let chipCountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.chipCream
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(chipShadowView)
        containerView.addSubview(chipTokenView)
        containerView.addSubview(chipCountLabel)

        containerView.addShadow(opacity: 0.25, radius: 12, offset: CGSize(width: 0, height: 6))

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xs),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.xs),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.xs),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xs),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.Spacing.md),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.sm),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.sm),

            chipShadowView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -10),
            chipShadowView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 8),
            chipShadowView.widthAnchor.constraint(equalToConstant: 72),
            chipShadowView.heightAnchor.constraint(equalToConstant: 72),

            chipTokenView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 6),
            chipTokenView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 4),
            chipTokenView.widthAnchor.constraint(equalToConstant: 80),
            chipTokenView.heightAnchor.constraint(equalToConstant: 80),

            chipCountLabel.topAnchor.constraint(equalTo: chipTokenView.bottomAnchor, constant: Theme.Spacing.xs),
            chipCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.sm),
            chipCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.sm)
        ])
    }

    func configure(player: Player) {
        nameLabel.text = player.name
        let color = Theme.Colors.chipColor(for: abs(player.id.hashValue))
        let isLightChip = (color == Theme.Colors.chipWhite || color == Theme.Colors.chipGold)
        let accent: UIColor = isLightChip ? Theme.Colors.rail : Theme.Colors.chipCream
        let textColor: UIColor = Theme.Colors.chipCream
        chipTokenView.baseColor = color
        chipTokenView.accentColor = accent
        chipTokenView.text = nil
        chipCountLabel.text = "\(player.chipCount)"
        chipCountLabel.textColor = textColor
        chipShadowView.backgroundColor = color.darker(by: 0.35)
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
