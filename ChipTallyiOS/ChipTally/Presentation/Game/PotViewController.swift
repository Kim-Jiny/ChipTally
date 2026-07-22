//
//  PotViewController.swift
//  ChipTally
//

import UIKit

protocol PotViewControllerDelegate: AnyObject {
    func potViewController(_ controller: PotViewController, didBet playerIndex: Int, amount: Int)
    func potViewController(_ controller: PotViewController, didTakePot winnerIndex: Int)
}

/// 팟에 칩을 걸거나, 팟 전액을 한 명에게 넘기는 화면.
/// `TransferViewController` 와 같은 반투명 오버레이라 조작 방식이 일관된다.
final class PotViewController: UIViewController {
    weak var delegate: PotViewControllerDelegate?

    private static let quickAmounts = [10, 25, 50]

    private let players: [Player]
    private let roundBets: [Int]
    private let pot: Int
    private var selectedIndex: Int = 0
    private var containerCenterYConstraint: NSLayoutConstraint?

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.panel
        view.roundCorners(Theme.CornerRadius.extraLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Pot.title
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = Theme.Colors.chipCream
        button.backgroundColor = Theme.Colors.railHighlight
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let potAmountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.chipCount
        label.textColor = Theme.Colors.chipGold
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playerLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Pot.betPlayer
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playerPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let holdingLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let roundBetLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Pot.amount
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let amountTextField: RoundedTextField = {
        let textField = RoundedTextField()
        textField.placeholder = L10n.Transfer.amountPlaceholder
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var quickButtons: [OutlineButton] = {
        var buttons = Self.quickAmounts.map { amount in
            OutlineButton(title: String(format: L10n.Transfer.quickAmountFormat, amount))
        }
        buttons.append(OutlineButton(title: L10n.Transfer.allIn))
        return buttons
    }()

    private lazy var quickStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: quickButtons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Theme.Spacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let betButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(L10n.Pot.placeBet, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.railHighlight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var takePotButton = OutlineButton(
        title: L10n.Pot.takePot,
        titleColor: Theme.Colors.chipCream
    )

    // MARK: - Init

    init(players: [Player], roundBets: [Int], pot: Int) {
        self.players = players
        self.roundBets = roundBets
        self.pot = pot
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        playerPicker.delegate = self
        playerPicker.dataSource = self
        setupKeyboardObservers()

        potAmountLabel.text = "\(pot)"
        updatePlayerInfo()
        validateForm()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)

        view.addSubview(containerView)
        [titleLabel, closeButton, potAmountLabel, playerLabel, playerPicker,
         holdingLabel, roundBetLabel, amountLabel, amountTextField,
         quickStack, betButton, separatorView, takePotButton].forEach(containerView.addSubview)

        containerView.addShadow(opacity: 0.35, radius: 16, offset: CGSize(width: 0, height: 10))

        containerCenterYConstraint = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        NSLayoutConstraint.activate([
            containerCenterYConstraint!,
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Spacing.lg),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Spacing.lg),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.Spacing.lg),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Theme.Spacing.md),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            potAmountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.sm),
            potAmountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            potAmountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            playerLabel.topAnchor.constraint(equalTo: potAmountLabel.bottomAnchor, constant: Theme.Spacing.md),
            playerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),

            playerPicker.topAnchor.constraint(equalTo: playerLabel.bottomAnchor),
            playerPicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            playerPicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            playerPicker.heightAnchor.constraint(equalToConstant: 110),

            holdingLabel.topAnchor.constraint(equalTo: playerPicker.bottomAnchor, constant: Theme.Spacing.xs),
            holdingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),

            roundBetLabel.centerYAnchor.constraint(equalTo: holdingLabel.centerYAnchor),
            roundBetLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            amountLabel.topAnchor.constraint(equalTo: holdingLabel.bottomAnchor, constant: Theme.Spacing.md),
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),

            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: Theme.Spacing.sm),
            amountTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            amountTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            quickStack.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: Theme.Spacing.sm),
            quickStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            quickStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            quickStack.heightAnchor.constraint(equalToConstant: 44),

            betButton.topAnchor.constraint(equalTo: quickStack.bottomAnchor, constant: Theme.Spacing.md),
            betButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            betButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            separatorView.topAnchor.constraint(equalTo: betButton.bottomAnchor, constant: Theme.Spacing.lg),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            takePotButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Theme.Spacing.lg),
            takePotButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            takePotButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            takePotButton.heightAnchor.constraint(equalToConstant: 52),
            takePotButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.Spacing.lg)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        betButton.addTarget(self, action: #selector(betTapped), for: .touchUpInside)
        takePotButton.addTarget(self, action: #selector(takePotTapped), for: .touchUpInside)
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)

        for (index, button) in quickButtons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(quickTapped(_:)), for: .touchUpInside)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func backgroundTapped() {
        view.endEditing(true)
    }

    @objc private func amountChanged() {
        validateForm()
    }

    @objc private func quickTapped(_ sender: OutlineButton) {
        if sender.tag < Self.quickAmounts.count {
            addAmount(Self.quickAmounts[sender.tag])
        } else {
            fillAmount(availableChips)   // 올인
        }
    }

    @objc private func betTapped() {
        guard let amount = Int(amountTextField.text ?? ""), amount > 0 else { return }
        delegate?.potViewController(self, didBet: selectedIndex, amount: amount)
        dismiss(animated: true)
    }

    @objc private func takePotTapped() {
        guard players.indices.contains(selectedIndex) else { return }
        let winner = players[selectedIndex]

        let alert = UIAlertController(
            title: L10n.Pot.takePot,
            message: String(format: L10n.Pot.takePotMessageFormat, winner.name, pot),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Pot.takePot, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.potViewController(self, didTakePot: self.selectedIndex)
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        UIView.animate(withDuration: duration) {
            self.containerCenterYConstraint?.constant = -frame.height / 2
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        UIView.animate(withDuration: duration) {
            self.containerCenterYConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Helpers

private extension PotViewController {
    var availableChips: Int {
        players.indices.contains(selectedIndex) ? players[selectedIndex].chipCount : 0
    }

    var currentRoundBet: Int {
        roundBets.indices.contains(selectedIndex) ? roundBets[selectedIndex] : 0
    }

    func fillAmount(_ value: Int) {
        amountTextField.text = "\(min(max(value, 0), availableChips))"
        validateForm()
    }

    func addAmount(_ delta: Int) {
        fillAmount((Int(amountTextField.text ?? "") ?? 0) + delta)
    }

    func updatePlayerInfo() {
        holdingLabel.text = String(format: L10n.Pot.holdingChipsFormat, availableChips)
        roundBetLabel.text = String(format: L10n.Pot.roundBetFormat, currentRoundBet)
    }

    func validateForm() {
        let amount = Int(amountTextField.text ?? "") ?? 0
        let available = availableChips

        betButton.isEnabled = amount > 0 && amount <= available
        quickButtons.forEach { $0.isEnabled = available > 0 }
        takePotButton.isEnabled = pot > 0
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension PotViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        players.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.text
        label.text = players[row].name
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        updatePlayerInfo()
        validateForm()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PotViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view == view
    }
}
