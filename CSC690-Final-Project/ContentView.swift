//
//  ContentView.swift
//  CSC690-Final-Project
//
//  Created by Johnson Wong on 12/1/19.
//  Copyright © 2019 Johnson Wong. All rights reserved.
//

import SwiftUI

// Create a structure that will represent each message in chat
struct ChatMessage: Hashable {
    var message: String
    var avatar: String
    var color: Color
    // isMe will be true if We sent the message
    var isMe: Bool = false
}

// ChatRow will be a view similar to a Cell in standard Swift
struct ChatRow: View {
    // We will need to access and represent the chatMessages here
    var chatMessage: ChatMessage
    
    // Body - is the body of the view
    var body: some View {
        // HStack - is a horizontal stack. We let the SwiftUI know that we need to place
        // all the following contents horizontally one after another
        Group {
            if !chatMessage.isMe {
                HStack {
                    Group {
                        // Show avatar of the user and their message
                        Text(chatMessage.avatar)
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Circle().fill(Color.black))
                        Text(chatMessage.message)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(chatMessage.color)
                            .cornerRadius(10)
                    }
                }
            }
            else {
                HStack {
                    Group {
                        Spacer()
                        Text(chatMessage.message)
                            .bold()
                            .foregroundColor(Color.black)
                            .padding(10)
                            .background(chatMessage.color)
                            .cornerRadius(10)
                        Text(chatMessage.avatar)
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Circle().fill(Color.black))
                    }
                }
            }
        }
    }
}

// Responsible for shifting ContentView up when keyboard is open
final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

struct ContentView: View {
    // @State here is necessary to make the composedMessage variable accessible from different views
    @State var composedMessage: String = ""
    @EnvironmentObject var chatController: ChatController
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        // The VStack is a vertical stack where we place all our substacks like the List and the TextField
        VStack {
            // Use List to create any list in SwiftUI
            List {
                Section(header: Text("Person A")) {
                    // Iterate over messages
                    ForEach(chatController.messages, id: \.self) { msg in
                        ChatRow(chatMessage: msg)
                    }
                }
            }
                // Remove seperator lines in List
                .onAppear { UITableView.appearance().separatorStyle = .none }
                .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
            
            // TextField are aligned with the Send Button in the same line so we put them in HStack
            HStack {
                // this textField generates the value for the composedMessage @State var
                TextField("Message", text: $composedMessage).frame(minHeight: CGFloat(40))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                // the button triggers the sendMessage() function written in the end of current View
                Button(action: sendMessage) {
                    //                    Text("Send")
                    //                        .foregroundColor(Color.white)
                    //                        .padding(10)
                    //                        .background(Color.green)
                    //                        .cornerRadius(10)
                    Image(systemName: "arrow.up.circle.fill").resizable().frame(width: 30, height: 30)
                }
            }.frame(minHeight: CGFloat(50)).padding()
            // that's the height of the HStack
        }
        .padding(.bottom, keyboard.currentHeight)
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeOut(duration: 0.16))
    }
    
    func sendMessage() {
        // Only send message when input field is not empty
        if composedMessage != "" {
            chatController.sendMessage(ChatMessage(message: composedMessage, avatar: "B", color: .blue, isMe: true))
            
            // Clear input field
            composedMessage = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ChatController())
    }
}
