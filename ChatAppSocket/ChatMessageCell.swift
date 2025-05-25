//
//  ChatMessageCell.swift
//  ChatAppSocket
//
//  Created by Mehmet Özkan on 23.05.2025.
//

import UIKit

final class ChatMessageCell: UITableViewCell {

    private let bubbleBackgroundView = UIView()
    private let messageLabel = UILabel()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bubbleBackgroundView.layer.cornerRadius = 15
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleBackgroundView)

        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)

        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -12),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -12),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 12),
        ]
        NSLayoutConstraint.activate(constraints)

        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: String, isIncoming: Bool) {
        messageLabel.text = message
        bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : UIColor.systemBlue
        messageLabel.textColor = isIncoming ? .black : .white

        if isIncoming {
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
        } else {
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
}
