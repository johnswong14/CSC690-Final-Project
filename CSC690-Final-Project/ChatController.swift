//
//  ChatController.swift
//  CSC690-Final-Project
//
//  Created by Johnson Wong on 12/1/19.
//  Copyright © 2019 Johnson Wong. All rights reserved.
//

import Combine
import SwiftUI

// ChatController needs to be a ObservableObject in order to be accessible by SwiftUI
class ChatController: ObservableObject {
    // didChange will let the SwiftUI know that some changes have happened in this object and we need to rebuild all the views related to that object
    var didChange = PassthroughSubject<Void, Never>()
    
    // We've relocated the messages from the main SwiftUI View.
    // It has to be @Published in order for the new updated values to be accessible from the ContentView Controller
    @Published var messages = [
        ChatMessage(message: "Hello, world!", avatar: "A", color: .gray),
        ChatMessage(message: "Anyone there?", avatar: "A", color: .gray)
    ]
    
    // This function will be accessible from SwiftUI main view
    // Here you can add the necessary code to send your messages not only to the SwiftUI view, but also to the database so that other users of the app would be able to see it
    func sendMessage(_ chatMessage: ChatMessage) {
        // here we populate the messages array
        messages.append(chatMessage)
        // here we let the SwiftUI know that we need to rebuild the views
        didChange.send(())
    }
    
    
}
