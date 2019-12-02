//
//  ChatController.swift
//  CSC690-Final-Project
//
//  Created by Johnson Wong on 12/1/19.
//  Copyright © 2019 Johnson Wong. All rights reserved.
//

import Combine
import SwiftUI
import Firebase

// ChatController needs to be a ObservableObject in order to be accessible by SwiftUI
class ChatController: ObservableObject {
    // We've relocated the messages from the main SwiftUI View.
    // It has to be @Published in order for the new updated values to be accessible from the ContentView Controller
    @Published var messages = [ChatMessage]()
    
    init() {
        
        let db = Firestore.firestore()
        
        db.collection("messages").addSnapshotListener { (snap, err) in
            
            if err != nil {
                
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documentChanges {
                
                if i.type == .added {
                    
                    let id = i.document.documentID
                    let username = i.document.get("username") as! String
                    let msg = i.document.get("msg") as! String
                    
                    self.messages.append(ChatMessage(id: id, username: username, msg: msg))
                }
            }
        }
    }
    
    // This function will be accessible from SwiftUI main view
    // Here you can add the necessary code to send your messages not only to the SwiftUI view, but also to the database so that other users of the app would be able to see it
    func sendMessage(username: String, msg: String) {
        
        let db = Firestore.firestore()
        
        db.collection("messages").addDocument(data: ["username": username, "msg": msg]) { (err) in
            
            if err != nil {
                
                print((err?.localizedDescription)!)
                return
            }
        }
    }
    
    
}

struct ChatMessage: Hashable {
    
    var id: String
    var username: String
    var msg: String
}
