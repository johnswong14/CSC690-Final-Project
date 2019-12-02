//
//  ContentView.swift
//  CSC690-Final-Project
//
//  Created by Johnson Wong on 12/1/19.
//  Copyright © 2019 Johnson Wong. All rights reserved.
//
import SwiftUI

// ChatRow will be a view similar to a Cell in standard Swift
struct ChatRow: View {
    // We will need to access and represent the chatMessages here
    var chatMessage: ChatMessage
    
    var currentUser = ""
    
    // Body - is the body of the view
    var body: some View {
        
        // HStack - is a horizontal stack. We let the SwiftUI know that we need to place
        // all the following contents horizontally one after another
        Group {
            
            // Check if current user sent the message
            if chatMessage.username != currentUser {
                HStack {
                    Group {
                        // Show avatar of the user and their message
                        Text((chatMessage.username).prefix(1))
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Circle().fill(Color.black))
                        Text(chatMessage.msg)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
            }
            else {
                HStack {
                    Group {
                        Spacer()
                        Text(chatMessage.msg)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(10)
                        Text((chatMessage.username).prefix(1))
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
    
    @State var username = ""
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                Color.pink
                
                Image(systemName: "person.3.fill").resizable().frame(width: 200, height: 100).padding(.bottom, 470)
                
                Text("Mr. Pink's Anonymous Chat").font(.custom("Georgia", size: 25)).padding(.bottom, 320)
                
                VStack {

                    Image(systemName: "person.circle.fill").resizable().frame(width: 60, height: 60).padding(.top, 12)
                    TextField("Enter a random name", text: $username).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    
                    NavigationLink(destination: MessagePage(username: self.username)) {

                        HStack {

                            Text("Join")
                            Image(systemName: "arrow.right.circle.fill").resizable().frame(width: 20, height: 20)
                        }

                    }.frame(width: 100, height: 54)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(27)
                        .padding(.bottom, 15)
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct MessagePage: View {
    
    var username = ""
    // @State here is necessary to make the composedMessage variable accessible from different views
    @State var composedMessage: String = ""
    @EnvironmentObject var chatController: ChatController
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        // The VStack is a vertical stack where we place all our substacks like the List and the TextField
        VStack {
            // Use List to create any list in SwiftUI
            List {
                // Iterate over messages
                ForEach(chatController.messages, id: \.self) { msg in
                    ChatRow(chatMessage: msg, currentUser: self.username)
                }
            }
                // Remove seperator lines in List
                .onAppear { UITableView.appearance().separatorStyle = .none }
                .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
                .navigationBarTitle("Chat", displayMode: .inline)
            
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
            chatController.sendMessage(username: self.username, msg: self.composedMessage)
            
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
