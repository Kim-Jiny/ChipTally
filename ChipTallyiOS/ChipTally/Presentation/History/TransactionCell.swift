//
//  TransactionCell.swift
//  ChipTally
//

import UIKit

final class TransactionCell: UITableViewCell {
    static let identifier = "TransactionCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.cardBackground
        view.roundCorners(Theme.CornerRadius.medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let fromLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let arrowLabel: UILabel = {
        let label = UILabel()
        label.text = "→"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.chipGold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.chipCream
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(fromLabel)
        containerView.addSubview(arrowLabel)
        containerView.addSubview(toLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(timeLabel)

        containerView.addShadow(opacity: 0.2, radius: 10, offset: CGSize(width: 0, height: 5))

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xs),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xs),

            fromLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.Spacing.md),
            fromLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),

            arrowLabel.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor),
            arrowLabel.leadingAnchor.constraint(equalTo: fromLabel.trailingAnchor, constant: Theme.Spacing.sm),

            toLabel.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor),
            toLabel.leadingAnchor.constraint(equalTo: arrowLabel.trailingAnchor, constant: Theme.Spacing.sm),

            amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            timeLabel.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: Theme.Spacing.xs),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.Spacing.md)
        ])
    }

    func configure(fromName: String, toName: String, amount: Int, timestamp: Date) {
        fromLabel.text = fromName
        toLabel.text = toName
        amountLabel.text = "+\(amount)"

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timeLabel.text = formatter.string(from: timestamp)
    }
}
