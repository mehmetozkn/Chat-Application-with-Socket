//
//  ChatViewModel.swift
//  ChatAppSocket
//
//  Created by Mehmet Özkan on 24.05.2025.
//

import Foundation

final class ChatViewModel {
    private let socket = SocketHandler.shared.getSocket()
    private(set) var messages: [Message] = []

    var onMessagesUpdated: (() -> Void)?
    var currentUserId: String = UUID().uuidString

    init() {
        setupSocketEvents()
        SocketHandler.shared.establishConnection()
    }

    private func setupSocketEvents() {
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
        }

        socket.on("receiveMessage") { [weak self] dataArray, ack in
            guard let self = self else { return }
            if let dict = dataArray[0] as? [String: Any],
               let userId = dict["userId"] as? String,
               let message = dict["message"] as? String {

                if userId != self.currentUserId {
                    let newMessage = Message(userId: userId, text: message)
                    self.messages.append(newMessage)
                    DispatchQueue.main.async {
                        self.onMessagesUpdated?()
                    }
                }
            }
        }
    }

    func sendMessage(_ text: String) {
        let messageData = ["userId": currentUserId, "message": text]
        socket.emit("sendMessage", messageData)

        let localMessage = Message(userId: currentUserId, text: text)
        messages.append(localMessage)
        onMessagesUpdated?()
    }
}
