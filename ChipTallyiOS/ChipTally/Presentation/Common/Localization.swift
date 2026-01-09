//
//  Localization.swift
//  ChipTally
//

import Foundation

// MARK: - String Extension for Localization

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

// MARK: - Localization Keys

enum L10n {
    // MARK: - Common
    enum Common {
        static let appName = "app.name".localized
        static let cancel = "common.cancel".localized
        static let confirm = "common.confirm".localized
        static let reset = "common.reset".localized
        static let close = "common.close".localized
    }

    // MARK: - Setup Screen
    enum Setup {
        static let subtitle = "setup.subtitle".localized
        static let playerCount = "setup.playerCount".localized
        static let initialChips = "setup.initialChips".localized
        static let playerNames = "setup.playerNames".localized
        static let namePlaceholder = "setup.namePlaceholder".localized
        static let startGame = "setup.startGame".localized
        static let resetTitle = "setup.resetTitle".localized
        static let resetMessage = "setup.resetMessage".localized
    }

    // MARK: - Game Screen
    enum Game {
        static let endGame = "game.endGame".localized
        static let endGameTitle = "game.endGameTitle".localized
        static let endGameMessage = "game.endGameMessage".localized
        static let end = "game.end".localized
    }

    // MARK: - Transfer Screen
    enum Transfer {
        static let title = "transfer.title".localized
        static let from = "transfer.from".localized
        static let to = "transfer.to".localized
        static let amount = "transfer.amount".localized
        static let amountPlaceholder = "transfer.amountPlaceholder".localized
        static let submit = "transfer.submit".localized
        static let invalidAmount = "transfer.invalidAmount".localized
        static let samePlayer = "transfer.samePlayer".localized
    }

    // MARK: - History Screen
    enum History {
        static let title = "history.title".localized
        static let empty = "history.empty".localized
    }

    // MARK: - Errors
    enum Error {
        static let insufficientChips = "error.insufficientChips".localized
        static let invalidPlayer = "error.invalidPlayer".localized
        static let samePlayer = "error.samePlayer".localized
        static let invalidAmount = "error.invalidAmount".localized
    }
}
