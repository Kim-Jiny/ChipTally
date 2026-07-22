//
//  OutlineButton.swift
//  ChipTally
//

import UIKit

/// 빠른 금액·팟 가져가기처럼 주 액션 옆에 놓이는 보조 버튼.
/// Android 의 `bg_button_outline` 과 같은 모양(투명 배경 + 레일 색 테두리)이다.
final class OutlineButton: UIButton {

    init(title: String? = nil, titleColor: UIColor = Theme.Colors.chipGold) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStyle() {
        backgroundColor = .clear
        titleLabel?.font = Theme.Fonts.bodyBold
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.7
        layer.borderWidth = 2
        layer.borderColor = Theme.Colors.railHighlight.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1.0 : 0.4 }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }
}
