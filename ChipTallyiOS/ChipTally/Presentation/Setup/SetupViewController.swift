//
//  SetupViewController.swift
//  ChipTally
//

import UIKit

protocol SetupViewControllerDelegate: AnyObject {
    func setupViewController(_ controller: SetupViewController, didStartGameWith session: GameSession)
}

final class SetupViewController: UIViewController {
    weak var delegate: SetupViewControllerDelegate?

    private let viewModel: SetupViewModel

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Common.appName
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Setup.subtitle
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playerCountSection: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.cardBackground
        view.roundCorners(Theme.CornerRadius.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let playerCountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Setup.playerCount
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playerCountLabel: UILabel = {
        let label = UILabel()
        label.text = "2"
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let decrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.tintColor = Theme.Colors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = Theme.Colors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let chipCountSection: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.cardBackground
        view.roundCorners(Theme.CornerRadius.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let chipCountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Setup.initialChips
        label.font = Theme.Fonts.bodyBold
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chipCountTextField: RoundedTextField = {
        let textField = RoundedTextField()
        textField.text = "100"
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let playerNamesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Setup.playerNames
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Common.reset, for: .normal)
        button.setTitleColor(Theme.Colors.secondaryText, for: .normal)
        button.titleLabel?.font = Theme.Fonts.caption
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var tableViewHeightConstraint: NSLayoutConstraint?

    private let startButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(L10n.Setup.startGame, for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(viewModel: SetupViewModel = SetupViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        setupKeyboardObservers()
        viewModel.delegate = self
        viewModel.loadSavedSettings()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Theme.Colors.background

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(resetButton)
        contentView.addSubview(playerCountSection)
        contentView.addSubview(chipCountSection)
        contentView.addSubview(playerNamesTitleLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(startButton)

        playerCountSection.addSubview(playerCountTitleLabel)
        playerCountSection.addSubview(decrementButton)
        playerCountSection.addSubview(playerCountLabel)
        playerCountSection.addSubview(incrementButton)

        chipCountSection.addSubview(chipCountTitleLabel)
        chipCountSection.addSubview(chipCountTextField)

        let tableHeight = CGFloat(viewModel.playerCount) * 80
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableHeight)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.xl),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.xs),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            resetButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),

            playerCountSection.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Theme.Spacing.xl),
            playerCountSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            playerCountSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),
            playerCountSection.heightAnchor.constraint(equalToConstant: 72),

            playerCountTitleLabel.leadingAnchor.constraint(equalTo: playerCountSection.leadingAnchor, constant: Theme.Spacing.md),
            playerCountTitleLabel.centerYAnchor.constraint(equalTo: playerCountSection.centerYAnchor),

            incrementButton.trailingAnchor.constraint(equalTo: playerCountSection.trailingAnchor, constant: -Theme.Spacing.md),
            incrementButton.centerYAnchor.constraint(equalTo: playerCountSection.centerYAnchor),
            incrementButton.widthAnchor.constraint(equalToConstant: 44),
            incrementButton.heightAnchor.constraint(equalToConstant: 44),

            playerCountLabel.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -Theme.Spacing.sm),
            playerCountLabel.centerYAnchor.constraint(equalTo: playerCountSection.centerYAnchor),
            playerCountLabel.widthAnchor.constraint(equalToConstant: 40),

            decrementButton.trailingAnchor.constraint(equalTo: playerCountLabel.leadingAnchor, constant: -Theme.Spacing.sm),
            decrementButton.centerYAnchor.constraint(equalTo: playerCountSection.centerYAnchor),
            decrementButton.widthAnchor.constraint(equalToConstant: 44),
            decrementButton.heightAnchor.constraint(equalToConstant: 44),

            chipCountSection.topAnchor.constraint(equalTo: playerCountSection.bottomAnchor, constant: Theme.Spacing.md),
            chipCountSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            chipCountSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),
            chipCountSection.heightAnchor.constraint(equalToConstant: 72),

            chipCountTitleLabel.leadingAnchor.constraint(equalTo: chipCountSection.leadingAnchor, constant: Theme.Spacing.md),
            chipCountTitleLabel.centerYAnchor.constraint(equalTo: chipCountSection.centerYAnchor),

            chipCountTextField.trailingAnchor.constraint(equalTo: chipCountSection.trailingAnchor, constant: -Theme.Spacing.md),
            chipCountTextField.centerYAnchor.constraint(equalTo: chipCountSection.centerYAnchor),
            chipCountTextField.widthAnchor.constraint(equalToConstant: 100),

            playerNamesTitleLabel.topAnchor.constraint(equalTo: chipCountSection.bottomAnchor, constant: Theme.Spacing.lg),
            playerNamesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),

            tableView.topAnchor.constraint(equalTo: playerNamesTitleLabel.bottomAnchor, constant: Theme.Spacing.sm),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),
            tableViewHeightConstraint!,

            startButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: Theme.Spacing.xl),
            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),
            startButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xl)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlayerNameCell.self, forCellReuseIdentifier: PlayerNameCell.identifier)
    }

    private func setupActions() {
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        chipCountTextField.addTarget(self, action: #selector(chipCountChanged), for: .editingChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)

        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
        }
    }

    @objc private func decrementTapped() {
        viewModel.decrementPlayerCount()
    }

    @objc private func incrementTapped() {
        viewModel.incrementPlayerCount()
    }

    @objc private func startTapped() {
        let session = viewModel.createGameSession()
        delegate?.setupViewController(self, didStartGameWith: session)
    }

    @objc private func chipCountChanged() {
        let count = Int(chipCountTextField.text ?? "0") ?? 0
        viewModel.updateInitialChipCount(count)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func resetTapped() {
        let alert = UIAlertController(
            title: L10n.Setup.resetTitle,
            message: L10n.Setup.resetMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Common.reset, style: .destructive) { [weak self] _ in
            self?.viewModel.resetToDefaults()
        })
        present(alert, animated: true)
    }

    private func updateTableViewHeight() {
        tableViewHeightConstraint?.constant = CGFloat(viewModel.playerCount) * 80
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension SetupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playerCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerNameCell.identifier, for: indexPath) as? PlayerNameCell else {
            return UITableViewCell()
        }
        cell.configure(index: indexPath.row, name: viewModel.playerNames[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - PlayerNameCellDelegate

extension SetupViewController: PlayerNameCellDelegate {
    func playerNameCell(_ cell: PlayerNameCell, didUpdateName name: String, at index: Int) {
        viewModel.updatePlayerName(at: index, name: name)
    }
}

// MARK: - SetupViewModelDelegate

extension SetupViewController: SetupViewModelDelegate {
    func didUpdatePlayerCount(_ count: Int) {
        playerCountLabel.text = "\(count)"
        tableView.reloadData()
        updateTableViewHeight()
    }

    func didValidateForm(_ isValid: Bool) {
        startButton.isEnabled = isValid
    }

    func didLoadSavedSettings() {
        playerCountLabel.text = "\(viewModel.playerCount)"
        chipCountTextField.text = "\(viewModel.initialChipCount)"
        tableView.reloadData()
        updateTableViewHeight()
    }
}
