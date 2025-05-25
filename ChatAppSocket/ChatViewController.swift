//
//  ChatViewController.swift
//  ChatAppSocket
//
//  Created by Mehmet Özkan on 23.05.2025.
//

import UIKit

final class ChatViewController: UIViewController {
    private let viewModel = ChatViewModel()
    private let tableView = UITableView()
    private let messageInputContainer = UIView()
    private let inputTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputComponents()
        bindViewModel()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bindViewModel() {
        viewModel.onMessagesUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }

    private func scrollToBottom() {
        if viewModel.messages.count > 0 {
            let indexPath = IndexPath(row: viewModel.messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - TextField Operations

extension ChatViewController: UITextFieldDelegate {
    private func setupInputComponents() {
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.backgroundColor = UIColor(white: 0.95, alpha: 1)

        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "Enter message..."
        inputTextField.delegate = self
        inputTextField.backgroundColor = .white
        inputTextField.layer.cornerRadius = 18
        inputTextField.clipsToBounds = true
        inputTextField.font = .systemFont(ofSize: 16)

        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        inputTextField.leftView = leftPaddingView
        inputTextField.leftViewMode = .always

        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        inputTextField.rightView = rightPaddingView
        inputTextField.rightViewMode = .always

        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)

        view.addSubview(messageInputContainer)
        messageInputContainer.addSubview(inputTextField)
        messageInputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            messageInputContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            messageInputContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 50),
            messageInputContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),

            inputTextField.leftAnchor.constraint(equalTo: messageInputContainer.leftAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8),
            inputTextField.heightAnchor.constraint(equalToConstant: 36),

            sendButton.rightAnchor.constraint(equalTo: messageInputContainer.rightAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func handleSend() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        viewModel.sendMessage(text)
        inputTextField.text = ""
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func handleKeyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.messageInputContainer.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 50, right: 0)
            self.scrollToBottom()
        }
    }

    @objc private func handleKeyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.messageInputContainer.transform = .identity
            self.tableView.contentInset = .zero
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

// MARK: - TableView Operations

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "cellId")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        let isCurrentUser = message.userId == viewModel.currentUserId
        cell.configure(with: message.text, isIncoming: !isCurrentUser)
        return cell
    }
}
