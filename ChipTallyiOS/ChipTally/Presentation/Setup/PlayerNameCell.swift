//
//  PlayerNameCell.swift
//  ChipTally
//

import UIKit

protocol PlayerNameCellDelegate: AnyObject {
    func playerNameCell(_ cell: PlayerNameCell, didUpdateName name: String, at index: Int)
}

final class PlayerNameCell: UITableViewCell {
    static let identifier = "PlayerNameCell"

    weak var delegate: PlayerNameCellDelegate?
    private var index: Int = 0

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.cardBackground
        view.roundCorners(Theme.CornerRadius.medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let playerLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.chipGold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: RoundedTextField = {
        let textField = RoundedTextField()
        textField.placeholder = L10n.Setup.namePlaceholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        containerView.addSubview(playerLabel)
        containerView.addSubview(nameTextField)

        containerView.addShadow(opacity: 0.2, radius: 10, offset: CGSize(width: 0, height: 5))

        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xs),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xs),

            playerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            playerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            playerLabel.widthAnchor.constraint(equalToConstant: 80),

            nameTextField.leadingAnchor.constraint(equalTo: playerLabel.trailingAnchor, constant: Theme.Spacing.sm),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            nameTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            containerView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }

    func configure(index: Int, name: String) {
        self.index = index
        playerLabel.text = "Player \(index + 1)"
        nameTextField.text = name
    }

    @objc private func textFieldDidChange() {
        delegate?.playerNameCell(self, didUpdateName: nameTextField.text ?? "", at: index)
    }
}
