//
//  GameViewController.swift
//  ChipTally
//

import UIKit

protocol GameViewControllerDelegate: AnyObject {
    func gameViewControllerDidEndGame(_ controller: GameViewController)
}

final class GameViewController: UIViewController {
    weak var delegate: GameViewControllerDelegate?

    private let viewModel: GameViewModel

    // MARK: - UI Components

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Common.appName
        label.font = Theme.Fonts.headline
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let endGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Theme.Spacing.sm
        layout.minimumLineSpacing = Theme.Spacing.sm
        layout.sectionInset = UIEdgeInsets(
            top: Theme.Spacing.md,
            left: Theme.Spacing.md,
            bottom: Theme.Spacing.md,
            right: Theme.Spacing.md
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Theme.Colors.background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let transferButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Theme.Colors.primary
        button.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(session: GameSession) {
        self.viewModel = GameViewModel(session: session)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupActions()
        viewModel.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transferButton.layer.cornerRadius = transferButton.bounds.height / 2
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Theme.Colors.background

        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(historyButton)
        headerView.addSubview(endGameButton)
        view.addSubview(collectionView)
        view.addSubview(transferButton)

        transferButton.addShadow()

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Theme.Spacing.md),

            endGameButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Theme.Spacing.md),
            endGameButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            endGameButton.widthAnchor.constraint(equalToConstant: 44),
            endGameButton.heightAnchor.constraint(equalToConstant: 44),

            historyButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Theme.Spacing.md),
            historyButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: 44),
            historyButton.heightAnchor.constraint(equalToConstant: 44),

            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            transferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transferButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Theme.Spacing.lg),
            transferButton.widthAnchor.constraint(equalToConstant: 64),
            transferButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PlayerChipCell.self, forCellWithReuseIdentifier: PlayerChipCell.identifier)
    }

    private func setupActions() {
        transferButton.addTarget(self, action: #selector(transferTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        endGameButton.addTarget(self, action: #selector(endGameTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func transferTapped() {
        let transferVC = TransferViewController(players: viewModel.players)
        transferVC.delegate = self
        present(transferVC, animated: true)
    }

    @objc private func historyTapped() {
        let historyVC = HistoryViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: historyVC)
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navController, animated: true)
    }

    @objc private func endGameTapped() {
        let alert = UIAlertController(
            title: L10n.Game.endGameTitle,
            message: L10n.Game.endGameMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Game.end, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.resetGame()
            self.delegate?.gameViewControllerDidEndGame(self)
        })
        present(alert, animated: true)
    }

    private func showToast(message: String, isError: Bool = false) {
        let toastView = UIView()
        toastView.backgroundColor = isError ? Theme.Colors.destructive : Theme.Colors.success
        toastView.roundCorners(Theme.CornerRadius.medium)
        toastView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = message
        label.font = Theme.Fonts.body
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        toastView.addSubview(label)
        view.addSubview(toastView)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: Theme.Spacing.sm),
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: Theme.Spacing.md),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -Theme.Spacing.md),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -Theme.Spacing.sm),

            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Theme.Spacing.md)
        ])

        toastView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                toastView.alpha = 0
            } completion: { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.players.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerChipCell.identifier, for: indexPath) as? PlayerChipCell else {
            return UICollectionViewCell()
        }
        cell.configure(player: viewModel.players[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = Theme.Spacing.md * 2 + Theme.Spacing.sm
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 140)
    }
}

// MARK: - TransferViewControllerDelegate

extension GameViewController: TransferViewControllerDelegate {
    func transferViewController(_ controller: TransferViewController, didTransferFrom fromIndex: Int, to toIndex: Int, amount: Int) {
        viewModel.transferChips(fromIndex: fromIndex, toIndex: toIndex, amount: amount)
    }
}

// MARK: - GameViewModelDelegate

extension GameViewController: GameViewModelDelegate {
    func didUpdateSession() {
        collectionView.reloadData()
    }

    func didTransferChips(transaction: Transaction) {
        let fromName = viewModel.getPlayerName(for: transaction.fromPlayerId)
        let toName = viewModel.getPlayerName(for: transaction.toPlayerId)
        showToast(message: "\(fromName) → \(toName): \(transaction.amount)개")
    }

    func didFailTransfer(error: TransferError) {
        showToast(message: error.localizedDescription, isError: true)
    }
}
