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

    private let chipIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = Theme.Colors.chipGold
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let chipCountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.chipCount
        label.textColor = Theme.Colors.primary
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
        containerView.addSubview(chipIconView)
        containerView.addSubview(chipCountLabel)

        containerView.addShadow()

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xs),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.xs),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.xs),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xs),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.Spacing.md),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.sm),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.sm),

            chipIconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            chipIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chipIconView.widthAnchor.constraint(equalToConstant: 24),
            chipIconView.heightAnchor.constraint(equalToConstant: 24),

            chipCountLabel.topAnchor.constraint(equalTo: chipIconView.bottomAnchor, constant: Theme.Spacing.sm),
            chipCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.sm),
            chipCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.sm)
        ])
    }

    func configure(player: Player) {
        nameLabel.text = player.name
        chipCountLabel.text = "\(player.chipCount)"
    }
}
