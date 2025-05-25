//
//  SocketManager.swift
//  ChatAppSocket
//
//  Created by Mehmet Özkan on 23.05.2025.
//

import SocketIO
import Foundation

final class SocketHandler {
    static let shared = SocketHandler()
    
    private let socket = SocketManager(socketURL: URL(string: "http://192.168.1.4:3000")!, config: [.log(true), .compress])
    private var mSocket: SocketIOClient!

    private init() {
        mSocket = socket.defaultSocket
    }

    func getSocket() -> SocketIOClient {
        return mSocket
    }

    func establishConnection() {
        mSocket.connect()
    }

    func closeConnection() {
        mSocket.disconnect()
    }
}
