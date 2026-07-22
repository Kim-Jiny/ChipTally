//
//  TransferViewController.swift
//  ChipTally
//

import UIKit

protocol TransferViewControllerDelegate: AnyObject {
    func transferViewController(_ controller: TransferViewController, didTransferFrom fromIndex: Int, to toIndex: Int, amount: Int)
}

final class TransferViewController: UIViewController {
    weak var delegate: TransferViewControllerDelegate?

    private let players: [Player]
    private static let quickAmounts = [10, 25, 50]

    private var fromIndex: Int
    private var toIndex: Int
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
        label.text = L10n.Transfer.title
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

    private let fromLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Transfer.from
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fromPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    /// 보내는/받는 사람 맞바꾸기. 예전엔 장식용 화살표였다.
    private let swapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left.arrow.right.circle.fill"), for: .normal)
        button.tintColor = Theme.Colors.chipGold
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Transfer.to
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Transfer.amount
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fromChipsLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toChipsLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let maxTransferLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.chipGold
        label.textAlignment = .center
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

    private let transferButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(L10n.Transfer.submit, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(players: [Player], fromIndex: Int = 0) {
        self.players = players
        self.fromIndex = players.indices.contains(fromIndex) ? fromIndex : 0
        // 보내는 사람과 겹치지 않게 받는 사람을 고른다.
        self.toIndex = self.fromIndex == 0 ? min(1, players.count - 1) : 0
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
        setupPickers()
        setupKeyboardObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)

        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(fromLabel)
        containerView.addSubview(fromPicker)
        containerView.addSubview(swapButton)
        containerView.addSubview(toLabel)
        containerView.addSubview(toPicker)
        containerView.addSubview(amountLabel)
        containerView.addSubview(fromChipsLabel)
        containerView.addSubview(toChipsLabel)
        containerView.addSubview(maxTransferLabel)
        containerView.addSubview(amountTextField)
        containerView.addSubview(quickStack)
        containerView.addSubview(transferButton)

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

            fromLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.lg),
            fromLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),

            fromPicker.topAnchor.constraint(equalTo: fromLabel.bottomAnchor),
            fromPicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            fromPicker.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.4),
            fromPicker.heightAnchor.constraint(equalToConstant: 120),

            swapButton.centerYAnchor.constraint(equalTo: fromPicker.centerYAnchor),
            swapButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            swapButton.widthAnchor.constraint(equalToConstant: 40),
            swapButton.heightAnchor.constraint(equalToConstant: 40),

            toLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.lg),
            toLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            toPicker.topAnchor.constraint(equalTo: toLabel.bottomAnchor),
            toPicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toPicker.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.4),
            toPicker.heightAnchor.constraint(equalToConstant: 120),

            fromChipsLabel.topAnchor.constraint(equalTo: fromPicker.bottomAnchor, constant: Theme.Spacing.xs),
            fromChipsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            fromChipsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45),

            toChipsLabel.topAnchor.constraint(equalTo: toPicker.bottomAnchor, constant: Theme.Spacing.xs),
            toChipsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            toChipsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45),

            maxTransferLabel.topAnchor.constraint(equalTo: fromChipsLabel.bottomAnchor, constant: Theme.Spacing.sm),
            maxTransferLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            maxTransferLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            amountLabel.topAnchor.constraint(equalTo: maxTransferLabel.bottomAnchor, constant: Theme.Spacing.md),
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),

            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: Theme.Spacing.sm),
            amountTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            amountTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),

            quickStack.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: Theme.Spacing.sm),
            quickStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            quickStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            quickStack.heightAnchor.constraint(equalToConstant: 44),

            transferButton.topAnchor.constraint(equalTo: quickStack.bottomAnchor, constant: Theme.Spacing.md),
            transferButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Theme.Spacing.md),
            transferButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Theme.Spacing.md),
            transferButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Theme.Spacing.lg)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        transferButton.addTarget(self, action: #selector(transferTapped), for: .touchUpInside)
        swapButton.addTarget(self, action: #selector(swapTapped), for: .touchUpInside)
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)

        for (index, button) in quickButtons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(quickTapped(_:)), for: .touchUpInside)
        }

        // '최대 전송 가능' 을 눌러 전액을 채울 수 있게 한다.
        maxTransferLabel.isUserInteractionEnabled = true
        maxTransferLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(maxTapped))
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    private func setupPickers() {
        fromPicker.delegate = self
        fromPicker.dataSource = self
        toPicker.delegate = self
        toPicker.dataSource = self

        fromPicker.selectRow(fromIndex, inComponent: 0, animated: false)
        toPicker.selectRow(toIndex, inComponent: 0, animated: false)
        updateChipInfo()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let offset = -keyboardHeight / 2

        UIView.animate(withDuration: duration) {
            self.containerCenterYConstraint?.constant = offset
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

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func swapTapped() {
        let newFrom = toIndex, newTo = fromIndex
        fromIndex = newFrom
        toIndex = newTo
        fromPicker.selectRow(newFrom, inComponent: 0, animated: true)
        toPicker.selectRow(newTo, inComponent: 0, animated: true)
        updateChipInfo()
    }

    @objc private func amountChanged() {
        updateChipInfo()
    }

    @objc private func maxTapped() {
        guard players.indices.contains(fromIndex) else { return }
        fillAmount(players[fromIndex].chipCount)
    }

    @objc private func quickTapped(_ sender: OutlineButton) {
        guard players.indices.contains(fromIndex) else { return }
        if sender.tag < Self.quickAmounts.count {
            fillAmount((Int(amountTextField.text ?? "") ?? 0) + Self.quickAmounts[sender.tag])
        } else {
            fillAmount(players[fromIndex].chipCount)   // 올인
        }
    }

    @objc private func backgroundTapped() {
        view.endEditing(true)
    }

    @objc private func transferTapped() {
        guard players.indices.contains(fromIndex), players.indices.contains(toIndex) else {
            showAlert(message: L10n.Transfer.invalidAmount)
            return
        }

        guard let amountText = amountTextField.text,
              let amount = Int(amountText),
              amount > 0 else {
            showAlert(message: L10n.Transfer.invalidAmount)
            return
        }

        guard fromIndex != toIndex else {
            showAlert(message: L10n.Transfer.samePlayer)
            return
        }

        delegate?.transferViewController(self, didTransferFrom: fromIndex, to: toIndex, amount: amount)
        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.confirm, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension TransferViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return players.count
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
        if pickerView == fromPicker {
            fromIndex = row
        } else {
            toIndex = row
        }
        updateChipInfo()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension TransferViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}

private extension TransferViewController {
    func fillAmount(_ value: Int) {
        guard players.indices.contains(fromIndex) else { return }
        amountTextField.text = "\(min(max(value, 0), players[fromIndex].chipCount))"
        updateChipInfo()
    }

    func updateChipInfo() {
        guard players.indices.contains(fromIndex), players.indices.contains(toIndex) else {
            fromChipsLabel.text = String(format: L10n.Transfer.fromChipsFormat, 0)
            toChipsLabel.text = String(format: L10n.Transfer.toChipsFormat, 0)
            maxTransferLabel.text = String(format: L10n.Transfer.maxTransferFormat, 0)
            return
        }
        let fromChips = players[fromIndex].chipCount
        let toChips = players[toIndex].chipCount

        fromChipsLabel.text = String(format: L10n.Transfer.fromChipsFormat, fromChips)
        toChipsLabel.text = String(format: L10n.Transfer.toChipsFormat, toChips)

        // 전송을 눌러봐야 알던 걸 입력 중에 바로 보여준다.
        let amount = Int(amountTextField.text ?? "") ?? 0
        let samePlayer = fromIndex == toIndex

        if samePlayer {
            maxTransferLabel.text = L10n.Error.samePlayer
            maxTransferLabel.textColor = Theme.Colors.destructive
        } else if amount > fromChips {
            maxTransferLabel.text = L10n.Error.insufficientChips
            maxTransferLabel.textColor = Theme.Colors.destructive
        } else {
            maxTransferLabel.text = String(format: L10n.Transfer.maxTransferFormat, fromChips)
            maxTransferLabel.textColor = Theme.Colors.chipGold
        }

        transferButton.isEnabled = !samePlayer && amount > 0 && amount <= fromChips
        quickButtons.forEach { $0.isEnabled = !samePlayer && fromChips > 0 }
    }
}
